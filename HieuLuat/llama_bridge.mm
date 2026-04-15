//
//  llama_bridge.mm
//  HieuLuat
//

#import <Foundation/Foundation.h>
#import <os/log.h>
#include "llama.h"
#include <string>
#include <vector>
#include <fstream>
#include <iostream>
#include <stdio.h>

static os_log_t llama_log = NULL;

__attribute__((constructor))
static void init_logging() {
    llama_log = os_log_create("com.hieuluat.llama", "inference");
}

// File logging for debugging
static void write_inference_log(const std::string& msg) {
    @autoreleasepool {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [paths objectAtIndex:0];
        NSString *logPath = [docDir stringByAppendingPathComponent:@"hieuluat_inference.log"];
        
        NSString *timestamp = [NSString stringWithFormat:@"[%@]", [NSDate date]];
        NSString *logMsg = [NSString stringWithFormat:@"%@ [C++] %s\n", timestamp, msg.c_str()];
        
        NSError *error = nil;
        if (![[NSFileManager defaultManager] fileExistsAtPath:logPath]) {
            [@"" writeToFile:logPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        }
        
        if (!error) {
            NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:logPath];
            [handle seekToEndOfFile];
            [handle writeData:[logMsg dataUsingEncoding:NSUTF8StringEncoding]];
            [handle synchronizeFile];
            [handle closeFile];
        }
    }
}

// Enable Metal GPU acceleration for A15/A16 devices
// Previously disabled due to shader compilation crashes, now attempting with safeguards
static int _metal_enabled = []() {
    // Only enable tensor API for A19+ devices; A15/A16 use limited offloading
    setenv("GGML_METAL_ENABLE", "1", 1);
    NSLog(@"[llama_bridge] Metal GPU enabled for inference");
    return 0;
}();

static llama_model   * s_model   = nullptr;
static llama_context * s_ctx     = nullptr;
static llama_sampler * s_sampler = nullptr;
static std::string     s_result;           // keeps return buffer alive

extern "C" {

void llama_bridge_init_model(const char * model_path) {
    if (s_model) {
        NSLog(@"[llama_bridge] model already loaded, skipping");
        return;
    }

    NSLog(@"[llama_bridge] llama_backend_init");
    
    // Initializing backend. Metal is already disabled via static initializer.
    llama_backend_init();

    // --- model ---
    //
    // GPU offload: conservative partial offloading (n_gpu_layers = 8).
    //
    // Known issue: Setting n_gpu_layers > 0 on A15/iOS can cause EXC_BAD_ACCESS in 
    // ggml_metal_encoder_set_pipeline if Metal shader pipelines fail to compile at runtime.
    // Using a small number of GPU layers (8 of 35 for Gemma-4 E2B) to:
    //   - Keep most compute on CPU (which is stable)
    //   - Offload final layers to GPU for ~20-30% speedup without hit crashes
    //   - Leave room for system memory
    // 
    // If crashes occur, reduce further. If stable, increase to 12-15 for better speedup.
    //
    struct llama_model_params mparams = llama_model_default_params();
    // GPU offload: A15 has 4GB VRAM, try 20 layers for better speedup.
    // If crashes occur, reduce to 8-12. Gemma-4 has 35 layers total.
    // Setting to -2 means all layers to GPU (max offload).
    mparams.n_gpu_layers = -2;  // All layers on GPU (A15 has enough VRAM for Q4_K_M)

    NSLog(@"[llama_bridge] loading model: %s (n_gpu_layers=%d)", model_path, mparams.n_gpu_layers);
    NSLog(@"[llama_bridge] About to call llama_model_load_from_file...");
    s_model = llama_model_load_from_file(model_path, mparams);
    NSLog(@"[llama_bridge] llama_model_load_from_file returned");
    if (!s_model) {
        NSLog(@"[llama_bridge] ERROR: failed to load model");
        return;
    }
    NSLog(@"[llama_bridge] model loaded OK (GPU offload enabled)");

    // --- context ---
    struct llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx       = 2048;  // Reduced context for A15 mobile (from 8K to 2K)
    cparams.n_batch     = 64;    // Reduced batch size to fit A15 memory (4GB VRAM)
    cparams.n_threads   = 4;
    cparams.n_threads_batch = 4;

    s_ctx = llama_init_from_model(s_model, cparams);
    if (!s_ctx) {
        NSLog(@"[llama_bridge] ERROR: failed to create context");
        llama_model_free(s_model);
        s_model = nullptr;
        return;
    }
    NSLog(@"[llama_bridge] context created OK (n_ctx=%u)", llama_n_ctx(s_ctx));

    // --- sampler chain: top_k → top_p → temp → dist ---
    struct llama_sampler_chain_params sparams = llama_sampler_chain_default_params();
    s_sampler = llama_sampler_chain_init(sparams);
    llama_sampler_chain_add(s_sampler, llama_sampler_init_top_k(40));
    llama_sampler_chain_add(s_sampler, llama_sampler_init_top_p(0.9f, 1));
    llama_sampler_chain_add(s_sampler, llama_sampler_init_temp(0.8f));
    llama_sampler_chain_add(s_sampler, llama_sampler_init_dist(LLAMA_DEFAULT_SEED));
    NSLog(@"[llama_bridge] sampler chain ready");
}

const char * llama_bridge_run_inference(const char * prompt, int max_new_tokens, const int * stop_tokens, int num_stop_tokens) {
    s_result.clear();
    os_log_with_type(llama_log, OS_LOG_TYPE_INFO, "[llama_bridge] run_inference() CALLED with prompt_len=%lu, max_new_tokens=%d", strlen(prompt), max_new_tokens);
    fprintf(stderr, "[llama_bridge] run_inference() CALLED\n");
    fflush(stderr);
    write_inference_log("run_inference() CALLED");

    if (!s_model || !s_ctx || !s_sampler) {
        NSLog(@"[llama_bridge] ERROR: model not loaded");
        write_inference_log("ERROR: model/ctx/sampler not loaded");
        s_result = "[error: model not loaded]";
        return s_result.c_str();
    }
    NSLog(@"[llama_bridge] Model/context/sampler OK");
    write_inference_log("Model/context/sampler OK");

    const struct llama_vocab * vocab = llama_model_get_vocab(s_model);

    // --- tokenize prompt ---
    const int max_tokens = 256;
    std::vector<llama_token> tokens(max_tokens);
    NSLog(@"[llama_bridge] About to tokenize prompt... (prompt_len=%lu)", strlen(prompt));
    write_inference_log("About to call llama_tokenize()");
    
    // Log the prompt for debugging
    NSLog(@"[llama_bridge] Prompt content: %.100s", prompt);
    write_inference_log(std::string("Prompt: ") + std::string(prompt).substr(0, 100));
    
    int n_tokens = llama_tokenize(vocab, prompt, (int)strlen(prompt),
                                   tokens.data(), max_tokens,
                                   /*add_special=*/true, /*parse_special=*/true);
    NSLog(@"[llama_bridge] llama_tokenize() returned: %d", n_tokens);
    write_inference_log(std::string("llama_tokenize() returned: ") + std::to_string(n_tokens));
    
    if (n_tokens < 0) {
        NSLog(@"[llama_bridge] ERROR: tokenize failed (%d)", n_tokens);
        write_inference_log("ERROR: tokenize failed");
        s_result = "[error: tokenize failed]";
        return s_result.c_str();
    }
    tokens.resize(n_tokens);
    NSLog(@"[llama_bridge] tokenized %d tokens", n_tokens);
    write_inference_log(std::string("Tokenized ") + std::to_string(n_tokens) + std::string(" tokens"));

    // --- clear KV cache ---
    NSLog(@"[llama_bridge] Clearing KV cache...");
    write_inference_log("Clearing KV cache");
    llama_memory_clear(llama_get_memory(s_ctx), /*data=*/true);
    NSLog(@"[llama_bridge] KV cache cleared");
    write_inference_log("KV cache cleared");

    // --- prefill: decode prompt batch ---
    NSLog(@"[llama_bridge] prefill: decoding %d tokens", n_tokens);
    write_inference_log(std::string("Prefill: decoding ") + std::to_string(n_tokens) + std::string(" tokens"));
    struct llama_batch batch = llama_batch_get_one(tokens.data(), n_tokens);
    NSLog(@"[llama_bridge] Created batch, about to call llama_decode...");
    write_inference_log("Created batch, about to call llama_decode()");
    
    if (llama_decode(s_ctx, batch) != 0) {
        NSLog(@"[llama_bridge] ERROR: decode (prefill) failed");
        write_inference_log("ERROR: llama_decode (prefill) failed");
        s_result = "[error: decode failed]";
        return s_result.c_str();
    }
    NSLog(@"[llama_bridge] prefill: OK");
    write_inference_log("Prefill OK");

    // --- autoregressive generation ---
    char piece_buf[64];
    NSLog(@"[llama_bridge] starting generation, max_new_tokens=%d", max_new_tokens);
    write_inference_log(std::string("Starting generation, max_new_tokens=") + std::to_string(max_new_tokens));

    for (int i = 0; i < max_new_tokens; i++) {
         // Log every step at start to catch GPU crashes early
         NSLog(@"[llama_bridge] step %d/%d starting...", i, max_new_tokens);
         write_inference_log(std::string("Step ") + std::to_string(i) + std::string("/") + std::to_string(max_new_tokens) + std::string(" - about to sample"));
         
         llama_token new_token = llama_sampler_sample(s_sampler, s_ctx, -1);
         write_inference_log(std::string("Step ") + std::to_string(i) + std::string(" - sampled token=") + std::to_string(new_token));
         
         NSLog(@"[llama_bridge] step %d/%d, token=%d", i, max_new_tokens, new_token);

        // check EOS / EOG
        if (llama_vocab_is_eog(vocab, new_token)) {
            NSLog(@"[llama_bridge] EOG at step %d", i);
            break;
        }

        // check stop tokens
        bool should_stop = false;
        for (int s = 0; s < num_stop_tokens; s++) {
            if (new_token == (llama_token)stop_tokens[s]) {
                should_stop = true;
                break;
            }
        }
        if (should_stop) {
            NSLog(@"[llama_bridge] STOP token at step %d", i);
            break;
        }

        // token → text
        write_inference_log(std::string("Step ") + std::to_string(i) + std::string(" - converting token to piece"));
        int piece_len = llama_token_to_piece(vocab, new_token,
                                             piece_buf, sizeof(piece_buf),
                                             /*lstrip=*/0, /*special=*/false);
        if (piece_len > 0) {
            s_result.append(piece_buf, piece_len);
            write_inference_log(std::string("Step ") + std::to_string(i) + std::string(" - appended ") + std::to_string(piece_len) + std::string(" chars"));
        }

        // prepare next decode: single token
        write_inference_log(std::string("Step ") + std::to_string(i) + std::string(" - preparing next decode"));
        llama_token single = new_token;
        struct llama_batch next = llama_batch_get_one(&single, 1);
        write_inference_log(std::string("Step ") + std::to_string(i) + std::string(" - about to call llama_decode"));
        if (llama_decode(s_ctx, next) != 0) {
            NSLog(@"[llama_bridge] ERROR: decode step %d failed", i);
            write_inference_log(std::string("ERROR: decode step ") + std::to_string(i) + std::string(" failed"));
            break;
        }
        write_inference_log(std::string("Step ") + std::to_string(i) + std::string(" - decode OK"));
    }

    os_log_with_type(llama_log, OS_LOG_TYPE_INFO, "[llama_bridge] generation loop finished, generated %lu chars", (unsigned long)s_result.size());
    fprintf(stderr, "[llama_bridge] INFERENCE COMPLETE! Generated %lu chars\n", (unsigned long)s_result.size());
    fprintf(stderr, "[llama_bridge] Result preview: %.100s\n", s_result.c_str());
    fflush(stderr);
    write_inference_log(std::string("Generation complete! Generated ") + std::to_string(s_result.size()) + std::string(" chars"));
    write_inference_log(std::string("Result: ") + s_result.substr(0, 200));
    NSLog(@"[llama_bridge] Result preview: %.200s", s_result.c_str());
    return s_result.c_str();
}

void llama_bridge_free(void) {
    if (s_sampler) { llama_sampler_free(s_sampler); s_sampler = nullptr; }
    if (s_ctx)     { llama_free(s_ctx);              s_ctx     = nullptr; }
    if (s_model)   { llama_model_free(s_model);      s_model   = nullptr; }
    llama_backend_free();
    NSLog(@"[llama_bridge] freed all resources");
}

} // extern "C"

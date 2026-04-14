//
//  llama_bridge.mm
//  HieuLuat
//

#import <Foundation/Foundation.h>
#include "llama.h"
#include <string>
#include <vector>

// Forcefully disable Metal at the earliest possible moment
static int _metal_disabled = []() {
    setenv("GGML_METAL_ENABLE", "0", 1);
    setenv("GGML_METAL_OFF", "1", 1);
    setenv("GGML_METAL_BF16_DISABLE", "1", 1);
    NSLog(@"[llama_bridge] Metal disabled via environment variables");
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
    // GPU offload: n_gpu_layers = 0 (CPU-only).
    //
    // Setting n_gpu_layers > 0 causes EXC_BAD_ACCESS in ggml_metal_encoder_set_pipeline
    // (ggml-metal-device.m:487) because some Metal shader pipelines fail to compile at
    // runtime on A15/iOS 26, returning NULL. The crash happens in ggml_metal_op_unary
    // during llama_decode.
    //
    // Root cause: ggml-metal's compile_pipeline returns {.pipeline=nil} on failure, but
    // callers dereference it without NULL checks → SIGSEGV.
    //
    // To re-enable GPU acceleration:
    //   1. Update llama.cpp to a newer version that may fix the pipeline NULL handling.
    //   2. Or patch ggml-metal-device.m to fallback to CPU when pipeline compile fails.
    //   3. Then set n_gpu_layers = 20~35 (Gemma-4 E2B has 35 layers, A15 has ~4GB VRAM).
    //
    struct llama_model_params mparams = llama_model_default_params();
    mparams.n_gpu_layers = 0;

    NSLog(@"[llama_bridge] loading model: %s", model_path);
    s_model = llama_model_load_from_file(model_path, mparams);
    if (!s_model) {
        NSLog(@"[llama_bridge] ERROR: failed to load model");
        return;
    }
    NSLog(@"[llama_bridge] model loaded OK");

    // --- context ---
    struct llama_context_params cparams = llama_context_default_params();
    cparams.n_ctx       = 256;
    cparams.n_batch     = 256;
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

    if (!s_model || !s_ctx || !s_sampler) {
        NSLog(@"[llama_bridge] ERROR: model not loaded");
        s_result = "[error: model not loaded]";
        return s_result.c_str();
    }

    const struct llama_vocab * vocab = llama_model_get_vocab(s_model);

    // --- tokenize prompt ---
    const int max_tokens = 256;
    std::vector<llama_token> tokens(max_tokens);
    int n_tokens = llama_tokenize(vocab, prompt, (int)strlen(prompt),
                                  tokens.data(), max_tokens,
                                  /*add_special=*/true, /*parse_special=*/true);
    if (n_tokens < 0) {
        NSLog(@"[llama_bridge] ERROR: tokenize failed (%d)", n_tokens);
        s_result = "[error: tokenize failed]";
        return s_result.c_str();
    }
    tokens.resize(n_tokens);
    NSLog(@"[llama_bridge] tokenized %d tokens", n_tokens);

    // --- clear KV cache ---
    llama_memory_clear(llama_get_memory(s_ctx), /*data=*/true);

    // --- prefill: decode prompt batch ---
    struct llama_batch batch = llama_batch_get_one(tokens.data(), n_tokens);
    if (llama_decode(s_ctx, batch) != 0) {
        NSLog(@"[llama_bridge] ERROR: decode (prefill) failed");
        s_result = "[error: decode failed]";
        return s_result.c_str();
    }

    // --- autoregressive generation ---
    char piece_buf[64];

    for (int i = 0; i < max_new_tokens; i++) {
        llama_token new_token = llama_sampler_sample(s_sampler, s_ctx, -1);

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
        int piece_len = llama_token_to_piece(vocab, new_token,
                                             piece_buf, sizeof(piece_buf),
                                             /*lstrip=*/0, /*special=*/false);
        if (piece_len > 0) {
            s_result.append(piece_buf, piece_len);
        }

        // prepare next decode: single token
        llama_token single = new_token;
        struct llama_batch next = llama_batch_get_one(&single, 1);
        if (llama_decode(s_ctx, next) != 0) {
            NSLog(@"[llama_bridge] ERROR: decode step %d failed", i);
            break;
        }
    }

    NSLog(@"[llama_bridge] generated %lu chars", (unsigned long)s_result.size());
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

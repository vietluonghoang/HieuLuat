//
//  llama_bridge.h
//  HieuLuat
//

#ifndef llama_bridge_h
#define llama_bridge_h

#ifdef __cplusplus
extern "C" {
#endif

void llama_bridge_init_model(const char * model_path,
                            int gpu_layers, int context_length,
                            int batch_size, int thread_count);
const char * llama_bridge_run_inference(const char * prompt, int max_new_tokens, const int * stop_tokens, int num_stop_tokens);
void llama_bridge_free(void);

#ifdef __cplusplus
}
#endif

#endif /* llama_bridge_h */

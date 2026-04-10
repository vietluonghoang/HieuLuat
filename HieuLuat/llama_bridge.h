//
//  llama_bridge.h
//  HieuLuat
//

#ifndef llama_bridge_h
#define llama_bridge_h

#ifdef __cplusplus
extern "C" {
#endif

void llama_bridge_init_model(const char * model_path);
const char * llama_bridge_run_inference(const char * prompt);
void llama_bridge_free(void);

#ifdef __cplusplus
}
#endif

#endif /* llama_bridge_h */

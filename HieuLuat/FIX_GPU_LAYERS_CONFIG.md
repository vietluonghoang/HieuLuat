# Fix: Remote Config aiGpuLayers Not Applied to Model Loading

## Problem

When setting `aiGpuLayers = 24` in Firebase Remote Config, the model still loads with `gpu=0`:

```
[llama_bridge] loading model: /path/to/gemma.gguf (gpu=0, ctx=2048, batch=64, threads=4)
```

Expected: `gpu=24`

## Root Cause

In `AIModelCoordinator.swift`, when a model already exists locally, the code path was:

```swift
if manager.checkModelAvailability() {
    overlay.show()
    listenForModelState()
    manager.loadModels()  // ❌ Remote config not loaded yet!
} else {
    startFullPipeline()   // ✅ This path calls fetchRemoteModelConfig()
}
```

### Why This Matters

1. `AIModelManager` initializes with default config: `aiConfig = .defaults` (gpuLayers: 0)
2. Remote config is fetched in `fetchRemoteModelConfig()` 
3. If local model exists, code skipped `fetchRemoteModelConfig()`
4. Result: Model loads with default gpuLayers=0 instead of remote config gpuLayers=24

## Solution

Added `fetchRemoteModelConfig()` call before `loadModels()`:

```swift
if manager.checkModelAvailability() {
    // Must fetch remote config BEFORE loading models to get GPU layers setting
    manager.fetchRemoteModelConfig()  // ✅ Now fetches before loading
    overlay.show()
    listenForModelState()
    manager.loadModels()
}
```

## Verification

The fix includes debug logging:

```swift
NSLog("DEBUG: AIRuntimeConfig.fromRemoteConfig() - aiGpuLayers raw value: %@", 
      rc.configValue(forKey: "aiGpuLayers"))
NSLog("DEBUG: AIRuntimeConfig.fromRemoteConfig() - gpuLayers parsed: %d", gpuLayers)
```

**To verify the fix works**:

1. Set `aiGpuLayers = 24` in Firebase Console
2. Run the app
3. Check Xcode console logs for:
   ```
   DEBUG: AIRuntimeConfig.fromRemoteConfig() - gpuLayers parsed: 24
   AIModelManager: AI config loaded — gpuLayers=24, ctx=2048, batch=64, threads=4, maxTokens=128, minRAM=5GB, minDisk=9GB
   [llama_bridge] loading model: ... (gpu=24, ctx=2048, batch=64, threads=4)
   ```

## Files Modified

- `AIModelCoordinator.swift` - Added fetchRemoteModelConfig() call
- `AIModelManager.swift` - Added debug logging to fromRemoteConfig()

## Execution Flow (After Fix)

```
startAISearch()
  ↓
checkDeviceCapability()
  ↓
shouldPromptUser()
  ├─ YES: Show dialog → user confirms → startFullPipeline()
  └─ NO: 
      ↓
      checkModelAvailability()
      ├─ NO: startFullPipeline() ✅
      └─ YES:
          ↓
          fetchRemoteModelConfig() ✅ ← NOW CALLED
          ↓
          overlay.show()
          listenForModelState()
          loadModels() ✅
```

## Related Settings

All AI runtime config from Firebase Remote Config:
- `aiGpuLayers` - Number of layers to offload to Metal GPU (0-80)
- `aiContextLength` - Model context length (default: 2048)
- `aiBatchSize` - Batch size (default: 64)
- `aiThreadCount` - Thread count (default: 4)
- `aiMaxNewTokens` - Max tokens to generate (default: 128)
- `aiMinimumRAM` - Minimum RAM required in GB (default: 5)
- `aiMinimumDiskSpace` - Minimum disk space in GB (default: 9)

## Testing Recommendations

1. **Test with local model (existing)**: Verify gpu layers from remote config
2. **Test with new download**: Verify gpu layers during fresh install
3. **Test with no network**: Verify falls back to defaults gracefully
4. **Test Firebase config changes**: Verify updates apply on next app restart
5. **Monitor Metal GPU usage**: Verify GPU layers setting actually affects performance

---

**Commit**: 87a9d01
**Date**: 2026-04-23
**Status**: ✅ BUILD SUCCEEDED

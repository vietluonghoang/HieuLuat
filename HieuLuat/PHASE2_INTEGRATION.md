# Phase 2: Logger & Analytics Integration Plan

**Current Status**: Build succeeds with temporary disabling of Logger and AnalyticsHelper calls

## Phase 2 Tasks

### Step 1: Add Core Files to Xcode Build Phases

**Files to Register** (currently in root, need to move to Core/):

```
Logger.swift → Core/Logger/Logger.swift
UIViewExtensions.swift → Core/Extensions/UIViewExtensions.swift
ConstraintHelpers.swift → Core/Layout/ConstraintHelpers.swift
AIInferenceErrorHandler.swift → Core/AI/AIInferenceErrorHandler.swift
DatabaseConnectionManager.swift → Modules/Database/Services/DatabaseConnectionManager.swift
```

**How to Do It**:
1. In Xcode, open HieuLuat.xcworkspace
2. Select HieuLuat project
3. Select HieuLuat target
4. Go to Build Phases → Compile Sources
5. Click "+" button
6. Add each file listed above
7. Verify files appear in the list
8. Save (Cmd+S)

### Step 2: Uncomment Logger Calls

Once Logger.swift is registered in build phases:

**Files to Update**:
- `GemmaInferenceEngine.swift`

**Changes**:
```swift
// BEFORE (current state)
print("Starting Gemma inference")

// AFTER (Phase 2)
Logger.info("Starting Gemma inference", category: .inference)
```

**Method**:
```bash
# In each file, replace:
sed -i '' 's/print(\(.*\))/Logger.info(\1, category: .inference)/g' filename.swift
```

### Step 3: Implement AnalyticsHelper Integration

Three options (choose one):

#### Option A: Create Global Wrapper (Recommended)
```swift
// File: Modules/Analytics/AnalyticsWrapper.swift
class AnalyticsWrapper {
    static let shared = AnalyticsHelper()
    // ... forwarding methods
}

// Make available globally:
let Analytics = AnalyticsWrapper.shared
```

#### Option B: Add Explicit Imports
Add to each file that uses AnalyticsHelper:
```swift
import AnalyticsHelper  // Not valid for same-module
// Instead: No imports needed, but ensure in compile sources
```

#### Option C: Keep Disabled (Simplest)
- Leave AnalyticsHelper calls commented out
- Implement analytics differently in Phase 3
- Current state is acceptable for now

### Step 4: Reorganize Folder Structure

**Current Structure**:
```
HieuLuat/
├── Logger.swift (root - duplicate)
├── UIViewExtensions.swift (root)
├── Core/
│   ├── Logger/
│   │   └── Logger.swift (original)
│   ├── Extensions/
│   │   └── UIViewExtensions.swift (original)
│   ├── Layout/
│   │   └── ConstraintHelpers.swift
│   └── AI/
│       └── AIInferenceErrorHandler.swift
└── Modules/
    └── Database/
        └── Services/
            └── DatabaseConnectionManager.swift
```

**Action**:
1. Delete root duplicates (Logger.swift, UIViewExtensions.swift, etc.)
2. Keep originals in Core/ and Modules/
3. Update Xcode references to point to Core/ and Modules/ locations

### Step 5: Update Documentation

- Update MIGRATION_GUIDE.md with actual integration steps
- Update QUICK_REFERENCE.md with Logger usage examples
- Document AnalyticsHelper integration decision

## Estimated Timeline

- **Step 1 (Add to Build)**: 5 minutes (manual Xcode GUI)
- **Step 2 (Uncomment Logger)**: 10 minutes (script + verify)
- **Step 3 (Analytics Integration)**: 30-60 minutes (design decision + implementation)
- **Step 4 (Folder Cleanup)**: 10 minutes
- **Step 5 (Documentation)**: 20 minutes

**Total**: ~1-2 hours for complete Phase 2

## Risk Mitigation

**Backup Before Starting**:
```bash
git commit -m "WIP: Before Phase 2 integration"
git tag phase2-start
```

**After Each Step**:
```bash
git add -A
git commit -m "phase2: Step 1 - Registered Core files in Xcode"
```

**Verify After Each Step**:
```bash
xcodebuild build -workspace HieuLuat.xcworkspace \
  -scheme HieuLuat -configuration Debug -arch arm64 -sdk iphonesimulator
```

## Success Criteria

- ✅ All Core files registered in Xcode project
- ✅ Logger calls uncommented and functional
- ✅ AnalyticsHelper integration decided and implemented
- ✅ BUILD SUCCEEDED
- ✅ All commits pushed with meaningful messages

## Notes

- Do NOT manually edit pbxproj files - use Xcode GUI
- Test build after each step
- Keep git commits small and descriptive
- Document any decisions made during integration

---

**Last Updated**: 2026-04-23
**Phase 1 Completed By**: AI Assistant

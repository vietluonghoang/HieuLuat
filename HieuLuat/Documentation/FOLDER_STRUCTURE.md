# HieuLuat Project Folder Structure (MVVM Architecture)

## Overview
This document describes the new modular MVVM architecture for the HieuLuat project.

## Folder Structure

```
HieuLuat/
│
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift (if needed)
│   └── AppConfiguration.swift
│
├── Core/
│   ├── Logger/
│   │   └── Logger.swift                    # Centralized logging
│   │
│   ├── Extensions/
│   │   └── UIViewExtensions.swift         # UI helper extensions
│   │
│   ├── Layout/
│   │   └── ConstraintHelpers.swift        # Auto Layout helpers
│   │
│   ├── AI/
│   │   └── AIInferenceErrorHandler.swift  # Error handling wrapper
│   │
│   └── Utilities/
│       ├── Constants.swift                # App-wide constants
│       └── Helpers.swift                  # General utility functions
│
├── Modules/
│   │
│   ├── Search/
│   │   ├── ViewControllers/
│   │   │   ├── VBPLSearchTableController.swift
│   │   │   ├── BBSearchTableController.swift
│   │   │   ├── InstructionSearchViewController.swift
│   │   │   └── MPSearchTableController.swift
│   │   │
│   │   ├── ViewModels/
│   │   │   ├── SearchViewModel.swift
│   │   │   └── FilterViewModel.swift
│   │   │
│   │   ├── Views/
│   │   │   ├── SearchTableViewCell.swift
│   │   │   └── FilterPopupView.swift
│   │   │
│   │   └── Models/
│   │       └── SearchResult.swift
│   │
│   ├── Details/
│   │   ├── ViewControllers/
│   │   │   ├── VBPLDetailsViewController.swift
│   │   │   ├── VBPLDetailsSearchTableController.swift
│   │   │   └── InstructionDetailsViewController.swift
│   │   │
│   │   ├── ViewModels/
│   │   │   └── DetailsViewModel.swift
│   │   │
│   │   └── Views/
│   │       └── DetailsTableViewCell.swift
│   │
│   ├── AIModel/
│   │   ├── Services/
│   │   │   ├── AIModelManager.swift
│   │   │   ├── AIModelDownloader.swift
│   │   │   ├── AIModelUnzipper.swift
│   │   │   ├── AIModelCoordinator.swift
│   │   │   └── AIModelOverlayWindow.swift
│   │   │
│   │   ├── Engines/
│   │   │   ├── AIInferenceEngine.swift
│   │   │   ├── GemmaInferenceEngine.swift
│   │   │   ├── QwenInferenceEngine.swift
│   │   │   └── LlamaInferenceEngine.swift
│   │   │
│   │   ├── Tokenizers/
│   │   │   ├── AITokenizer.swift
│   │   │   ├── GemmaTokenizer.swift
│   │   │   └── QwenTokenizer.swift
│   │   │
│   │   └── Models/
│   │       ├── AIModelConfig.swift
│   │       └── AIModelStatus.swift
│   │
│   ├── Database/
│   │   ├── Services/
│   │   │   ├── DataConnection.swift
│   │   │   └── Queries.swift
│   │   │
│   │   └── Models/
│   │       ├── Vanban.swift
│   │       ├── Dieukhoan.swift
│   │       ├── Loaivanban.swift
│   │       ├── Coquanbanhanh.swift
│   │       ├── Phantich.swift
│   │       └── Bosung.swift
│   │
│   ├── Settings/
│   │   ├── ViewControllers/
│   │   │   ├── GeneralSettings.swift
│   │   │   ├── CouponInputScreenViewController.swift
│   │   │   └── UpdatePopupViewController.swift
│   │   │
│   │   ├── ViewModels/
│   │   │   └── SettingsViewModel.swift
│   │   │
│   │   └── Views/
│   │       └── SettingsTableViewCell.swift
│   │
│   ├── Analytics/
│   │   ├── Services/
│   │   │   ├── AnalyticsHelper.swift
│   │   │   └── AdsHelper.swift
│   │   │
│   │   └── Models/
│   │       └── AnalyticsEvent.swift
│   │
│   ├── Speech/
│   │   ├── ViewControllers/
│   │   │   └── SpeechRecognizerController.swift
│   │   │
│   │   ├── Services/
│   │   │   └── SpeechRecognitionService.swift
│   │   │
│   │   └── ViewModels/
│   │       └── SpeechViewModel.swift
│   │
│   ├── Video/
│   │   ├── ViewControllers/
│   │   │   └── VideoCaptureViewController.swift
│   │   │
│   │   └── ViewModels/
│   │       └── VideoViewModel.swift
│   │
│   ├── Appearance/
│   │   ├── Services/
│   │   │   └── AppearanceUtil.swift
│   │   │
│   │   └── Styles/
│   │       └── AppTheme.swift
│   │
│   └── Navigation/
│       ├── CustomUINavigationController.swift
│       ├── VKDTableViewController.swift
│       └── NavigationManager.swift
│
├── Networking/
│   ├── DeviceInfoCollector.swift
│   ├── NetworkHandler.swift
│   └── MessagingContainer.swift
│
├── Resources/
│   ├── Assets.xcassets/
│   ├── Localizable.strings
│   ├── GoogleService-Info.plist
│   └── remote_config_defaults.plist
│
├── DesignSystem/
│   ├── Components/
│   │   ├── AutoScaleButton.swift
│   │   ├── CustomizedLabel.swift
│   │   ├── LoadingView.swift
│   │   ├── GifImageView.swift
│   │   ├── WebImage.swift
│   │   └── PickerViewSelectPopup.swift
│   │
│   └── Extensions/
│       └── UIColorExtensions.swift
│
├── Bridging/
│   ├── llama_bridge.h
│   ├── llama_bridge.mm
│   └── LlamaBridge.swift
│
├── Tests/
│   ├── HieuLuatTests/
│   │   ├── Core/
│   │   │   └── LoggerTests.swift
│   │   ├── Modules/
│   │   │   ├── AIModelManagerTests.swift
│   │   │   ├── DataConnectionTests.swift
│   │   │   └── InferenceEngineTests.swift
│   │   └── Utilities/
│   │       └── ConstraintHelpersTests.swift
│   │
│   └── HieuLuatUITests/
│       └── HieuLuatUITests.swift
│
├── .gitignore
├── Podfile
├── Podfile.lock
├── README.md
├── FOLDER_STRUCTURE.md (this file)
└── Hieuluat.sqlite
```

## Migration Guide

### Phase 1: Create Core Infrastructure (Week 1)
1. Create Core/Logger/ and Logger.swift ✅
2. Create Core/Extensions/ and UIViewExtensions.swift ✅
3. Create Core/Layout/ and ConstraintHelpers.swift ✅
4. Create Core/AI/ and AIInferenceErrorHandler.swift ✅

### Phase 2: Organize Modules (Week 2-3)
1. Create Modules/ directory structure
2. Move Search-related VCs to Modules/Search/
3. Move Details-related VCs to Modules/Details/
4. Create ViewModels for each module

### Phase 3: Improve Database Layer (Week 3)
1. Move database files to Modules/Database/
2. Create repository pattern wrappers

### Phase 4: Update AI Components (Week 4)
1. Reorganize AI files under Modules/AIModel/
2. Update all inference engines with error handling
3. Add unit tests

### Phase 5: Testing & Cleanup (Week 5)
1. Add unit tests for Core/
2. Add integration tests for modules
3. Remove deprecated Utils.swift

## Key Improvements

### 1. Logging
- **Before**: Print statements scattered throughout
- **After**: Centralized Logger with categories

### 2. Layout Management
- **Before**: 900+ lines in Utils.swift with deprecated NSLayoutConstraint
- **After**: Modern constraints using anchor API in ConstraintHelpers

### 3. Error Handling
- **Before**: NSLog + sometimes silent failures
- **After**: AIInferenceErrorHandler with proper Result types

### 4. Code Organization
- **Before**: ~70 files in root directory
- **After**: Clear module structure with feature isolation

### 5. Testing
- **Before**: No test infrastructure
- **After**: Tests organized by Core/Modules

## Migration Checklist

- [ ] Create all Core/ subdirectories
- [ ] Create all Modules/ subdirectories
- [ ] Copy and refactor existing files
- [ ] Update all imports
- [ ] Replace Utils.swift usage with Extensions/ConstraintHelpers
- [ ] Replace NSLog with Logger
- [ ] Add error handling to inference engines
- [ ] Create unit tests
- [ ] Update CI/CD if applicable
- [ ] Update documentation

## Notes

- Keep Pods/ directory as-is (don't reorganize)
- llama.cpp/ stays as external dependency
- Gradual migration is recommended to avoid breaking builds
- Update imports as you move files
- Consider using find-and-replace for Logger updates

# HieuLuat Refactoring - Quick Reference

**Quick links** for developers working on the refactored codebase.

---

## 🎯 Cheat Sheet

### Logging

```swift
// Import
import os.log  // Already included in Logger.swift

// Usage
Logger.debug("Debug message", category: .database)
Logger.info("Info message", category: .aiModel)
Logger.warning("Warning message", category: .inference)
Logger.error("Error message", error: someError, category: .network)
Logger.critical("Critical error", error: someError, category: .ui)

// Categories available
case database
case aiModel
case inference
case network
case ui
case analytics
case search
case general  // Default
```

### Image Scaling

```swift
// Instead of deprecated UIGraphicsBeginImageContext
let scaled = image.scaledToWidth(320)        // Width-based
let scaled = image.scaledToHeight(480)       // Height-based

// Chain with guard
guard let scaled = image.scaledToWidth(320) else {
    Logger.warning("Image scaling failed", category: .ui)
    return image
}
```

### Auto Layout (Constraints)

```swift
// Vertical stacking (top-to-bottom)
ConstraintHelpers.addVerticalConstraints(
    parent: containerView,
    topComponent: containerView,
    component: myView,
    top: 10,
    left: 20,
    right: 20,
    isInside: true
)

// Horizontal stacking (left-to-right)
ConstraintHelpers.addHorizontalConstraints(
    parent: containerView,
    leftComponent: containerView,
    component: myView,
    left: 10,
    top: 20,
    bottom: 20,
    isInside: true
)

// Centered vertical
ConstraintHelpers.addVerticalConstraintsWithCenterX(
    parent: containerView,
    topComponent: containerView,
    component: myView,
    top: 50,
    isInside: true
)

// Linear layout (auto stacking)
let views = [view1, view2, view3]
ConstraintHelpers.createLinearLayout(
    in: containerView,
    views: views,
    axis: .vertical,  // or .horizontal
    top: 10,
    bottom: 10,
    left: 20,
    right: 20,
    spacing: 8
)

// Fixed size
ConstraintHelpers.addWidthConstraint(to: myView, width: 200)
ConstraintHelpers.addHeightConstraint(to: myView, height: 100)
```

### AI Inference with Error Handling

```swift
// Setup wrapper
let wrapper = AIInferenceWrapper(engine: inferenceEngine, timeout: 300)

// Run with error handling
wrapper.runGenerate(
    prompt: "Your prompt here",
    maxNewTokens: 128,
    stopTokenIds: Set([2])  // End token ID
) { result in
    switch result {
    case .success(let tokens):
        Logger.info("Got \(tokens.count) tokens", category: .inference)
        // Handle tokens
        
    case .failure(let error):
        switch error {
        case .inferenceTimeout:
            self.showErrorAlert("Inference took too long")
        case .memoryInsufficient:
            self.showErrorAlert("Not enough memory")
        case .gpuError(let details):
            self.showErrorAlert("GPU error: \(details)")
        case .cancelled:
            self.showErrorAlert("Operation cancelled")
        default:
            self.showErrorAlert(error.errorDescription ?? "Unknown error")
        }
        Logger.error("Inference failed", error: error, category: .inference)
    }
}

// Cancel ongoing inference
wrapper.cancel()

// Reset engine state
wrapper.reset()
```

### Database Access

```swift
// Safe database access
do {
    // Get connection
    let db = try DatabaseConnectionManager.shared.getInstance()
    
    // Execute query
    let results = try DatabaseConnectionManager.shared.executeQuery(
        "SELECT * FROM dieukhoan WHERE vanban_id = ?",
        parameters: [vanbanID]
    )
    
    // Execute update
    try DatabaseConnectionManager.shared.executeUpdate(
        "UPDATE dieukhoan SET name = ? WHERE id = ?",
        parameters: [newName, dieukhoanID]
    )
    
} catch let error as DatabaseError {
    Logger.error("Database operation failed", error: error, category: .database)
    
    switch error {
    case .connectionFailed(let message):
        showAlert("Cannot connect: \(message)")
    case .queryFailed(let message):
        showAlert("Query failed: \(message)")
    case .versionMismatch(let current, let required):
        showAlert("Database outdated. Updating...")
        try? DatabaseConnectionManager.shared.resetDatabase()
    default:
        showAlert(error.errorDescription ?? "Unknown database error")
    }
}
```

### Button/View State

```swift
// Button state
button.updateState(
    isActive: true,
    activeColor: .systemBlue,
    inactiveColor: .systemGray
)

// View background
view.updateBackgroundState(
    isActive: isSelected,
    activeColor: .systemGreen,
    inactiveColor: .systemGray5
)

// Label font
label.applyContentFont()  // Sets size 15

// String trimming
let trimmed = "Hello World".removingLast(6)  // "Hello"
let trimmed = "Hello World".removingFirst(6) // "World"

// Screen dimensions
let width = UIView.screenWidth
let height = UIView.screenHeight
```

### Table View Height Update

```swift
// In your UIViewController
@IBOutlet weak var tableHeightConstraint: NSLayoutConstraint!
@IBOutlet weak var tableView: UITableView!

override func viewDidLoad() {
    super.viewDidLoad()
    updateTableHeight()
}

func updateTableHeight() {
    tableView.updateHeight(
        constraint: tableHeightConstraint,
        minimumHeight: 200
    )
}

// Or with default minimum
tableView.updateHeight(constraint: tableHeightConstraint)
```

---

## 🔧 Common Patterns

### Pattern 1: Safe Inference with Loading State

```swift
class MyViewModel {
    @Published var isLoading = false
    @Published var error: AIInferenceError?
    @Published var result: [Int] = []
    
    private var inferenceWrapper: AIInferenceWrapper?
    
    func runInference(prompt: String) {
        isLoading = true
        error = nil
        
        let wrapper = AIInferenceWrapper(engine: engine)
        inferenceWrapper = wrapper
        
        wrapper.runGenerate(
            prompt: prompt,
            maxNewTokens: 128,
            stopTokenIds: [2]
        ) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                switch result {
                case .success(let tokens):
                    self?.result = tokens
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    func cancelInference() {
        inferenceWrapper?.cancel()
        isLoading = false
    }
}
```

### Pattern 2: Safe Database Query

```swift
func fetchVanban(id: Int64) -> Vanban? {
    do {
        let results = try DatabaseConnectionManager.shared.executeQuery(
            "SELECT * FROM vanban WHERE id = ?",
            parameters: [id]
        )
        
        guard results.next() else {
            Logger.warning("No vanban found for id: \(id)", category: .database)
            return nil
        }
        
        let vanban = Vanban()
        vanban.id = results.longLongInt(forColumn: "id")
        vanban.name = results.string(forColumn: "name") ?? ""
        
        return vanban
        
    } catch let error as DatabaseError {
        Logger.error("Failed to fetch vanban", error: error, category: .database)
        return nil
    }
}
```

### Pattern 3: Dynamic Constraint Update

```swift
func updateLayout(for width: CGFloat) {
    if width > 600 {
        // iPad landscape
        ConstraintHelpers.addHorizontalConstraints(
            parent: containerView,
            leftComponent: leftPanel,
            component: rightPanel,
            left: 20,
            top: 0,
            bottom: 0,
            isInside: false
        )
    } else {
        // iPhone
        ConstraintHelpers.addVerticalConstraints(
            parent: containerView,
            topComponent: leftPanel,
            component: rightPanel,
            top: 20,
            left: 0,
            right: 0,
            isInside: false
        )
    }
}
```

---

## ⚠️ Common Mistakes

### ❌ Wrong
```swift
// Old NSLog - Don't use
NSLog("Operation complete")
print("Debug message")  // Also don't use in production

// Old image scaling
UIGraphicsBeginImageContextWithOptions(...)
```

### ✅ Right
```swift
// Use Logger
Logger.info("Operation complete", category: .general)

// Modern image scaling
let scaled = image.scaledToWidth(320)
```

### ❌ Wrong
```swift
// No error handling
engine.runGenerate(...) { tokens in
    // Might be empty if failed
}
```

### ✅ Right
```swift
// Proper error handling
let wrapper = AIInferenceWrapper(engine: engine)
wrapper.runGenerate(...) { result in
    switch result {
    case .success(let tokens):
        // Handle tokens
    case .failure(let error):
        // Handle error
    }
}
```

### ❌ Wrong
```swift
// Old constraints - Too verbose
Utils.generateNewComponentConstraints(parent: parent, topComponent: parent, ...)
```

### ✅ Right
```swift
// Modern constraints - Cleaner
ConstraintHelpers.addVerticalConstraints(parent: parent, topComponent: parent, ...)
```

---

## 📚 File References

| Task | File | Function |
|------|------|----------|
| Logging | `Core/Logger/Logger.swift` | `Logger.info/debug/warning/error/critical` |
| Image Scaling | `Core/Extensions/UIViewExtensions.swift` | `UIImage.scaledToWidth()` |
| Constraints | `Core/Layout/ConstraintHelpers.swift` | `ConstraintHelpers.addVertical...` |
| Inference | `Core/AI/AIInferenceErrorHandler.swift` | `AIInferenceWrapper` |
| Database | `Modules/Database/Services/DatabaseConnectionManager.swift` | `DatabaseConnectionManager.shared` |

---

## 🚨 Debugging Tips

### Check Logs
```bash
# Filter for inference logs
log stream --predicate 'category == "Inference"'

# Filter for errors
log stream --level error
```

### Enable Full Logging
Set environment variable in scheme:
```
OS_LOG_SUBSYSTEM=com.hieuluat.app
```

### Test Error Handling
```swift
// Simulate timeout
let wrapper = AIInferenceWrapper(engine: engine, timeout: 0.1)

// Simulate cancellation
wrapper.cancel()

// Simulate database error
try? DatabaseConnectionManager.shared.resetDatabase()
```

---

## 📞 Quick Links

- **Full Guide**: See `MIGRATION_GUIDE.md`
- **Structure**: See `FOLDER_STRUCTURE.md`
- **Summary**: See `REFACTORING_SUMMARY.md`
- **Xcode Docs**: Press Opt+Click on any class/function

---

**Version**: 1.0  
**Last Updated**: April 22, 2026  
**Maintainer**: Development Team

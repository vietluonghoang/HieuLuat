import UIKit
import ObjectiveC

// MARK: - Modern Button Styles

enum ButtonStyle {
    case primary       // Filled primary color (CTA, confirm, update)
    case secondary     // Outlined with primary color (cancel, secondary actions)
    case tertiary      // Subtle bordered text button (see more, filter labels)
    case link          // Plain text link, no border, no background (URLs, nav links)
    case destructive   // Red filled (delete, cancel operations)
    case icon          // Icon-only circular button (mic, speaker, close)
    case toggle        // Toggleable button with on/off states (vehicle filter)
}

// MARK: - Touch Handler (solves @objc-in-extension problem)

private class ButtonTouchHandler: NSObject {
    weak var button: UIButton?

    init(button: UIButton) {
        self.button = button
        super.init()
    }

    @objc func handleTouchDown() {
        guard let btn = button else { return }
        UIView.animate(withDuration: 0.08, delay: 0, options: [.allowUserInteraction, .curveEaseIn]) {
            btn.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
            btn.alpha = 0.7
        }
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }

    @objc func handleTouchUp() {
        guard let btn = button else { return }
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.45,
            initialSpringVelocity: 0.6,
            options: [.allowUserInteraction]
        ) {
            btn.transform = .identity
            btn.alpha = 1.0
        }
    }
}

private var kTouchHandlerKey: UInt8 = 0

// MARK: - UIButton Styling Extension

extension UIButton {

    private var touchHandler: ButtonTouchHandler? {
        get { objc_getAssociatedObject(self, &kTouchHandlerKey) as? ButtonTouchHandler }
        set { objc_setAssociatedObject(self, &kTouchHandlerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }

    func applyModernStyle(_ style: ButtonStyle) {
        adjustsImageWhenHighlighted = false
        clipsToBounds = true

        switch style {
        case .primary:
            backgroundColor = AppColors.primary
            setTitleColor(AppColors.onPrimary, for: .normal)
            setTitleColor(AppColors.onPrimary.withAlphaComponent(0.5), for: .disabled)
            layer.cornerRadius = AppRadius.md
            titleLabel?.font = AppTypography.labelLarge
            contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)

        case .secondary:
            backgroundColor = .clear
            setTitleColor(AppColors.primary, for: .normal)
            setTitleColor(AppColors.primary.withAlphaComponent(0.4), for: .disabled)
            layer.borderWidth = 1.5
            layer.borderColor = AppColors.primary.cgColor
            layer.cornerRadius = AppRadius.md
            titleLabel?.font = AppTypography.labelLarge
            contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)

        case .tertiary:
            backgroundColor = .clear
            setTitleColor(AppColors.primary, for: .normal)
            setTitleColor(AppColors.primary.withAlphaComponent(0.4), for: .disabled)
            tintColor = AppColors.primary
            layer.cornerRadius = AppRadius.sm
            layer.borderWidth = 0.5
            layer.borderColor = AppColors.outline.cgColor
            titleLabel?.font = AppTypography.labelLarge
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)

        case .link:
            backgroundColor = .clear
            setTitleColor(AppColors.primary, for: .normal)
            setTitleColor(AppColors.primary.withAlphaComponent(0.4), for: .highlighted)
            tintColor = AppColors.primary
            layer.borderWidth = 0
            layer.cornerRadius = 0
            titleLabel?.font = AppTypography.bodyMedium

        case .destructive:
            backgroundColor = AppColors.error
            setTitleColor(.white, for: .normal)
            layer.cornerRadius = AppRadius.md
            titleLabel?.font = AppTypography.labelLarge
            contentEdgeInsets = UIEdgeInsets(top: 12, left: 24, bottom: 12, right: 24)

        case .icon:
            backgroundColor = AppColors.surfaceVariant
            tintColor = AppColors.onSurfaceVariant
            layer.cornerRadius = AppRadius.full
            layer.borderWidth = 0.5
            layer.borderColor = AppColors.outline.cgColor
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)

        case .toggle:
            backgroundColor = AppColors.surfaceVariant
            setTitleColor(AppColors.onSurfaceVariant, for: .normal)
            layer.cornerRadius = AppRadius.sm
            layer.borderWidth = 1
            layer.borderColor = AppColors.outline.cgColor
            titleLabel?.font = AppTypography.labelMedium
            contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        }

        addTouchAnimations()
    }

    func addTouchAnimations() {
        guard touchHandler == nil else { return }
        let handler = ButtonTouchHandler(button: self)
        self.touchHandler = handler
        addTarget(handler, action: #selector(ButtonTouchHandler.handleTouchDown), for: .touchDown)
        addTarget(handler, action: #selector(ButtonTouchHandler.handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    func applyToggleState(isOn: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: [.allowUserInteraction]) {
            if isOn {
                self.backgroundColor = AppColors.primaryContainer
                self.setTitleColor(AppColors.primary, for: .normal)
                self.layer.borderColor = AppColors.primary.cgColor
                self.layer.borderWidth = 1.5
            } else {
                self.backgroundColor = AppColors.surfaceVariant
                self.setTitleColor(AppColors.onSurfaceVariant, for: .normal)
                self.layer.borderColor = AppColors.outline.cgColor
                self.layer.borderWidth = 1
            }
        }
    }
}

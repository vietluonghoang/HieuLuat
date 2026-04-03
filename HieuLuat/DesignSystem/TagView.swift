import UIKit

class TagView: UIView {
    enum TagStyle {
        case primary
        case success
        case warning
        case danger
        case neutral
        case custom(bg: UIColor, text: UIColor)
    }

    private let label = UILabel()
    private let iconView = UIImageView()

    init(text: String, style: TagStyle = .neutral, icon: UIImage? = nil) {
        super.init(frame: .zero)
        label.text = text
        iconView.image = icon
        setupView(style: style)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(style: .neutral)
    }

    private func setupView(style: TagStyle) {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = AppRadius.sm

        let (bgColor, textColor) = colors(for: style)
        backgroundColor = bgColor

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = AppSpacing.xs
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        if iconView.image != nil {
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = textColor
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.widthAnchor.constraint(equalToConstant: 12),
                iconView.heightAnchor.constraint(equalToConstant: 12)
            ])
            stack.addArrangedSubview(iconView)
        }

        label.font = AppTypography.labelSmall
        label.textColor = textColor
        stack.addArrangedSubview(label)

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: AppSpacing.xs),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppSpacing.sm),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppSpacing.sm),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AppSpacing.xs)
        ])
    }

    private func colors(for style: TagStyle) -> (UIColor, UIColor) {
        switch style {
        case .primary:
            return (AppColors.primaryContainer, AppColors.primary)
        case .success:
            return (AppColors.success.withAlphaComponent(0.12), AppColors.success)
        case .warning:
            return (AppColors.penaltyMedium.withAlphaComponent(0.12), AppColors.penaltyMedium)
        case .danger:
            return (AppColors.error.withAlphaComponent(0.12), AppColors.error)
        case .neutral:
            return (AppColors.surfaceVariant, AppColors.onSurfaceVariant)
        case .custom(let bg, let text):
            return (bg, text)
        }
    }

    func updateText(_ text: String) {
        label.text = text
    }
}

// MARK: - Penalty Tag Helper

extension TagView {
    static func forPenalty(amount: String) -> TagView {
        let numericString = amount.replacingOccurrences(of: ".", with: "")
        let value = Int(numericString) ?? 0
        let style: TagStyle
        if value < 500_000 {
            style = .primary
        } else if value < 5_000_000 {
            style = .warning
        } else {
            style = .danger
        }
        let icon = UIImage(systemName: "banknote")
        return TagView(text: amount + "đ", style: style, icon: icon)
    }

    static func forVehicle(_ name: String) -> TagView {
        let iconName: String
        switch name.lowercased() {
        case let n where n.contains("ô tô") || n.contains("oto"):
            iconName = "car.fill"
        case let n where n.contains("xe máy") || n.contains("moto"):
            iconName = "bicycle"
        case let n where n.contains("xe đạp"):
            iconName = "figure.walk"
        default:
            iconName = "car.fill"
        }
        let icon = UIImage(systemName: iconName)
        return TagView(text: name, style: .neutral, icon: icon)
    }
}

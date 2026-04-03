import UIKit

class CardView: UIView {
    enum Style {
        case elevated
        case filled
        case outlined
    }

    private let style: Style
    private let contentView = UIView()

    init(style: Style = .elevated) {
        self.style = style
        super.init(frame: .zero)
        setupView()
    }

    required init?(coder: NSCoder) {
        self.style = .elevated
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = AppRadius.lg
        clipsToBounds = false

        switch style {
        case .elevated:
            backgroundColor = AppColors.surface
            AppShadow.light(for: layer)
        case .filled:
            backgroundColor = AppColors.surfaceContainer
        case .outlined:
            backgroundColor = AppColors.surface
            layer.borderWidth = 1
            layer.borderColor = AppColors.outlineVariant.cgColor
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if style == .outlined {
            layer.borderColor = AppColors.outlineVariant.cgColor
        }
    }

    func applyGradient(colors: [UIColor]) {
        let gradient = CAGradientLayer()
        gradient.colors = colors.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.cornerRadius = AppRadius.lg
        gradient.frame = bounds
        layer.insertSublayer(gradient, at: 0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.sublayers?.first(where: { $0 is CAGradientLayer })?.frame = bounds
    }
}

// MARK: - Convenience initializer for wrapping content

extension CardView {
    static func wrap(_ content: UIView, padding: CGFloat = AppSpacing.md, style: Style = .elevated) -> CardView {
        let card = CardView(style: style)
        content.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(content)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: card.topAnchor, constant: padding),
            content.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: padding),
            content.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -padding),
            content.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -padding)
        ])
        return card
    }
}

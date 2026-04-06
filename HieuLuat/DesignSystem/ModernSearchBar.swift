import UIKit

class ModernSearchBar: UIView {
    private let containerView = UIView()
    private let searchIcon = UIImageView()
    let textField = UITextField()
    let microButton = UIButton(type: .system)
    private let aiIndicatorView = AIBadgeView()

    var onTextChanged: ((String) -> Void)?
    var onMicroTapped: (() -> Void)?

    var text: String? {
        get { textField.text }
        set { textField.text = newValue }
    }

    var showAIBadge: Bool = false {
        didSet { aiIndicatorView.isHidden = !showAIBadge }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false

        containerView.backgroundColor = AppColors.surfaceVariant
        containerView.layer.cornerRadius = AppRadius.xl
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        // Search icon
        searchIcon.image = UIImage(systemName: "magnifyingglass")
        searchIcon.tintColor = AppColors.onSurfaceVariant
        searchIcon.contentMode = .scaleAspectFit
        searchIcon.translatesAutoresizingMaskIntoConstraints = false

        // Text field
        textField.placeholder = "Tìm kiếm..."
        textField.font = AppTypography.bodyLarge
        textField.textColor = AppColors.onSurface
        textField.tintColor = AppColors.primary
        textField.borderStyle = .none
        textField.returnKeyType = .search
        textField.clearButtonMode = .whileEditing
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textChanged), for: .editingChanged)

        // Micro button
        let microConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        microButton.setImage(UIImage(systemName: "mic.fill", withConfiguration: microConfig), for: .normal)
        microButton.tintColor = AppColors.onSurfaceVariant
        microButton.translatesAutoresizingMaskIntoConstraints = false
        microButton.addTarget(self, action: #selector(microTapped), for: .touchUpInside)
        microButton.addTouchAnimations()

        // AI badge
        aiIndicatorView.isHidden = true

        containerView.addSubview(searchIcon)
        containerView.addSubview(textField)
        containerView.addSubview(microButton)
        containerView.addSubview(aiIndicatorView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 48),

            searchIcon.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: AppSpacing.md),
            searchIcon.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),

            textField.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: AppSpacing.sm),
            textField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            textField.trailingAnchor.constraint(equalTo: aiIndicatorView.leadingAnchor, constant: -AppSpacing.xs),

            aiIndicatorView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            aiIndicatorView.trailingAnchor.constraint(equalTo: microButton.leadingAnchor, constant: -AppSpacing.xs),

            microButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -AppSpacing.sm),
            microButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            microButton.widthAnchor.constraint(equalToConstant: 36),
            microButton.heightAnchor.constraint(equalToConstant: 36)
        ])
    }

    @objc private func textChanged() {
        onTextChanged?(textField.text ?? "")
    }

    @objc private func microTapped() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        onMicroTapped?()
    }

    func animateFocus() {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5) {
            self.containerView.backgroundColor = AppColors.surface
            self.containerView.layer.borderWidth = 2
            self.containerView.layer.borderColor = AppColors.primary.cgColor
            AppShadow.light(for: self.containerView.layer)
        }
    }

    func animateBlur() {
        UIView.animate(withDuration: 0.3) {
            self.containerView.backgroundColor = AppColors.surfaceVariant
            self.containerView.layer.borderWidth = 0
            self.containerView.layer.shadowOpacity = 0
        }
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if containerView.layer.borderWidth > 0 {
            containerView.layer.borderColor = AppColors.primary.cgColor
        }
    }
}

// MARK: - AI Badge View

class AIBadgeView: UIView {
    private let sparkleIcon = UIImageView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.tertiary.withAlphaComponent(0.12)
        layer.cornerRadius = AppRadius.sm

        let config = UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
        sparkleIcon.image = UIImage(systemName: "sparkles", withConfiguration: config)
        sparkleIcon.tintColor = AppColors.tertiary
        sparkleIcon.translatesAutoresizingMaskIntoConstraints = false

        label.text = "AI"
        label.font = UIFont.systemFont(ofSize: 10, weight: .bold)
        label.textColor = AppColors.tertiary

        let stack = UIStackView(arrangedSubviews: [sparkleIcon, label])
        stack.axis = .horizontal
        stack.spacing = 2
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 3),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 5),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -5),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3)
        ])
    }

    func startGlow() {
        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1.0
        animation.toValue = 0.4
        animation.duration = 1.0
        animation.autoreverses = true
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "glow")
    }

    func stopGlow() {
        layer.removeAnimation(forKey: "glow")
    }
}

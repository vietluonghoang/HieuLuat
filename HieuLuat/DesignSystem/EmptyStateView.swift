import UIKit

class EmptyStateView: UIView {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let actionButton = UIButton(type: .system)

    var onAction: (() -> Void)?

    init(image: UIImage? = nil, title: String, subtitle: String? = nil, actionTitle: String? = nil) {
        super.init(frame: .zero)
        setupView(image: image, title: title, subtitle: subtitle, actionTitle: actionTitle)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView(image: nil, title: "", subtitle: nil, actionTitle: nil)
    }

    private func setupView(image: UIImage?, title: String, subtitle: String?, actionTitle: String?) {
        translatesAutoresizingMaskIntoConstraints = false
        isHidden = true

        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = AppSpacing.md
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        // Image
        let config = UIImage.SymbolConfiguration(pointSize: 48, weight: .light)
        let defaultImage = UIImage(systemName: "doc.text.magnifyingglass", withConfiguration: config)
        imageView.image = image ?? defaultImage
        imageView.tintColor = AppColors.onSurfaceVariant.withAlphaComponent(0.5)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 80),
            imageView.heightAnchor.constraint(equalToConstant: 80)
        ])
        stack.addArrangedSubview(imageView)

        // Title
        titleLabel.text = title
        titleLabel.font = AppTypography.titleMedium
        titleLabel.textColor = AppColors.onSurface
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        stack.addArrangedSubview(titleLabel)

        // Subtitle
        if let subtitle = subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.font = AppTypography.bodyMedium
            subtitleLabel.textColor = AppColors.onSurfaceVariant
            subtitleLabel.textAlignment = .center
            subtitleLabel.numberOfLines = 0
            stack.addArrangedSubview(subtitleLabel)
        }

        // Action button
        if let actionTitle = actionTitle {
            actionButton.setTitle(actionTitle, for: .normal)
            actionButton.titleLabel?.font = AppTypography.labelLarge
            actionButton.tintColor = AppColors.primary
            actionButton.addTarget(self, action: #selector(actionTapped), for: .touchUpInside)
            stack.addArrangedSubview(actionButton)
        }

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerXAnchor.constraint(equalTo: centerXAnchor),
            stack.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -AppSpacing.xl),
            stack.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: AppSpacing.xl),
            stack.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -AppSpacing.xl)
        ])
    }

    @objc private func actionTapped() {
        onAction?()
    }
}

// MARK: - Skeleton Loading View

class SkeletonView: UIView {
    private var gradientLayer = CAGradientLayer()

    init(height: CGFloat = 20, cornerRadius: CGFloat = AppRadius.sm) {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.surfaceVariant
        layer.cornerRadius = cornerRadius
        clipsToBounds = true
        heightAnchor.constraint(equalToConstant: height).isActive = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }

    func startShimmer() {
        gradientLayer.removeFromSuperlayer()

        let lightColor = AppColors.surfaceVariant.cgColor
        let darkColor = AppColors.outline.withAlphaComponent(0.3).cgColor

        gradientLayer.colors = [lightColor, darkColor, lightColor]
        gradientLayer.locations = [0.0, 0.5, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.frame = CGRect(x: -bounds.width, y: 0, width: bounds.width * 3, height: bounds.height)
        layer.addSublayer(gradientLayer)

        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = -bounds.width
        animation.toValue = bounds.width
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmer")
    }

    func stopShimmer() {
        gradientLayer.removeAllAnimations()
        gradientLayer.removeFromSuperlayer()
    }
}

// MARK: - Skeleton Cell Helper

class SkeletonCellView: UIView {
    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = AppColors.surface
        layer.cornerRadius = AppRadius.lg

        let titleSkeleton = SkeletonView(height: 14)
        let subtitleSkeleton = SkeletonView(height: 10)
        let bodySkeleton1 = SkeletonView(height: 12)
        let bodySkeleton2 = SkeletonView(height: 12)

        let stack = UIStackView(arrangedSubviews: [titleSkeleton, subtitleSkeleton, bodySkeleton1, bodySkeleton2])
        stack.axis = .vertical
        stack.spacing = AppSpacing.sm
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: AppSpacing.md),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppSpacing.md),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppSpacing.md),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AppSpacing.md),

            subtitleSkeleton.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.6),
            bodySkeleton2.widthAnchor.constraint(equalTo: stack.widthAnchor, multiplier: 0.8)
        ])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            [titleSkeleton, subtitleSkeleton, bodySkeleton1, bodySkeleton2].forEach { $0.startShimmer() }
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

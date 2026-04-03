import UIKit

class ChipView: UIView {
    private let label = UILabel()
    private let iconView = UIImageView()
    private let closeButton = UIButton(type: .system)

    var isChipSelected: Bool = false {
        didSet { updateAppearance() }
    }

    var onTap: (() -> Void)?
    var onClose: (() -> Void)?

    private let showClose: Bool

    init(text: String, icon: UIImage? = nil, showClose: Bool = false) {
        self.showClose = showClose
        super.init(frame: .zero)
        label.text = text
        iconView.image = icon
        setupView()
    }

    required init?(coder: NSCoder) {
        self.showClose = false
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = AppRadius.full
        layer.borderWidth = 1

        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = AppSpacing.xs
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false

        if iconView.image != nil {
            iconView.contentMode = .scaleAspectFit
            iconView.tintColor = AppColors.onSurface
            iconView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                iconView.widthAnchor.constraint(equalToConstant: 16),
                iconView.heightAnchor.constraint(equalToConstant: 16)
            ])
            stack.addArrangedSubview(iconView)
        }

        label.font = AppTypography.labelMedium
        label.textColor = AppColors.onSurface
        stack.addArrangedSubview(label)

        if showClose {
            let xIcon = UIImage(systemName: "xmark")?.withConfiguration(
                UIImage.SymbolConfiguration(pointSize: 10, weight: .semibold)
            )
            closeButton.setImage(xIcon, for: .normal)
            closeButton.tintColor = AppColors.onSurfaceVariant
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                closeButton.widthAnchor.constraint(equalToConstant: 18),
                closeButton.heightAnchor.constraint(equalToConstant: 18)
            ])
            closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
            stack.addArrangedSubview(closeButton)
        }

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: AppSpacing.sm),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: AppSpacing.md),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -AppSpacing.md),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -AppSpacing.sm),
            heightAnchor.constraint(greaterThanOrEqualToConstant: 32)
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tap)

        updateAppearance()
    }

    private func updateAppearance() {
        UIView.animate(withDuration: 0.2) {
            if self.isChipSelected {
                self.backgroundColor = AppColors.primaryContainer
                self.layer.borderColor = AppColors.primary.cgColor
                self.label.textColor = AppColors.primary
                self.iconView.tintColor = AppColors.primary
            } else {
                self.backgroundColor = .clear
                self.layer.borderColor = AppColors.outline.cgColor
                self.label.textColor = AppColors.onSurface
                self.iconView.tintColor = AppColors.onSurface
            }
        }
    }

    @objc private func handleTap() {
        isChipSelected.toggle()
        onTap?()
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    @objc private func closeTapped() {
        onClose?()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateAppearance()
    }
}

// MARK: - ChipGroup

class ChipGroupView: UIView {
    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var chips: [ChipView] = []

    var onSelectionChanged: (([Int]) -> Void)?

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

        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(scrollView)

        stackView.axis = .horizontal
        stackView.spacing = AppSpacing.sm
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor),

            stackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: AppSpacing.md),
            stackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -AppSpacing.md),
            stackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            stackView.heightAnchor.constraint(equalTo: scrollView.heightAnchor),

            heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    func setChips(_ items: [(text: String, icon: UIImage?)]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        chips.removeAll()

        for (index, item) in items.enumerated() {
            let chip = ChipView(text: item.text, icon: item.icon)
            chip.tag = index
            chip.onTap = { [weak self] in
                self?.chipTapped(index: index)
            }
            stackView.addArrangedSubview(chip)
            chips.append(chip)
        }
    }

    private func chipTapped(index: Int) {
        let selectedIndices = chips.enumerated()
            .filter { $0.element.isChipSelected }
            .map { $0.offset }
        onSelectionChanged?(selectedIndices)
    }

    func setSelected(at index: Int, selected: Bool) {
        guard index < chips.count else { return }
        chips[index].isChipSelected = selected
    }
}

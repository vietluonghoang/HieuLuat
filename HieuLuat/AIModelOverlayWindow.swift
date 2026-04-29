//
//  AIModelOverlayWindow.swift
//  HieuLuat
//
//  Created by AI Assistant on 3/27/26.
//  Copyright © 2026 VietLH. All rights reserved.
//

import UIKit

class AIModelOverlayWindow: UIWindow {

    static let shared = AIModelOverlayWindow()

    var onCancel: (() -> Void)?
    var onRetry: (() -> Void)?

    private var isMinimized = false

    // MARK: - Expanded UI

    private let backgroundView = UIView()
    private let cardView = UIView()
    private let titleLabel = UILabel()
    private let statusLabel = UILabel()
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let percentageLabel = UILabel()
    private let speedLabel = UILabel()
    private let cancelButton = UIButton(type: .system)
    private let retryButton = UIButton(type: .system)
    private let checkmarkLabel = UILabel()
    private let minimizeButton = UIButton(type: .system)
    private let loadingIndicator = UIActivityIndicatorView(style: .medium)

    // MARK: - Minimized UI (floating bubble)

    private let bubbleView = UIView()
    private let bubbleIconLabel = UILabel()
    private let bubbleStatusLabel = UILabel()
    private let bubbleProgressView = UIProgressView(progressViewStyle: .default)
    private let bubblePercentLabel = UILabel()

    // Track current progress for syncing between expanded/minimized
    private var currentProgress: Float = 0
    private var currentStatusText: String = ""
    private var isShowingSuccess = false
    private var isShowingError = false

    private init() {
        if #available(iOS 13.0, *),
           let windowScene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first {
            super.init(windowScene: windowScene)
        } else {
            super.init(frame: UIScreen.main.bounds)
        }
        setupWindow()
        setupExpandedUI()
        setupMinimizedBubble()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Touch pass-through

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if isMinimized {
            let bubblePoint = convert(point, to: bubbleView)
            if bubbleView.bounds.contains(bubblePoint) && !bubbleView.isHidden {
                return bubbleView.hitTest(bubblePoint, with: event)
            }
            return nil
        }
        return super.hitTest(point, with: event)
    }

    // MARK: - Setup

    private func setupWindow() {
        let transparentVC = UIViewController()
        transparentVC.view.backgroundColor = .clear
        rootViewController = transparentVC
        windowLevel = .alert + 1
        backgroundColor = .clear
        isHidden = true
        alpha = 0
    }

    private func setupExpandedUI() {
        guard let rootView = rootViewController?.view else { return }

        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(backgroundView)
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: rootView.topAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: rootView.bottomAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: rootView.leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: rootView.trailingAnchor)
        ])

        let bgTap = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        bgTap.cancelsTouchesInView = false
        backgroundView.addGestureRecognizer(bgTap)

        if #available(iOS 13.0, *) {
            cardView.backgroundColor = .systemBackground
        } else {
            cardView.backgroundColor = .white
        }
        cardView.layer.cornerRadius = 16
        cardView.clipsToBounds = true
        cardView.translatesAutoresizingMaskIntoConstraints = false
        rootView.addSubview(cardView)
        NSLayoutConstraint.activate([
            cardView.centerXAnchor.constraint(equalTo: rootView.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: rootView.centerYAnchor),
            cardView.widthAnchor.constraint(equalToConstant: 300)
        ])

        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            stackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24),
            stackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24)
        ])

        // Title row with minimize button
        let titleRow = UIStackView()
        titleRow.axis = .horizontal
        titleRow.spacing = 8
        titleRow.alignment = .center
        titleRow.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(titleRow)
        NSLayoutConstraint.activate([
            titleRow.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])

        titleLabel.text = "AI Search"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        if #available(iOS 13.0, *) { titleLabel.textColor = .label } else { titleLabel.textColor = .black }
        titleLabel.textAlignment = .left
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleRow.addArrangedSubview(titleLabel)

        minimizeButton.setTitle("▾", for: .normal)
        minimizeButton.titleLabel?.font = UIFont.systemFont(ofSize: 22, weight: .medium)
        minimizeButton.setTitleColor(.gray, for: .normal)
        minimizeButton.addTarget(self, action: #selector(minimizeTapped), for: .touchUpInside)
        minimizeButton.setContentHuggingPriority(.required, for: .horizontal)
        titleRow.addArrangedSubview(minimizeButton)

        statusLabel.text = "Đang tải..."
        statusLabel.font = UIFont.systemFont(ofSize: 14)
        statusLabel.textColor = .gray
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 0
        stackView.addArrangedSubview(statusLabel)

        progressView.progressTintColor = .cyan
        progressView.trackTintColor = UIColor.cyan.withAlphaComponent(0.2)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.widthAnchor.constraint(equalTo: stackView.widthAnchor)
        ])

        percentageLabel.text = "0%"
        percentageLabel.font = UIFont.boldSystemFont(ofSize: 16)
        if #available(iOS 13.0, *) { percentageLabel.textColor = .label } else { percentageLabel.textColor = .black }
        percentageLabel.textAlignment = .center
        stackView.addArrangedSubview(percentageLabel)

        speedLabel.text = "0 MB/s"
        speedLabel.font = UIFont.systemFont(ofSize: 12)
        speedLabel.textColor = .lightGray
        speedLabel.textAlignment = .center
        stackView.addArrangedSubview(speedLabel)

        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.color = .cyan
        stackView.addArrangedSubview(loadingIndicator)

        checkmarkLabel.text = "✓ Hoàn tất!"
        checkmarkLabel.font = UIFont.boldSystemFont(ofSize: 20)
        checkmarkLabel.textColor = UIColor(red: 56/255, green: 207/255, blue: 109/255, alpha: 1)
        checkmarkLabel.textAlignment = .center
        checkmarkLabel.isHidden = true
        stackView.addArrangedSubview(checkmarkLabel)

        cancelButton.setTitle("Hủy", for: .normal)
        cancelButton.applyModernStyle(.destructive)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        stackView.addArrangedSubview(cancelButton)

        retryButton.setTitle("Thử lại", for: .normal)
        retryButton.applyModernStyle(.primary)
        retryButton.addTarget(self, action: #selector(retryTapped), for: .touchUpInside)
        retryButton.isHidden = true
        stackView.addArrangedSubview(retryButton)
    }

    private func setupMinimizedBubble() {
        guard let rootView = rootViewController?.view else { return }

        let bubbleWidth: CGFloat = 160
        let bubbleHeight: CGFloat = 56
        bubbleView.frame = CGRect(x: 12, y: rootView.bounds.height - bubbleHeight - 12, width: bubbleWidth, height: bubbleHeight)
        bubbleView.autoresizingMask = []
        bubbleView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.15, alpha: 0.95)
        bubbleView.layer.cornerRadius = 28
        bubbleView.clipsToBounds = true
        bubbleView.layer.borderColor = UIColor.cyan.withAlphaComponent(0.4).cgColor
        bubbleView.layer.borderWidth = 1.5
        bubbleView.isHidden = true
        rootView.addSubview(bubbleView)

        // Icon
        bubbleIconLabel.text = "🤖"
        bubbleIconLabel.font = UIFont.systemFont(ofSize: 22)
        bubbleIconLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(bubbleIconLabel)

        // Status text (e.g. "Đang tải" / "Giải nén" / "Nạp mô hình")
        bubbleStatusLabel.text = "Đang tải"
        bubbleStatusLabel.font = UIFont.systemFont(ofSize: 11)
        bubbleStatusLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        bubbleStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(bubbleStatusLabel)

        // Percent label
        bubblePercentLabel.text = "0%"
        bubblePercentLabel.font = UIFont.boldSystemFont(ofSize: 13)
        bubblePercentLabel.textColor = .white
        bubblePercentLabel.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(bubblePercentLabel)

        // Progress bar
        bubbleProgressView.progressTintColor = .cyan
        bubbleProgressView.trackTintColor = UIColor.cyan.withAlphaComponent(0.2)
        bubbleProgressView.translatesAutoresizingMaskIntoConstraints = false
        bubbleView.addSubview(bubbleProgressView)

        // Layout: icon | statusLabel + percentLabel / progressBar
        NSLayoutConstraint.activate([
            bubbleIconLabel.leadingAnchor.constraint(equalTo: bubbleView.leadingAnchor, constant: 12),
            bubbleIconLabel.centerYAnchor.constraint(equalTo: bubbleView.centerYAnchor),
            bubbleIconLabel.widthAnchor.constraint(equalToConstant: 28),

            bubbleStatusLabel.leadingAnchor.constraint(equalTo: bubbleIconLabel.trailingAnchor, constant: 6),
            bubbleStatusLabel.topAnchor.constraint(equalTo: bubbleView.topAnchor, constant: 9),

            bubblePercentLabel.leadingAnchor.constraint(equalTo: bubbleStatusLabel.trailingAnchor, constant: 4),
            bubblePercentLabel.trailingAnchor.constraint(lessThanOrEqualTo: bubbleView.trailingAnchor, constant: -10),
            bubblePercentLabel.firstBaselineAnchor.constraint(equalTo: bubbleStatusLabel.firstBaselineAnchor),

            bubbleProgressView.leadingAnchor.constraint(equalTo: bubbleIconLabel.trailingAnchor, constant: 6),
            bubbleProgressView.trailingAnchor.constraint(equalTo: bubbleView.trailingAnchor, constant: -10),
            bubbleProgressView.topAnchor.constraint(equalTo: bubbleStatusLabel.bottomAnchor, constant: 6),
            bubbleProgressView.heightAnchor.constraint(equalToConstant: 4)
        ])

        // Tap to maximize
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(bubbleTapped))
        bubbleView.addGestureRecognizer(tapGesture)

        // Drag gesture
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(bubbleDragged(_:)))
        bubbleView.addGestureRecognizer(panGesture)
    }

    // MARK: - Actions

    @objc private func cancelTapped() {
        onCancel?()
    }

    @objc private func retryTapped() {
        onRetry?()
    }

    @objc private func minimizeTapped() {
        animateToMinimized()
    }

    @objc private func backgroundTapped() {
        // Allow minimize from background tap unless showing success
        if !isShowingSuccess {
            animateToMinimized()
        }
    }

    @objc private func bubbleTapped() {
        animateToExpanded()
    }

    @objc private func bubbleDragged(_ gesture: UIPanGestureRecognizer) {
        guard let rootView = rootViewController?.view else { return }

        switch gesture.state {
        case .changed:
            let translation = gesture.translation(in: rootView)
            bubbleView.center = CGPoint(
                x: bubbleView.center.x + translation.x,
                y: bubbleView.center.y + translation.y
            )
            gesture.setTranslation(.zero, in: rootView)
        case .ended, .cancelled:
            let bounds = rootView.bounds
            let safeInsets = rootView.safeAreaInsets
            let margin: CGFloat = 8
            let size = bubbleView.bounds.size

            // Snap horizontally to nearest edge
            let leftX = margin
            let rightX = bounds.width - size.width - margin
            var targetX = bubbleView.frame.origin.x
            targetX = (bubbleView.center.x < bounds.midX) ? leftX : rightX

            // Clamp vertically within safe area
            let minY = safeInsets.top + margin
            let maxY = bounds.height - safeInsets.bottom - size.height - margin
            var targetY = bubbleView.frame.origin.y
            targetY = max(minY, min(targetY, maxY))

            UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseOut) {
                self.bubbleView.frame.origin = CGPoint(x: targetX, y: targetY)
            }
        default:
            break
        }
    }

    // MARK: - Minimize / Maximize Animations

    private func animateToMinimized() {
        guard !isMinimized else { return }
        isMinimized = true
        isUserInteractionEnabled = true

        syncBubbleState()

        // Position bubble at bottom-left using current safe area
        if let rootView = rootViewController?.view {
            let margin: CGFloat = 12
            let safeBottom = rootView.safeAreaInsets.bottom
            bubbleView.frame.origin = CGPoint(
                x: margin,
                y: rootView.bounds.height - bubbleView.bounds.height - safeBottom - margin
            )
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 0
            self.cardView.alpha = 0
            self.cardView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: { _ in
            self.backgroundView.isHidden = true
            self.cardView.isHidden = true
            self.bubbleView.isHidden = false
            self.bubbleView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            self.bubbleView.alpha = 0
            UIView.animate(withDuration: 0.25) {
                self.bubbleView.transform = .identity
                self.bubbleView.alpha = 1
            }
        })
    }

    private func animateToExpanded() {
        guard isMinimized else { return }
        isMinimized = false

        UIView.animate(withDuration: 0.2, animations: {
            self.bubbleView.alpha = 0
            self.bubbleView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        }, completion: { _ in
            self.bubbleView.isHidden = true
            self.bubbleView.transform = .identity
            self.backgroundView.isHidden = false
            self.cardView.isHidden = false
            self.backgroundView.alpha = 0
            self.cardView.alpha = 0
            self.cardView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            UIView.animate(withDuration: 0.3) {
                self.backgroundView.alpha = 1
                self.cardView.alpha = 1
                self.cardView.transform = .identity
            }
        })
    }

    private func syncBubbleState() {
        bubbleProgressView.progress = currentProgress
        bubbleProgressView.isHidden = false

        if isShowingSuccess {
            bubbleIconLabel.text = "✅"
            bubbleStatusLabel.text = "Hoàn tất!"
            bubblePercentLabel.text = ""
            bubbleProgressView.progress = 1.0
        } else {
            bubbleIconLabel.text = "🤖"
            bubbleStatusLabel.text = currentStatusText
            bubblePercentLabel.text = "\(Int(currentProgress * 100))%"
        }
    }

    // MARK: - Public Methods

    func show() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isMinimized = false
            self.isShowingSuccess = false
            self.isShowingError = false
            self.resetUI()
            self.backgroundView.isHidden = false
            self.cardView.isHidden = false
            self.bubbleView.isHidden = true
            self.backgroundView.alpha = 1
            self.cardView.alpha = 1
            self.cardView.transform = .identity
            self.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
            }
        }
    }
    
    /// Show directly in minimized state (floating bubble)
    func showMinimized() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isMinimized = true
            self.isShowingSuccess = false
            self.isShowingError = false
            self.resetUI()
            self.backgroundView.isHidden = true
            self.cardView.isHidden = true
            self.bubbleView.isHidden = false
            self.bubbleView.alpha = 0
            self.bubbleView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            self.isHidden = false
            UIView.animate(withDuration: 0.3) {
                self.alpha = 1
                self.bubbleView.alpha = 1
                self.bubbleView.transform = .identity
            }
        }
    }

    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3, animations: {
                self.alpha = 0
            }, completion: { _ in
                self.isHidden = true
                self.isMinimized = false
                self.isShowingSuccess = false
                self.isShowingError = false
                self.bubbleView.isHidden = true
                self.backgroundView.isHidden = false
                self.cardView.isHidden = false
                self.backgroundView.alpha = 1
                self.cardView.alpha = 1
                self.cardView.transform = .identity
            })
        }
    }
    
    /// Dismiss overlay and ensure it's not visible (reset to safe state)
    func dismissCompletely() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isHidden = true
            self.alpha = 0
            self.isMinimized = false
            self.isShowingSuccess = false
            self.isShowingError = false
            self.bubbleView.isHidden = true
            self.backgroundView.isHidden = true
            self.cardView.isHidden = true
        }
    }

    func updateDownloadProgress(progress: Double, speed: Double, downloadedMB: Double, totalMB: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentProgress = Float(progress)
            self.currentStatusText = "Tải AI"
            self.isShowingSuccess = false
            self.isShowingError = false  // Clear error flag when progress resumes

            // Auto-minimize if expanded
            if !self.isMinimized {
                self.animateToMinimized()
            }

            self.statusLabel.text = "Đang tải mô hình AI..."
            self.statusLabel.textColor = .gray
            self.progressView.isHidden = false
            self.progressView.progress = Float(progress)
            self.percentageLabel.isHidden = false
            self.percentageLabel.text = "\(Int(progress * 100))%"
            self.speedLabel.isHidden = false
            self.speedLabel.text = String(format: "%.1f MB/s • %.0f/%.0f MB", speed, downloadedMB, totalMB)
            self.cancelButton.isHidden = false
            self.retryButton.isHidden = true
            self.checkmarkLabel.isHidden = true
            self.loadingIndicator.stopAnimating()
            self.minimizeButton.isHidden = false

            if self.isMinimized { self.syncBubbleState() }
        }
    }

    func updateUnzipProgress(progress: Double) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.currentProgress = Float(progress)
            self.currentStatusText = "Giải nén"
            self.isShowingSuccess = false
            self.isShowingError = false  // Clear error flag when progress resumes

            // Auto-minimize if expanded
            if !self.isMinimized {
                self.animateToMinimized()
            }

            self.statusLabel.text = "Đang giải nén..."
            self.statusLabel.textColor = .gray
            self.progressView.isHidden = false
            self.progressView.progress = Float(progress)
            self.percentageLabel.isHidden = false
            self.percentageLabel.text = "\(Int(progress * 100))%"
            self.speedLabel.isHidden = true
            self.cancelButton.isHidden = true
            self.retryButton.isHidden = true
            self.checkmarkLabel.isHidden = true
            self.loadingIndicator.stopAnimating()
            self.minimizeButton.isHidden = false

            if self.isMinimized { self.syncBubbleState() }
        }
    }

    func updateLoadingModels(current: Int, total: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            let fraction = Float(current) / Float(max(total, 1))
            self.currentProgress = fraction
            self.currentStatusText = "Nạp AI"
            self.isShowingSuccess = false
            self.isShowingError = false  // Clear error flag when progress resumes

            // Auto-minimize if expanded
            if !self.isMinimized {
                self.animateToMinimized()
            }

            self.statusLabel.text = "Đang nạp mô hình... (\(current)/\(total))"
            self.statusLabel.textColor = .gray
            self.progressView.isHidden = false
            self.progressView.progress = fraction
            self.percentageLabel.isHidden = false
            self.percentageLabel.text = "\(Int(fraction * 100))%"
            self.speedLabel.isHidden = true
            self.cancelButton.isHidden = true
            self.retryButton.isHidden = true
            self.checkmarkLabel.isHidden = true
            self.loadingIndicator.startAnimating()
            self.minimizeButton.isHidden = false

            if self.isMinimized { self.syncBubbleState() }
        }
    }

    func showSuccess() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isShowingSuccess = true
            self.currentProgress = 1.0

            // Force expand to show checkmark (unless already expanded)
            if self.isMinimized {
                self.animateToExpanded()
            }

            self.statusLabel.isHidden = true
            self.progressView.isHidden = true
            self.percentageLabel.isHidden = true
            self.speedLabel.isHidden = true
            self.cancelButton.isHidden = true
            self.retryButton.isHidden = true
            self.loadingIndicator.stopAnimating()
            self.minimizeButton.isHidden = true
            self.checkmarkLabel.isHidden = false

            // Also update bubble state for minimized transition
            self.syncBubbleState()

            DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
                self?.dismiss()
            }
        }
    }

    func showError(message: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isShowingError = true

            // Force expanded for errors
            if self.isMinimized {
                self.animateToExpanded()
            }

            self.statusLabel.text = message
            self.statusLabel.textColor = .red
            self.statusLabel.isHidden = false
            self.progressView.isHidden = true
            self.percentageLabel.isHidden = true
            self.speedLabel.isHidden = true
            self.cancelButton.isHidden = true
            self.retryButton.isHidden = false
            self.checkmarkLabel.isHidden = true
            self.loadingIndicator.stopAnimating()
            self.minimizeButton.isHidden = true
        }
    }

    // MARK: - Private

    private func resetUI() {
        statusLabel.text = "Đang tải..."
        statusLabel.textColor = .gray
        statusLabel.isHidden = false
        progressView.progress = 0
        progressView.isHidden = false
        percentageLabel.text = "0%"
        percentageLabel.isHidden = false
        speedLabel.text = "0 MB/s"
        speedLabel.isHidden = false
        cancelButton.isHidden = false
        retryButton.isHidden = true
        checkmarkLabel.isHidden = true
        minimizeButton.isHidden = false
        loadingIndicator.stopAnimating()
        currentProgress = 0
        currentStatusText = "Đang tải"
        bubbleProgressView.isHidden = false
        bubbleStatusLabel.text = "Đang tải"
        bubblePercentLabel.text = "0%"
        bubbleProgressView.progress = 0
    }
}

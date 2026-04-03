import UIKit

// MARK: - Design Tokens

enum AppColors {
    // Primary
    static let primary = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.54, green: 0.71, blue: 0.97, alpha: 1.0)  // #8AB4F8
            : UIColor(red: 0.10, green: 0.45, blue: 0.91, alpha: 1.0)  // #1A73E8
    }
    static let onPrimary = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.0, green: 0.2, blue: 0.5, alpha: 1.0)
            : UIColor.white
    }
    static let primaryContainer = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.0, green: 0.3, blue: 0.6, alpha: 1.0)
            : UIColor(red: 0.85, green: 0.92, blue: 1.0, alpha: 1.0)  // #D9EBFF
    }

    // Surface
    static let surface = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0) // #1E1E1E
            : UIColor.white
    }
    static let surfaceVariant = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.0) // #2D2D2D
            : UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0) // #F5F5F5
    }
    static let surfaceContainer = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
            : UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
    }

    // Text
    static let onSurface = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.90, green: 0.88, blue: 0.90, alpha: 1.0) // #E6E1E5
            : UIColor(red: 0.11, green: 0.11, blue: 0.12, alpha: 1.0) // #1C1B1F
    }
    static let onSurfaceVariant = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.77, green: 0.75, blue: 0.79, alpha: 1.0)
            : UIColor(red: 0.29, green: 0.27, blue: 0.31, alpha: 1.0) // #49454F
    }

    // Outline
    static let outline = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.38, green: 0.36, blue: 0.40, alpha: 1.0)
            : UIColor(red: 0.79, green: 0.77, blue: 0.82, alpha: 1.0) // #CAC4D0
    }
    static let outlineVariant = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.29, green: 0.27, blue: 0.31, alpha: 1.0)
            : UIColor(red: 0.89, green: 0.87, blue: 0.91, alpha: 1.0)
    }

    // Semantic
    static let error = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 1.0, green: 0.71, blue: 0.67, alpha: 1.0)  // #FFB4AB
            : UIColor(red: 0.73, green: 0.10, blue: 0.10, alpha: 1.0) // #BA1A1A
    }
    static let success = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.43, green: 0.84, blue: 0.55, alpha: 1.0)
            : UIColor(red: 0.0, green: 0.42, blue: 0.30, alpha: 1.0)
    }
    static let tertiary = UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.43, green: 0.84, blue: 0.55, alpha: 1.0) // #6DD58C
            : UIColor(red: 0.0, green: 0.42, blue: 0.30, alpha: 1.0)  // #006C4C
    }

    // Penalty severity
    static let penaltyLow = UIColor(red: 0.13, green: 0.59, blue: 0.95, alpha: 1.0)
    static let penaltyMedium = UIColor(red: 1.0, green: 0.65, blue: 0.0, alpha: 1.0)
    static let penaltyHigh = UIColor(red: 0.96, green: 0.26, blue: 0.21, alpha: 1.0)

    // Gradient
    static let gradientStart = UIColor(red: 0.10, green: 0.45, blue: 0.91, alpha: 1.0)
    static let gradientEnd = UIColor(red: 0.25, green: 0.32, blue: 0.71, alpha: 1.0)
}

enum AppTypography {
    static let displayLarge = UIFont.systemFont(ofSize: 28, weight: .bold)
    static let displayMedium = UIFont.systemFont(ofSize: 24, weight: .bold)
    static let titleLarge = UIFont.systemFont(ofSize: 20, weight: .semibold)
    static let titleMedium = UIFont.systemFont(ofSize: 17, weight: .semibold)
    static let titleSmall = UIFont.systemFont(ofSize: 15, weight: .semibold)
    static let bodyLarge = UIFont.systemFont(ofSize: 16, weight: .regular)
    static let bodyMedium = UIFont.systemFont(ofSize: 14, weight: .regular)
    static let bodySmall = UIFont.systemFont(ofSize: 12, weight: .regular)
    static let labelLarge = UIFont.systemFont(ofSize: 14, weight: .medium)
    static let labelMedium = UIFont.systemFont(ofSize: 12, weight: .medium)
    static let labelSmall = UIFont.systemFont(ofSize: 11, weight: .medium)
    static let caption = UIFont.systemFont(ofSize: 11, weight: .regular)
}

enum AppSpacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

enum AppRadius {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let full: CGFloat = 9999
}

enum AppShadow {
    static func light(for layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.06
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 8
        layer.masksToBounds = false
    }

    static func medium(for layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.10
        layer.shadowOffset = CGSize(width: 0, height: 4)
        layer.shadowRadius = 12
        layer.masksToBounds = false
    }

    static func elevated(for layer: CALayer) {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 16
        layer.masksToBounds = false
    }
}

// MARK: - Theme Application

enum AppTheme {
    static func apply() {
        // Navigation Bar
        let navAppearance = UINavigationBarAppearance()
        navAppearance.configureWithOpaqueBackground()
        navAppearance.backgroundColor = AppColors.surface
        navAppearance.titleTextAttributes = [
            .foregroundColor: AppColors.onSurface,
            .font: AppTypography.titleMedium
        ]
        navAppearance.largeTitleTextAttributes = [
            .foregroundColor: AppColors.onSurface,
            .font: AppTypography.displayMedium
        ]
        navAppearance.shadowColor = .clear

        UINavigationBar.appearance().standardAppearance = navAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navAppearance
        UINavigationBar.appearance().compactAppearance = navAppearance
        UINavigationBar.appearance().tintColor = AppColors.primary

        // Tab Bar
        let tabAppearance = UITabBarAppearance()
        tabAppearance.configureWithOpaqueBackground()
        tabAppearance.backgroundColor = AppColors.surface
        tabAppearance.shadowColor = AppColors.outlineVariant
        UITabBar.appearance().standardAppearance = tabAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabAppearance
        }
        UITabBar.appearance().tintColor = AppColors.primary
        UITabBar.appearance().unselectedItemTintColor = AppColors.onSurfaceVariant

        // Table View
        UITableView.appearance().backgroundColor = AppColors.surfaceVariant
        UITableView.appearance().separatorStyle = .none
        UITableViewCell.appearance().backgroundColor = .clear

        // Search Bar
        UISearchBar.appearance().tintColor = AppColors.primary

        // Switch
        UISwitch.appearance().onTintColor = AppColors.primary
    }

    static func styleViewController(_ vc: UIViewController) {
        vc.view.backgroundColor = AppColors.surfaceVariant
    }
}

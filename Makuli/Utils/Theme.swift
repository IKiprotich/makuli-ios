//
//  Theme.swift
//  Makuli
//

import SwiftUI

// MARK: - Colours

enum AppColors {
    // Brand
    static let primaryOrange = Color("PrimaryOrange")
    static let successGreen  = Color("SuccessGreen")
    static let warnRed       = Color("WarnRed")

    // Static (light-mode only — use sparingly)
    static let bgCream      = Color("BackgroundCream")
    static let textCharcoal = Color("TextCharcoal")
    static let warmsand     = Color("WarmSand")

    // Adaptive — prefer these throughout the app
    static var background: Color {
        Color(UIColor { tc in
            tc.userInterfaceStyle == .dark ? .systemBackground : UIColor(bgCream)
        })
    }

    static var surface: Color {
        Color(UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : .white
        })
    }

    static var card: Color {
        Color(UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor.secondarySystemBackground : .white
        })
    }

    static var text: Color {
        Color(UIColor { tc in
            tc.userInterfaceStyle == .dark ? .label : UIColor(textCharcoal)
        })
    }

    static var textSecondary: Color {
        Color(UIColor { tc in
            tc.userInterfaceStyle == .dark ? .secondaryLabel : UIColor(textCharcoal).withAlphaComponent(0.6)
        })
    }

    static var border: Color {
        Color(UIColor { tc in
            tc.userInterfaceStyle == .dark ? UIColor.separator : UIColor.systemGray4
        })
    }
}

// MARK: - Typography

enum AppFonts {
    static func largeTitle() -> Font { .system(size: 34, weight: .bold,     design: .rounded) }
    static func title()      -> Font { .system(size: 28, weight: .bold,     design: .rounded) }
    static func title2()     -> Font { .system(size: 22, weight: .semibold, design: .rounded) }
    static func headline()   -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
    static func body()       -> Font { .system(size: 16, weight: .regular,  design: .rounded) }
    static func subheadline()-> Font { .system(size: 15, weight: .medium,   design: .rounded) }
    static func caption()    -> Font { .system(size: 13, weight: .regular,  design: .rounded) }
}

// MARK: - Reusable Modifiers

extension View {
    /// Full-width orange primary button style.
    func primaryButtonStyle() -> some View {
        self
            .font(AppFonts.headline())
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.primaryOrange)
            .foregroundColor(.white)
            .cornerRadius(12)
    }

    /// Outlined secondary button style.
    func secondaryButtonStyle() -> some View {
        self
            .font(AppFonts.headline())
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.primaryOrange.opacity(0.1))
            .foregroundColor(AppColors.primaryOrange)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.primaryOrange.opacity(0.3), lineWidth: 1))
    }
}

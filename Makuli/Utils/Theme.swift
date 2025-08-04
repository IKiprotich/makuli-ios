//
//  Theme.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//


import SwiftUI

enum AppColors {
    // Primary colors
    static let primaryOrange  = Color("PrimaryOrange")
    static let successGreen   = Color("SuccessGreen")
    static let warnRed        = Color("WarnRed")
    
    // Light mode colors
    static let bgCream        = Color("BackgroundCream")
    static let textCharcoal   = Color("TextCharcoal")
    static let warmsand       = Color("WarmSand")
    
    // Dark mode colors
    static let darkBackground = Color.black
    static let darkSurface    = Color(red: 0.08, green: 0.08, blue: 0.08)
    static let darkCard       = Color(red: 0.12, green: 0.12, blue: 0.12)
    static let darkText       = primaryOrange
    static let darkTextSecondary = primaryOrange.opacity(0.8)
    static let darkBorder     = Color(red: 0.2, green: 0.2, blue: 0.2)
    
    // Dynamic colors that adapt to light/dark mode
    static var background: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(darkBackground) : UIColor(bgCream)
        })
    }
    
    static var surface: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(darkSurface) : UIColor.white
        })
    }
    
    static var card: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(darkCard) : UIColor.white
        })
    }
    
    static var text: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(darkText) : UIColor(textCharcoal)
        })
    }
    
    static var textSecondary: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(darkTextSecondary) : UIColor(textCharcoal).withAlphaComponent(0.7)
        })
    }
    
    static var border: Color {
        Color(UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? 
                UIColor(darkBorder) : UIColor.gray.withAlphaComponent(0.2)
        })
    }
    
    // Helper method to get colors based on current color scheme
    static func getBackground(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? darkBackground : bgCream
    }
    
    static func getSurface(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? darkSurface : Color.white
    }
    
    static func getCard(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? darkCard : Color.white
    }
    
    static func getText(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? primaryOrange : textCharcoal
    }
    
    static func getTextSecondary(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? primaryOrange.opacity(0.8) : textCharcoal.opacity(0.7)
    }
    
    static func getBorder(for colorScheme: ColorScheme) -> Color {
        return colorScheme == .dark ? darkBorder : Color.gray.opacity(0.2)
    }
}

enum AppFonts {
    
    static func title2() -> Font { .system(size: 24, weight: .bold, design: .rounded) }
    static func headline() -> Font { .system(size: 17, weight: .semibold, design: .rounded) }
    static func body() -> Font { .system(size: 16, weight: .regular, design: .rounded) }
    static func caption() -> Font { .system(size: 13, weight: .regular, design: .rounded) }
}

extension View {
    func primaryButtonStyle() -> some View {
        self
            .font(AppFonts.headline())
            .padding()
            .frame(maxWidth: .infinity)
            .background(AppColors.primaryOrange)
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

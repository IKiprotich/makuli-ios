//
//  Theme.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//


import SwiftUI

enum AppColors {
    static let primaryOrange  = Color("PrimaryOrange")
    static let successGreen   = Color("SuccessGreen")
    static let warnRed        = Color("WarnRed")
    static let bgCream        = Color("BackgroundCream")
    static let textCharcoal   = Color("TextCharcoal")
    static let warmsand       = Color("WarmSand")
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

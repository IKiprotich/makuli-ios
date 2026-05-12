//
//  MakuliApp.swift
//  Makuli
//

import SwiftUI

@main
struct MakuliApp: App {
    @StateObject private var themeManager = ThemeManager.shared

    var body: some Scene {
        WindowGroup {
            MainAppView()
                .preferredColorScheme(themeManager.colorScheme)
                .environmentObject(themeManager)
        }
    }
}

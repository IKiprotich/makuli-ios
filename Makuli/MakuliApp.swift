//
//  MakuliApp.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
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

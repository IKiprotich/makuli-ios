//  BuildplateApp.swift
//  Buildplate
//
//  Created by ian on 2025-01-03.
//

import SwiftUI

@main
struct BuildplateApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some Scene {
        WindowGroup {
            MainAppView()
                .preferredColorScheme(themeManager.colorScheme)
                .environmentObject(themeManager)
        }
    }
}

//
//  ThemeManager.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Theme manager for handling dark mode toggle and persistence.
//

import SwiftUI

@MainActor
class ThemeManager: ObservableObject {
    static let shared = ThemeManager()
    
    @Published var isDarkMode: Bool {
        didSet {
            UserDefaults.standard.set(isDarkMode, forKey: "isDarkMode")
            colorScheme = isDarkMode ? .dark : .light
        }
    }
    
    @Published var colorScheme: ColorScheme {
        didSet {
            UserDefaults.standard.set(colorScheme == .dark, forKey: "isDarkMode")
            // Only update isDarkMode if it's different to avoid infinite loop
            if isDarkMode != (colorScheme == .dark) {
                isDarkMode = colorScheme == .dark
            }
        }
    }
    
    private init() {
        // Load saved preference or default to dark mode
        let savedDarkMode = UserDefaults.standard.object(forKey: "isDarkMode") as? Bool ?? true
        self.isDarkMode = savedDarkMode
        self.colorScheme = savedDarkMode ? .dark : .light
    }
    
    func toggleDarkMode() {
        isDarkMode.toggle()
    }
    
    func setDarkMode(_ isDark: Bool) {
        isDarkMode = isDark
    }
} 
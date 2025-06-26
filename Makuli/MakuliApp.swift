//
//  MakuliApp.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

@main
struct MakuliApp: App {
    
    init() {
        _ = SupabaseManager.shared
        print("✅ Supabase initialized")
    }

    var body: some Scene {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        WindowGroup {
            if hasCompletedOnboarding {
                AppTabView()
            } else {
                OnboardingView()
            }
        }
    }
}

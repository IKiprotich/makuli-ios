//
//  MainAppView.swift
//  Makuli
//
//  Created by Ian   on 27/06/2025.
//

import SwiftUI

struct MainAppView: View {
    @EnvironmentObject var authManager: AuthManager
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some View {
        Group {
            if hasCompletedOnboarding {
                // User has completed onboarding, show main app
                AppTabView()
                    .environmentObject(authManager)
            } else {
                // User needs to complete onboarding first
                OnboardingView()
                    .environmentObject(authManager)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .onboardingCompleted)) { _ in
            hasCompletedOnboarding = true
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}

// MARK: - Preview
struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
            .environmentObject(AuthManager())
    }
} 
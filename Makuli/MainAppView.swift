//
//  MainAppView.swift
//  Makuli
//
//  Created by Ian   on 27/06/2025.
//

import SwiftUI

struct MainAppView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        Group {
            if authViewModel.user == nil {
                // User not logged in - show auth view
                AuthView()
                    .onAppear {
                        Logger.info("Showing AuthView - no user logged in")
                    }
            } else if authViewModel.user?.isOnboardingCompleted == false {
                // User logged in but onboarding not completed - show onboarding
                OnboardingView()
                    .onAppear {
                        Logger.info("Showing OnboardingView - user needs to complete onboarding")
                    }
            } else {
                // User logged in and onboarding completed - show main app
                AppTabView()
                    .onAppear {
                        Logger.info("Showing AppTabView - user fully authenticated and onboarded")
                    }
            }
        }
        .environmentObject(authViewModel)
        .onChange(of: authViewModel.user?.isOnboardingCompleted) { _, newValue in
            if let completed = newValue {
                Logger.debug("Onboarding status changed: \(completed)")
            }
        }
    }
}

// MARK: - Preview
struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
} 


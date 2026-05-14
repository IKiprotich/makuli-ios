//
//  MainAppView.swift
//  Makuli
//
//  Created by Ian on 2025-06-27.
//

import SwiftUI

struct MainAppView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Group {
            if authViewModel.user == nil {
                AuthView()
                    .onAppear {
                        Logger.info("Showing AuthView - no user logged in")
                    }
            } else if authViewModel.user?.isOnboardingCompleted == false {
                OnboardingView()
                    .onAppear {
                        Logger.info("Showing OnboardingView - user needs to complete onboarding")
                    }
            } else {
                AppTabView()
                    .onAppear {
                        Logger.info("Showing AppTabView - user fully authenticated and onboarded")
                    }
            }
        }
        .environmentObject(authViewModel)
        .environmentObject(themeManager)
        .onChange(of: authViewModel.user?.isOnboardingCompleted) { newValue in
            if let completed = newValue {
                Logger.debug("Onboarding status changed: \(completed)")
            }
        }
    }
}

struct MainAppView_Previews: PreviewProvider {
    static var previews: some View {
        MainAppView()
    }
}


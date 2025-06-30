//
//  OnboardingViewModel.swift
//  Makuli
//
//  Created by Ian   on 30/06/2025.
//

import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var isCompleting = false
    
    func completeOnboarding(
        age: Int,
        gender: String,
        diet: String,
        budget: String,
        authViewModel: AuthViewModel
    ) async {
        guard !isCompleting else {
            Logger.warning("Onboarding completion already in progress - ignoring duplicate request")
            return
        }
        
        isCompleting = true
        Logger.debug("OnboardingViewModel: Starting completion process")
        
        // Call the AuthViewModel which will call AuthManager
        await authViewModel.completeOnboarding(
            age: age,
            gender: gender,
            diet: diet,
            budget: budget
        )
        
        isCompleting = false
        Logger.debug("OnboardingViewModel: Completion process finished")
        
        // Check final state without exposing user data
        if let user = authViewModel.user {
            Logger.debug("Final user state: isOnboardingCompleted = \(user.isOnboardingCompleted)")
        } else {
            Logger.warning("No user found after onboarding completion")
        }
    }
} 
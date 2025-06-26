//
//  OnboardingView.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//


import SwiftUI

struct OnboardingView: View {
    @StateObject private var onboardingData = OnboardingData()
    @State private var currentPage = 0
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    private let totalPages = 7
    
    var body: some View {
        NavigationView {
            TabView(selection: $currentPage) {
                SplashScreenView(currentPage: $currentPage)
                    .tag(0)
                
                AgeInputView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(1)
                
                GenderSelectionView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(2)
                
                GoalSelectionView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(3)
                
                BudgetInputView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(4)
                
                DietPreferenceView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(5)
                
                StartPlanView(
                    onboardingData: onboardingData,
                    hasCompletedOnboarding: $hasCompletedOnboarding
                )
                .tag(6)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    OnboardingView()
}

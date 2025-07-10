//
//  OnboardingView.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//


import SwiftUI

struct OnboardingView: View {
    @StateObject private var onboardingData = OnboardingData()
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @State private var currentPage = 0
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private let totalPages = 7
    
    var body: some View {
        NavigationView {
            TabView(selection: $currentPage) {
                SplashScreenView()
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
                    onboardingViewModel: onboardingViewModel,
                    authViewModel: authViewModel
                )
                .tag(6)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            Logger.debug("OnboardingView appeared - User needs to complete onboarding")
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AuthViewModel())
}

//
//  OnboardingView.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//


import SwiftUI

struct OnboardingView: View {
    @StateObject private var onboardingData: OnboardingData
    @StateObject private var onboardingViewModel = OnboardingViewModel()
    @State private var currentPage = 0
    @EnvironmentObject var authViewModel: AuthViewModel
    
    private let totalPages = 14 // Decremented by 1 since cuisine step is removed
    
    init() {
        // Initialize with default values for onboarding
        let defaultOnboardingData = OnboardingData(
            id: UUID().uuidString,
            userId: "",
            age: 0,
            gender: "",
            height: 0.0,
            weight: 0.0,
            activityLevel: "",
            fitnessGoal: "",
            dietaryPreferences: [],
            budgetRange: "",
            preferredCuisines: [],
            cookingSkillLevel: "",
            preferredPrepTime: 0,
            preferredServings: 0,
            allergies: [],
            favoriteIngredients: [],
            dislikedIngredients: [],
            includeMealPrep: false,
            includeShoppingList: false,
            includeNutritionInfo: false,
            rotateMeals: false,
            includeLeftovers: false,
            preferredComplexity: "",
            additionalNotes: nil,
            isCompleted: false,
            currentStep: 0,
            totalSteps: 7,
            createdAt: Date(),
            updatedAt: Date()
        )
        self._onboardingData = StateObject(wrappedValue: defaultOnboardingData)
    }
    
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
                AllergiesView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(6)
                DislikesView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(7)
                EnergyNeedsView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(8)
                WeightInputView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(9)
                HeightInputView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(10)
                CookingSkillView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(11)
                PantryStatusView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(12)
                AvatarSelectionView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage
                )
                .tag(13)
                PlanSummaryView(
                    onboardingData: onboardingData,
                    onboardingViewModel: onboardingViewModel,
                    authViewModel: authViewModel
                )
                .tag(14)
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

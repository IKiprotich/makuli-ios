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
    
    private let totalPages = 13 // Decremented by 1 since splash screen is removed
    
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
                AgeInputView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(0)
                GenderSelectionView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(1)
                GoalSelectionView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(2)
                BudgetInputView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(3)
                DietPreferenceView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(4)
                AllergiesView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(5)
                DislikesView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(6)
                EnergyNeedsView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(7)
                WeightInputView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(8)
                HeightInputView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(9)
                CookingSkillView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(10)
                PantryStatusView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(11)
                AvatarSelectionView(
                    onboardingData: onboardingData,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(12)
                PlanSummaryView(
                    onboardingData: onboardingData,
                    onboardingViewModel: onboardingViewModel,
                    authViewModel: authViewModel,
                    currentPage: $currentPage,
                    totalPages: totalPages
                )
                .tag(13)
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

//
//  StartPlanView.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import SwiftUI

struct StartPlanView: View {
    @ObservedObject var onboardingData: OnboardingData
    @ObservedObject var onboardingViewModel: OnboardingViewModel
    let authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            AppColors.bgCream
            
            VStack(spacing: 40) {
                // Progress indicator
                ProgressView(value: 7, total: 7)
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.primaryOrange)
                
                VStack(spacing: 20) {
                    Text("You're all set!")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(AppColors.textCharcoal)
                        .multilineTextAlignment(.center)
                    
                    Text("Your personalized meal plan is ready")
                        .font(.title3)
                        .foregroundColor(AppColors.textCharcoal.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Summary card
                VStack(alignment: .leading, spacing: 15) {
                    Text("Your Profile")
                        .font(.headline)
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Group {
                        HStack {
                            Text("Age:")
                                .fontWeight(.medium)
                            Spacer()
                            Text("\(onboardingData.age) years")
                        }
                        HStack {
                            Text("Gender:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(onboardingData.gender)
                        }
                        HStack {
                            Text("Goal:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(onboardingData.fitnessGoal)
                        }
                        HStack {
                            Text("Budget:")
                                .fontWeight(.medium)
                            Spacer()
                            Text(onboardingData.budgetRange)
                        }
                    }
                    .foregroundColor(AppColors.textCharcoal)
                    
                    if !onboardingData.dietaryPreferences.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Diet Preferences:")
                                .fontWeight(.medium)
                                .foregroundColor(AppColors.textCharcoal)
                            
                            Text(onboardingData.dietaryPreferences.joined(separator: ", "))
                                .foregroundColor(AppColors.textCharcoal.opacity(0.8))
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.95))
                .cornerRadius(12)
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    Task {
                        await onboardingViewModel.completeOnboarding(authViewModel: authViewModel)
                    }
                }) {
                    HStack {
                        if onboardingViewModel.isCompleting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(onboardingViewModel.isCompleting ? "Setting up..." : "Start My Meal Plan")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(AppColors.primaryOrange)
                    .cornerRadius(12)
                }
                .disabled(onboardingViewModel.isCompleting)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    StartPlanView(
        onboardingData: OnboardingData(
            id: "preview-id",
            userId: "preview-user",
            age: 25,
            gender: "Other",
            height: 170.0,
            weight: 70.0,
            activityLevel: "Moderately Active",
            fitnessGoal: "Maintain Weight",
            dietaryPreferences: [],
            budgetRange: "Medium",
            preferredCuisines: [],
            cookingSkillLevel: "Beginner",
            preferredPrepTime: 30,
            preferredServings: 2,
            allergies: [],
            favoriteIngredients: [],
            dislikedIngredients: [],
            includeMealPrep: true,
            includeShoppingList: true,
            includeNutritionInfo: true,
            rotateMeals: true,
            includeLeftovers: false,
            preferredComplexity: "Easy",
            additionalNotes: nil,
            isCompleted: false,
            currentStep: 1,
            totalSteps: 7,
            createdAt: Date(),
            updatedAt: Date()
        ),
        onboardingViewModel: OnboardingViewModel(),
        authViewModel: AuthViewModel()
    )
}

//
//  BudgetInputView.swift
//  Makuli
//
//  Created by Ian on 2025-06-26.
//

import SwiftUI

struct BudgetInputView: View {
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    let totalPages: Int
    
    private let budgetOptions = [
        ("$50 - $100", "Budget-friendly meals", "dollarsign.circle.fill"),
        ("$100 - $200", "Balanced nutrition", "dollarsign.circle.fill"),
        ("$200 - $300", "Premium ingredients", "dollarsign.circle.fill"),
        ("$300+", "Gourmet experience", "dollarsign.circle.fill")
    ]
    
    var body: some View {
        ZStack {
            AppColors.background
            
            VStack(spacing: 30) {
                ProgressView(value: Double(currentPage), total: Double(totalPages))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                VStack(spacing: 16) {
                    Text("What's your weekly food budget?")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("We'll suggest meals that fit your budget")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                
                VStack(spacing: 15) {
                    ForEach(budgetOptions, id: \.0) { option in
                        let isSelected = onboardingData.budgetRange == option.0
                        
                        Button(action: {
                            onboardingData.budgetRange = option.0
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: option.2)
                                    .font(.title2)
                                    .foregroundColor(isSelected ? .white : AppColors.successGreen)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(option.0)
                                        .font(.headline)
                                        .foregroundColor(isSelected ? .white : AppColors.text)
                                    
                                    Text(option.1)
                                        .font(.caption)
                                        .foregroundColor(isSelected
                                            ? .white.opacity(0.85)
                                            : AppColors.textSecondary)
                                }
                                
                                Spacer()
                                
                                if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.white)
                                }
                            }
                            .padding()
                            .background(isSelected ? AppColors.primaryOrange : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(
                                        isSelected ? Color.clear : Color.gray.opacity(0.25),
                                        lineWidth: 1
                                    )
                            )
                            .shadow(color: Color.black.opacity(0.02), radius: 1, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                Button(action: {
                    if !onboardingData.budgetRange.isEmpty {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentPage += 1
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            onboardingData.budgetRange.isEmpty
                            ? Color.gray.opacity(0.5)
                            : AppColors.primaryOrange
                        )
                        .cornerRadius(12)
                }
                .disabled(onboardingData.budgetRange.isEmpty)
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BudgetInputView(
        onboardingData: OnboardingData(
            id: "id",
            userId: "userId",
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
        currentPage: .constant(2),
        totalPages: 7
    )
}

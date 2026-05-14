//
//  AgeInputView.swift
//  Makuli
//
//  Created by Ian on 2025-06-25.
//

import SwiftUI

struct AgeInputView: View {
    
    @ObservedObject var onboardingData: OnboardingData
    @Binding var currentPage: Int
    let totalPages: Int
    @State private var selectedAge: Int = 25
    
    
    var body: some View {
        ZStack {
            AppColors.background
            
            VStack(spacing: 30) {
                
                ProgressView(value: Double(currentPage), total: Double(totalPages))
                    .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
                    .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Text("Age")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(AppColors.text)
                        .multilineTextAlignment(.center)
                    Text("Age is used to calculate your calories")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 24)
                Picker("Age", selection: $selectedAge) {
                    ForEach(10...100, id: \.self) { value in
                        Text("\(value)").tag(value)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 120)
                
                
                Spacer()
                
                
                Button(action: {
                    onboardingData.age = selectedAge
                    currentPage += 1
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primaryOrange)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
                
            }
        }
        .ignoresSafeArea()
        .onAppear {
            selectedAge = onboardingData.age > 0 ? onboardingData.age : 25
        }
    }
}

#Preview {
    AgeInputView(
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
        currentPage: .constant(1),
        totalPages: 7
    )
}

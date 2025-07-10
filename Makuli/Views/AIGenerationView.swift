//
//  AIGenerationView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  AI meal plan generation view.
//

import SwiftUI

struct AIGenerationView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var planViewModel = PlanViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var weekStartDate = Date()
    @State private var selectedGoals: [String] = []
    @State private var selectedBudget = "medium"
    @State private var selectedDietaryRestrictions: [String] = []
    @State private var cookingTime = "30-45 minutes"
    @State private var difficulty = "intermediate"
    @State private var servings = 2
    @State private var isGenerating = false
    
    let budgetOptions = ["low", "medium", "high", "premium"]
    let cookingTimeOptions = ["15-30 minutes", "30-45 minutes", "45-60 minutes", "60+ minutes"]
    let difficultyOptions = ["beginner", "intermediate", "advanced"]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    
                    preferencesSection
                    
                    generateButton
                }
                .padding()
            }
            .navigationTitle("AI Meal Plan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .task {
                if let user = authViewModel.user {
                    await profileViewModel.fetchProfile(for: user.id)
                    loadUserPreferences()
                }
            }
            .alert("Error", isPresented: .constant(planViewModel.errorMessage != nil)) {
                Button("OK") {
                    planViewModel.clearError()
                }
            } message: {
                if let errorMessage = planViewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .alert("Success", isPresented: .constant(planViewModel.selectedPlan != nil && !isGenerating)) {
                Button("View Plan") {
                    dismiss()
                }
                Button("Generate Another") {
                    planViewModel.selectedPlan = nil
                }
            } message: {
                Text("Your AI meal plan has been generated successfully!")
            }
        }
    }
}

extension AIGenerationView {
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 50))
                .foregroundColor(AppColors.primaryOrange)
            
            Text("AI Meal Plan Generator")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Let AI create a personalized meal plan based on your preferences")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // Show usage limits if applicable
            if let profile = profileViewModel.profile, !profile.hasPremiumAccess {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                    
                    Text("You have \(profile.aiGenerationsRemainingThisMonth) AI generations remaining this month")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                }
                .padding()
                .background(AppColors.bgCream)
                .cornerRadius(8)
            }
        }
    }
    
    private var preferencesSection: some View {
        VStack(spacing: 20) {
            // Week Start Date
            VStack(alignment: .leading, spacing: 8) {
                Text("Week Starting")
                    .font(.headline)
                
                DatePicker(
                    "Week Start Date",
                    selection: $weekStartDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .padding()
                .background(AppColors.bgCream)
                .cornerRadius(12)
            }
            
            // Budget
            VStack(alignment: .leading, spacing: 8) {
                Text("Budget")
                    .font(.headline)
                
                Picker("Budget", selection: $selectedBudget) {
                    ForEach(budgetOptions, id: \.self) { budget in
                        Text(budget.capitalized).tag(budget)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Cooking Time
            VStack(alignment: .leading, spacing: 8) {
                Text("Cooking Time")
                    .font(.headline)
                
                Picker("Cooking Time", selection: $cookingTime) {
                    ForEach(cookingTimeOptions, id: \.self) { time in
                        Text(time).tag(time)
                    }
                }
                .pickerStyle(.menu)
                .padding()
                .background(AppColors.bgCream)
                .cornerRadius(12)
            }
            
            // Difficulty
            VStack(alignment: .leading, spacing: 8) {
                Text("Difficulty Level")
                    .font(.headline)
                
                Picker("Difficulty", selection: $difficulty) {
                    ForEach(difficultyOptions, id: \.self) { level in
                        Text(level.capitalized).tag(level)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            // Servings
            VStack(alignment: .leading, spacing: 8) {
                Text("Servings")
                    .font(.headline)
                
                HStack {
                    Button("-") {
                        if servings > 1 {
                            servings -= 1
                        }
                    }
                    .frame(width: 40, height: 40)
                    .background(AppColors.bgCream)
                    .cornerRadius(8)
                    
                    Spacer()
                    
                    Text("\(servings)")
                        .font(.title2)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Button("+") {
                        if servings < 10 {
                            servings += 1
                        }
                    }
                    .frame(width: 40, height: 40)
                    .background(AppColors.bgCream)
                    .cornerRadius(8)
                }
                .padding()
                .background(AppColors.bgCream)
                .cornerRadius(12)
            }
        }
    }
    
    private var generateButton: some View {
        Button(action: generateAIPlan) {
            HStack {
                if isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(.white)
                } else {
                    Image(systemName: "wand.and.stars")
                }
                
                Text(isGenerating ? "Generating Plan..." : "Generate AI Plan")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(canGenerate ? AppColors.primaryOrange : Color.gray)
            .cornerRadius(12)
        }
        .disabled(!canGenerate || isGenerating)
    }
    
    private var canGenerate: Bool {
        guard let profile = profileViewModel.profile else { return false }
        return profile.canUseAIGeneration && profile.canCreateMorePlans
    }
    
    private func loadUserPreferences() {
        guard let profile = profileViewModel.profile else { return }
        
        // Pre-fill with user's profile preferences
        if let budget = profile.budget {
            selectedBudget = budget
        }
        
        if let goal = profile.goal {
            selectedGoals = [goal]
        }
        
        if let diet = profile.diet {
            selectedDietaryRestrictions = [diet]
        }
    }
    
    private func generateAIPlan() {
        guard let user = authViewModel.user,
              let profile = profileViewModel.profile else { return }
        
        isGenerating = true
        
        Task {
            let preferences = MealPlanPreferences(
                weekStartDate: weekStartDate,
                budget: selectedBudget,
                dietaryRestrictions: selectedDietaryRestrictions,
                goals: selectedGoals,
                excludedIngredients: []
            )
            
            let success = await planViewModel.generateAIMealPlan(
                for: profile,
                preferences: preferences
            )
            
            if success {
                await profileViewModel.incrementPlanCreationCount()
                await profileViewModel.incrementAIGenerationCount()
            }
            
            isGenerating = false
        }
    }
}

#Preview {
    AIGenerationView()
        .environmentObject(AuthViewModel())
} 
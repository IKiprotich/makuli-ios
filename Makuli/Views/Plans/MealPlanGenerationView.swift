//
//  MealPlanGenerationView.swift
//  Makuli
//
//  Created by Ian on 2025-01-03.
//
//  UI for AI-powered meal plan generation with customizable preferences.
//

import SwiftUI

struct MealPlanGenerationView: View {
    @StateObject private var planViewModel = PlanViewModel()
    @StateObject private var profileViewModel = UserProfileViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var preferences = MealPlanPreferences(
        weekStartDate: Calendar.current.startOfDay(for: Date()),
        budget: "Medium ($60-100)",
        dietaryRestrictions: [],
        goals: ["General Health"],
        excludedIngredients: []
    )
    
    @State private var showingPreferences = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        
                        switch planViewModel.generationState {
                        case .idle:
                            preferencesSection
                            generateButton
                            
                            // Show error message if any
                            if let errorMessage = planViewModel.errorMessage {
                                errorMessageView(errorMessage)
                            }
                            
                        case .generating:
                            generatingView
                            
                        case .saving:
                            savingView
                            
                        case .saved(let plan):
                            successView(plan)
                            
                        case .error(let message):
                            errorView(message)
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationTitle("Generate Meal Plan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingPreferences) {
                MealPlanPreferencesView(preferences: $preferences)
            }
            .task {
                await profileViewModel.fetchProfile()
            }
        }
    }
}

// MARK: - UI Components
extension MealPlanGenerationView {
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spoonacular Meal Planning")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)
            
            Text("Generate a personalized 7-day meal plan using Spoonacular's extensive recipe database, tailored to your dietary preferences and nutritional goals.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    private var preferencesSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Preferences")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                
                Spacer()
                
                Button("Customize") {
                    showingPreferences = true
                }
                .font(.caption)
                .foregroundColor(AppColors.primaryOrange)
            }
            
            VStack(spacing: 12) {
                preferenceRow(title: "Week Starting", value: formatDate(preferences.weekStartDate))
                preferenceRow(title: "Budget", value: preferences.budget)
                preferenceRow(title: "Dietary Restrictions", value: preferences.dietaryRestrictions.isEmpty ? "None" : preferences.dietaryRestrictions.joined(separator: ", "))
                preferenceRow(title: "Goals", value: preferences.goals.joined(separator: ", "))
                
                if !preferences.excludedIngredients.isEmpty {
                    preferenceRow(title: "Excluded Ingredients", value: preferences.excludedIngredients.joined(separator: ", "))
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
    }
    
    private func preferenceRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(AppColors.text)
                .multilineTextAlignment(.trailing)
        }
    }
    
    private var generateButton: some View {
        Button(action: generateMealPlan) {
            HStack {
                Image(systemName: "sparkles")
                Text("Generate My Meal Plan")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primaryOrange)
            .cornerRadius(12)
        }
        .disabled(profileViewModel.profile == nil)
    }
    
    private var generatingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.primaryOrange))
            
            Text("Generating your personalized meal plan...")
                .font(.headline)
                .foregroundColor(AppColors.text)
            
            Text("This may take a few moments while we search Spoonacular's recipe database and create a plan tailored to your preferences.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    

    
    private var savingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.2)
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.successGreen))
            
            Text("Saving your meal plan...")
                .font(.headline)
                .foregroundColor(AppColors.text)
            
            Text("Adding meals to your plan library and generating grocery lists.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func successView(_ plan: Makuli.Plan) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppColors.successGreen)
            
            Text("Spoonacular Plan Generated! 🎉")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)
            
            Text("Your personalized meal plan has been created using Spoonacular's recipe database and saved to your library.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 8) {
                Text("Plan Details:")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                
                Text("• \(plan.title)")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("• Generated using Spoonacular API")
                    .font(.body)
                    .foregroundColor(.secondary)
                
                Text("• Cached for offline access")
                    .font(.body)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(AppColors.successGreen.opacity(0.1))
            .cornerRadius(8)
            
            Button("View My Plans") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.primaryOrange)
            .cornerRadius(12)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func errorView(_ message: String) -> some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 50))
                .foregroundColor(AppColors.warnRed)
            
            Text("Generation Failed")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 12) {
                Button("Try Again") {
                    planViewModel.resetGenerationState()
                }
                .font(.headline)
                .foregroundColor(AppColors.primaryOrange)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primaryOrange, lineWidth: 1)
                )
                .cornerRadius(12)
                
                Button("Cancel") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.warnRed)
                .cornerRadius(12)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func errorMessageView(_ message: String) -> some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(AppColors.warnRed)
                
                Text("Error")
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                
                Spacer()
            }
            
            Text(message)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
            
            Button("Dismiss") {
                planViewModel.errorMessage = nil
            }
            .font(.caption)
            .foregroundColor(AppColors.primaryOrange)
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .background(AppColors.warnRed.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(AppColors.warnRed.opacity(0.3), lineWidth: 1)
        )
    }
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func generateMealPlan() {
        guard let profile = profileViewModel.profile else { 
            // Show error if no profile
            planViewModel.errorMessage = "Please complete your profile to generate a meal plan."
            return 
        }
        
        // Validate that user has sufficient preferences
        guard profile.hasValidSpoonacularPreferences else {
            planViewModel.errorMessage = "Please complete your dietary preferences in your profile to generate a meal plan."
            return
        }
        
        Task {
            let success = await planViewModel.generateSpoonacularMealPlan(
                for: profile,
                weekStart: preferences.weekStartDate
            )
            
            if success {
                // Plan was generated successfully, dismiss the view
                await MainActor.run {
                    dismiss()
                }
            }
        }
    }
    

}

#Preview {
    MealPlanGenerationView()
        .environmentObject(AuthViewModel())
} 

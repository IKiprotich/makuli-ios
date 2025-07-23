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
                AppColors.bgCream.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        
                        switch planViewModel.generationState {
                        case .idle:
                            preferencesSection
                            generateButton
                            
                        case .generating:
                            generatingView
                            
                        case .generated(let response):
                            generatedPlanPreview(response)
                            
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
            Text("AI-Powered Meal Planning")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textCharcoal)
            
                                    Text("Let our AI create a personalized 7-day meal plan based on your preferences, featuring delicious Western cuisine within your budget.")
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
                    .foregroundColor(AppColors.textCharcoal)
                
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
                .foregroundColor(AppColors.textCharcoal)
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
            
            Text("Creating your personalized meal plan...")
                .font(.headline)
                .foregroundColor(AppColors.textCharcoal)
            
                                    Text("This may take a few moments while our AI analyzes your preferences and selects the best Western dishes for you.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
    
    private func generatedPlanPreview(_ response: MealPlanGenerationResponse) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading) {
                    Text("✨ \(response.weekTitle)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textCharcoal)
                    
                                                Text("Estimated Cost: $\(Int(response.totalEstimatedCost))")
                        .font(.subheadline)
                        .foregroundColor(AppColors.primaryOrange)
                }
                
                Spacer()
            }
            
            // Show preview of first few meals
            LazyVStack(spacing: 12) {
                ForEach(response.meals.prefix(3), id: \.day) { dayPlan in
                    DayPlanPreviewCard(dayPlan: dayPlan)
                }
                
                if response.meals.count > 3 {
                    Text("+ \(response.meals.count - 3) more days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            
            HStack(spacing: 12) {
                Button("Regenerate") {
                    generateMealPlan()
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
                
                Button("Save Plan") {
                    saveMealPlan(response)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primaryOrange)
                .cornerRadius(12)
            }
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
                .foregroundColor(AppColors.textCharcoal)
            
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
            
            Text("Meal Plan Saved! 🎉")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textCharcoal)
            
            Text("Your personalized meal plan has been added to your library. You can view it in the Plans tab.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
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
                .foregroundColor(AppColors.textCharcoal)
            
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
    
    // MARK: - Helper Methods
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func generateMealPlan() {
        guard let profile = profileViewModel.profile else { return }
        
        Task {
            await planViewModel.generateAIMealPlanWithPreferences(
                for: profile,
                preferences: preferences
            )
        }
    }
    
    private func saveMealPlan(_ response: MealPlanGenerationResponse) {
        // Convert the AI response to a MealPlan and add to AI-generated plans
        let mealPlan = convertToMealPlan(from: response)
        planViewModel.addAIGeneratedPlan(mealPlan)
        // Optionally, show a success state or dismiss
        dismiss()
    }

    /// Helper to convert MealPlanGenerationResponse to MealPlan
    private func convertToMealPlan(from response: MealPlanGenerationResponse) -> MealPlan {
        // Generate a unique ID and planId for the new plan
        let id = UUID().uuidString
        let planId = id // Or use a different logic if needed
        // Convert the response's meals to the [String: [String: [Meal]]] format expected by MealPlan
        var mealsDict: [String: [String: [Meal]]] = [:]
        for dayPlan in response.meals {
            var mealTypes: [String: [Meal]] = [:]
            mealTypes["breakfast"] = [dayPlan.breakfast.toMeal(category: .breakfast)]
            mealTypes["lunch"] = [dayPlan.lunch.toMeal(category: .lunch)]
            mealTypes["dinner"] = [dayPlan.dinner.toMeal(category: .dinner)]
            mealsDict[dayPlan.day] = mealTypes
        }
        let now = Date()
        return MealPlan(id: id, planId: planId, meals: mealsDict, createdAt: now, updatedAt: now, isAIGenerated: true)
    }
}

// MARK: - Day Plan Preview Card
struct DayPlanPreviewCard: View {
    let dayPlan: DayMealPlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(dayPlan.day)
                .font(.headline)
                .foregroundColor(AppColors.textCharcoal)
            
            VStack(alignment: .leading, spacing: 4) {
                mealRow("🌅", dayPlan.breakfast.name, dayPlan.breakfast.cookingTime)
                mealRow("☀️", dayPlan.lunch.name, dayPlan.lunch.cookingTime)
                mealRow("🌙", dayPlan.dinner.name, dayPlan.dinner.cookingTime)
            }
        }
        .padding()
        .background(AppColors.warmsand.opacity(0.3))
        .cornerRadius(8)
    }
    
    private func mealRow(_ icon: String, _ name: String, _ time: Int) -> some View {
        HStack {
            Text(icon)
            Text(name)
                .font(.caption)
                .foregroundColor(AppColors.textCharcoal)
            Spacer()
            Text("\(time)min")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    MealPlanGenerationView()
        .environmentObject(AuthViewModel())
} 

//
//  MealPlanPreferencesView.swift
//  Makuli
//
//  Created by AI Assistant on 2025-01-03.
//
//  Customizable preferences view for Spoonacular meal plan generation.
//

import SwiftUI

struct MealPlanPreferencesView: View {
    @Binding var preferences: MealPlanPreferences
    @Environment(\.dismiss) private var dismiss
    
    @State private var weekStartDate: Date
    @State private var selectedBudget: String
    @State private var selectedDietaryRestrictions: Set<String>
    @State private var selectedGoals: Set<String>
    @State private var excludedIngredients: String = ""
    
    init(preferences: Binding<MealPlanPreferences>) {
        self._preferences = preferences
        self._weekStartDate = State(initialValue: preferences.wrappedValue.weekStartDate)
        self._selectedBudget = State(initialValue: preferences.wrappedValue.budget)
        self._selectedDietaryRestrictions = State(initialValue: Set(preferences.wrappedValue.dietaryRestrictions))
        self._selectedGoals = State(initialValue: Set(preferences.wrappedValue.goals))
        self._excludedIngredients = State(initialValue: preferences.wrappedValue.excludedIngredients.joined(separator: ", "))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                weekStartSection
                budgetSection
                dietaryRestrictionsSection
                goalsSection
                excludedIngredientsSection
            }
            .navigationTitle("Meal Plan Preferences")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        savePreferences()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Form Sections
extension MealPlanPreferencesView {
    
    private var weekStartSection: some View {
        Section("Week Starting Date") {
            DatePicker(
                "Select week start",
                selection: $weekStartDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
        }
    }
    
    private var budgetSection: some View {
        Section("Budget Range") {
            ForEach(MealPlanPreferences.budgetOptions, id: \.self) { budget in
                HStack {
                    Text(budget)
                    Spacer()
                    if selectedBudget == budget {
                        Image(systemName: "checkmark")
                            .foregroundColor(AppColors.primaryOrange)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedBudget = budget
                }
            }
        }
    }
    
    private var dietaryRestrictionsSection: some View {
        Section("Dietary Restrictions") {
            ForEach(MealPlanPreferences.commonDietaryRestrictions, id: \.self) { restriction in
                HStack {
                    Text(restriction)
                    Spacer()
                    if selectedDietaryRestrictions.contains(restriction) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.primaryOrange)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedDietaryRestrictions.contains(restriction) {
                        selectedDietaryRestrictions.remove(restriction)
                    } else {
                        selectedDietaryRestrictions.insert(restriction)
                    }
                }
            }
        }
    }
    
    private var goalsSection: some View {
        Section("Health Goals") {
            ForEach(MealPlanPreferences.commonGoals, id: \.self) { goal in
                HStack {
                    Text(goal)
                    Spacer()
                    if selectedGoals.contains(goal) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(AppColors.primaryOrange)
                    } else {
                        Image(systemName: "circle")
                            .foregroundColor(.secondary)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if selectedGoals.contains(goal) {
                        selectedGoals.remove(goal)
                    } else {
                        selectedGoals.insert(goal)
                    }
                }
            }
        }
    }
    
    private var excludedIngredientsSection: some View {
        Section("Excluded Ingredients") {
            TextField("E.g., peanuts, shellfish, dairy", text: $excludedIngredients)
                .textFieldStyle(.plain)
            
            Text("Separate multiple ingredients with commas")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Helper Methods
    
    private func savePreferences() {
        let excludedList = excludedIngredients
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        preferences = MealPlanPreferences(
            weekStartDate: weekStartDate,
            budget: selectedBudget,
            dietaryRestrictions: Array(selectedDietaryRestrictions),
            goals: selectedGoals.isEmpty ? ["General Health"] : Array(selectedGoals),
            excludedIngredients: excludedList
        )
    }
}

#Preview {
    MealPlanPreferencesView(preferences: .constant(
        MealPlanPreferences(
            weekStartDate: Date(),
            budget: "Medium ($60-100)",
            dietaryRestrictions: [],
            goals: ["General Health"],
            excludedIngredients: []
        )
    ))
} 
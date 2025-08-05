//
//  MealPlanGeneration.swift
//  Makuli
//
//  Created by ian on 2025-08-05.
//
//  Essential types for meal plan generation UI state management.
//

import Foundation

// MARK: - UI State Models

/// UI state for the meal plan generation process
enum MealPlanGenerationState: Equatable {
    case idle
    case generating
    case saving
    case saved(Plan)
    case error(String)
    
    // Custom Equatable implementation for associated values
    static func == (lhs: MealPlanGenerationState, rhs: MealPlanGenerationState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle):
            return true
        case (.generating, .generating):
            return true
        case (.saving, .saving):
            return true
        case (.saved(let lhsPlan), .saved(let rhsPlan)):
            return lhsPlan.id == rhsPlan.id
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

/// User preferences for meal plan generation
struct MealPlanPreferences {
    let weekStartDate: Date
    let budget: String
    let dietaryRestrictions: [String]
    let goals: [String]
    let excludedIngredients: [String]
    
    static let budgetOptions = ["Low ($40-60)", "Medium ($60-100)", "High ($100+)"]
    static let commonDietaryRestrictions = ["Vegetarian", "Vegan", "No Pork", "No Beef", "Gluten-Free", "Dairy-Free"]
    static let commonGoals = ["Weight Loss", "Weight Gain", "Muscle Building", "General Health", "Energy Boost"]
    
    init(
        weekStartDate: Date = Calendar.current.startOfDay(for: Date()),
        budget: String = "Medium ($60-100)",
        dietaryRestrictions: [String] = [],
        goals: [String] = ["General Health"],
        excludedIngredients: [String] = []
    ) {
        self.weekStartDate = weekStartDate
        self.budget = budget
        self.dietaryRestrictions = dietaryRestrictions
        self.goals = goals
        self.excludedIngredients = excludedIngredients
    }
} 
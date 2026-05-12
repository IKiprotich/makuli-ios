//
//  OnboardingViewModel.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var isCompleting = false
    @Published var errorMessage: String?
    @Published var completionSuccess = false
    @Published var currentStep = 0
    @Published var validationErrors: [String: String] = [:]

    // Form data (used by the multi-step form flow)
    @Published var name = ""
    @Published var age = ""
    @Published var selectedGender = ""
    @Published var selectedDiet = ""
    @Published var selectedBudget = ""
    @Published var selectedGoals: [String] = []
    @Published var cookingExperience = ""
    @Published var allergens: [String] = []
    @Published var householdSize = ""

    private let supabaseManager = SupabaseManager.shared

    let totalSteps = 5
    
    // MARK: - Options

    let genderOptions = ["Male", "Female", "Non-binary", "Prefer not to say"]

    let dietOptions = [
        "No restrictions",
        "Vegetarian",
        "Vegan",
        "Pescatarian",
        "Keto",
        "Paleo",
        "Mediterranean",
        "Low-carb",
        "Gluten-free",
        "Dairy-free"
    ]
    
    let budgetOptions = [
        "Budget-friendly ($30-50/week)",
        "Moderate ($50-80/week)",
        "Flexible ($80-120/week)",
        "Premium ($120+/week)"
    ]
    
    let goalOptions = [
        "Weight loss",
        "Weight gain",
        "Muscle building",
        "Maintain weight",
        "Eat healthier",
        "Save time cooking",
        "Learn new recipes",
        "Meal prep",
        "Family meals",
        "Special occasions"
    ]
    
    let experienceOptions = [
        "Beginner",
        "Some experience",
        "Intermediate",
        "Advanced",
        "Expert chef"
    ]
    
    let commonAllergens = [
        "Nuts",
        "Shellfish",
        "Eggs",
        "Dairy",
        "Soy",
        "Gluten",
        "Fish",
        "Sesame"
    ]
    
    // MARK: - Computed Properties

    var isCurrentStepValid: Bool {
        switch currentStep {
        case 0: // Personal info
            return isPersonalInfoValid
        case 1: // Dietary preferences
            return isDietaryPreferencesValid
        case 2: // Goals and experience
            return isGoalsAndExperienceValid
        case 3: // Budget and household
            return isBudgetAndHouseholdValid
        case 4: // Review
            return true
        default:
            return false
        }
    }
    
    private var isPersonalInfoValid: Bool {
        return !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !age.isEmpty &&
               Int(age) != nil &&
               Int(age)! >= 13 &&
               Int(age)! <= 120 &&
               !selectedGender.isEmpty
    }
    
    private var isDietaryPreferencesValid: Bool {
        return !selectedDiet.isEmpty
    }
    
    private var isGoalsAndExperienceValid: Bool {
        return !selectedGoals.isEmpty && !cookingExperience.isEmpty
    }
    
    private var isBudgetAndHouseholdValid: Bool {
        return !selectedBudget.isEmpty &&
               !householdSize.isEmpty &&
               Int(householdSize) != nil &&
               Int(householdSize)! >= 1 &&
               Int(householdSize)! <= 20
    }
    
    var progressPercentage: Double {
        return Double(currentStep) / Double(totalSteps) * 100.0
    }

    var canProceed: Bool { isCurrentStepValid }
    var canGoBack: Bool { currentStep > 0 }
    var isFinalStep: Bool { currentStep >= totalSteps - 1 }

    // MARK: - Navigation

    func nextStep() {
        guard canProceed && !isFinalStep else { return }
        
        validateCurrentStep()
        
        if validationErrors.isEmpty {
            currentStep += 1
        }
    }
    
    func previousStep() {
        guard canGoBack else { return }
        currentStep -= 1
        clearValidationErrors()
    }

    func goToStep(_ step: Int) {
        guard step >= 0 && step < totalSteps else { return }
        currentStep = step
    }

    // MARK: - Validation

    private func validateCurrentStep() {
        clearValidationErrors()
        
        switch currentStep {
        case 0:
            validatePersonalInfo()
        case 1:
            validateDietaryPreferences()
        case 2:
            validateGoalsAndExperience()
        case 3:
            validateBudgetAndHousehold()
        default:
            break
        }
    }
    
    private func validatePersonalInfo() {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationErrors["name"] = "Name is required"
        } else if name.count < 2 {
            validationErrors["name"] = "Name must be at least 2 characters"
        }
        
        if age.isEmpty {
            validationErrors["age"] = "Age is required"
        } else if let ageInt = Int(age) {
            if ageInt < 13 {
                validationErrors["age"] = "You must be at least 13 years old"
            } else if ageInt > 120 {
                validationErrors["age"] = "Please enter a valid age"
            }
        } else {
            validationErrors["age"] = "Please enter a valid age"
        }
        
        if selectedGender.isEmpty {
            validationErrors["gender"] = "Please select your gender"
        }
    }
    
    private func validateDietaryPreferences() {
        if selectedDiet.isEmpty {
            validationErrors["diet"] = "Please select your dietary preference"
        }
    }
    
    private func validateGoalsAndExperience() {
        if selectedGoals.isEmpty {
            validationErrors["goals"] = "Please select at least one goal"
        }
        
        if cookingExperience.isEmpty {
            validationErrors["experience"] = "Please select your cooking experience level"
        }
    }
    
    private func validateBudgetAndHousehold() {
        if selectedBudget.isEmpty {
            validationErrors["budget"] = "Please select your budget preference"
        }
        
        if householdSize.isEmpty {
            validationErrors["household"] = "Household size is required"
        } else if let size = Int(householdSize) {
            if size < 1 {
                validationErrors["household"] = "Household size must be at least 1"
            } else if size > 20 {
                validationErrors["household"] = "Household size cannot exceed 20"
            }
        } else {
            validationErrors["household"] = "Please enter a valid number"
        }
    }
    
    private func clearValidationErrors() {
        validationErrors.removeAll()
    }

    // MARK: - Selection

    func toggleGoal(_ goal: String) {
        if selectedGoals.contains(goal) {
            selectedGoals.removeAll { $0 == goal }
        } else {
            selectedGoals.append(goal)
        }
    }
    
    func toggleAllergen(_ allergen: String) {
        if allergens.contains(allergen) {
            allergens.removeAll { $0 == allergen }
        } else {
            allergens.append(allergen)
        }
    }
    
    // MARK: - Completion

    /// Completes onboarding using data collected from the onboarding screens.
    /// This is the primary path called from PlanSummaryView.
    func completeOnboarding(authViewModel: AuthViewModel, onboardingData: OnboardingData) async {
        guard !isCompleting else { return }
        guard authViewModel.user != nil else {
            errorMessage = "User not authenticated. Please try logging in again."
            return
        }

        isCompleting = true
        errorMessage = nil
        completionSuccess = false

        let diet = mapDietToDBValue(onboardingData.dietaryPreferences)
        let gender = mapGenderToDBValue(onboardingData.gender)
        let goal = mapGoalToDBValue(onboardingData.fitnessGoal)
        let budget = mapBudgetToDBValue(onboardingData.budgetRange)

        await authViewModel.completeOnboarding(
            age: onboardingData.age,
            gender: gender,
            diet: diet,
            budget: budget,
            goal: goal
        )

        if authViewModel.user?.isOnboardingCompleted == true {
            completionSuccess = true
        } else {
            errorMessage = authViewModel.errorMessage ?? "Failed to complete onboarding. Please try again."
        }

        isCompleting = false
    }

    // MARK: - Helper Methods

    func clearError() {
        errorMessage = nil
    }

    func resetState() {
        isCompleting = false
        errorMessage = nil
        completionSuccess = false
        currentStep = 0
        validationErrors.removeAll()
        name = ""
        age = ""
        selectedGender = ""
        selectedDiet = ""
        selectedBudget = ""
        selectedGoals.removeAll()
        cookingExperience = ""
        allergens.removeAll()
        householdSize = ""
    }

    // MARK: - Value Mapping

    // Maps onboarding screen values to their database-constraint equivalents.

    private func mapGenderToDBValue(_ gender: String) -> String {
        switch gender {
        case "Male": return "male"
        case "Female": return "female"
        case "Non-binary": return "other"
        case "Prefer not to say": return "prefer_not_to_say"
        default: return "prefer_not_to_say"
        }
    }

    // Takes an array because DietPreferenceView allows multi-select; first DB-supported value wins.
    private func mapDietToDBValue(_ preferences: [String]) -> String {
        for pref in preferences {
            switch pref {
            case "Vegetarian": return "vegetarian"
            case "Vegan": return "vegan"
            case "Keto": return "keto"
            case "Paleo": return "paleo"
            case "Mediterranean": return "mediterranean"
            case "Gluten-free": return "gluten_free"
            default: continue
            }
        }
        return "none"
    }

    private func mapBudgetToDBValue(_ budget: String) -> String {
        switch budget {
        case "$50 - $100": return "low"
        case "$100 - $200": return "medium"
        case "$200 - $300", "$300+": return "high"
        default: return "medium"
        }
    }

    private func mapGoalToDBValue(_ goal: String) -> String {
        switch goal {
        case "Lose Weight": return "lose_weight"
        case "Gain Weight": return "gain_weight"
        case "Maintain Weight": return "maintain_weight"
        case "Build Muscle": return "build_muscle"
        case "Improve Health": return "improve_health"
        default: return "maintain_weight"
        }
    }

    // Legacy helpers used by the multi-step form (not called from onboarding screens).
    private func extractBudgetCategory(from fullBudget: String) -> String {
        if fullBudget.contains("Budget-friendly") { return "low" }
        if fullBudget.contains("Moderate") { return "medium" }
        if fullBudget.contains("Flexible") || fullBudget.contains("Premium") { return "high" }
        return "medium"
    }

    private func extractDietCategory(from dietSelection: String) -> String {
        switch dietSelection {
        case "No restrictions": return "none"
        case "Vegetarian": return "vegetarian"
        case "Vegan": return "vegan"
        case "Keto", "Low-carb": return "keto"
        case "Paleo": return "paleo"
        case "Mediterranean": return "mediterranean"
        case "Gluten-free": return "gluten_free"
        default: return "none"
        }
    }

    private func extractGenderCategory(from genderSelection: String) -> String {
        switch genderSelection {
        case "Male": return "male"
        case "Female": return "female"
        case "Non-binary": return "other"
        default: return "prefer_not_to_say"
        }
    }

    private func extractGoalCategory(from selectedGoals: [String]) -> String {
        let priority: [String: String] = [
            "Weight loss": "lose_weight",
            "Weight gain": "gain_weight",
            "Muscle building": "build_muscle",
            "Maintain weight": "maintain_weight",
            "Eat healthier": "improve_health"
        ]
        for goal in selectedGoals {
            if let dbGoal = priority[goal] { return dbGoal }
        }
        return "maintain_weight"
    }

    private func validateAllSteps() {
        clearValidationErrors()
        let originalStep = currentStep
        for step in 0..<totalSteps {
            currentStep = step
            validateCurrentStep()
        }
        currentStep = originalStep
    }

    // MARK: - Step Descriptions

    func getCurrentStepTitle() -> String {
        switch currentStep {
        case 0:
            return "Tell us about yourself"
        case 1:
            return "Dietary preferences"
        case 2:
            return "Goals & experience"
        case 3:
            return "Budget & household"
        case 4:
            return "Review your profile"
        default:
            return "Getting started"
        }
    }
    
    func getCurrentStepDescription() -> String {
        switch currentStep {
        case 0:
            return "We'll use this to personalize your meal plans"
        case 1:
            return "Help us understand your dietary needs and restrictions"
        case 2:
            return "What are your goals and cooking experience level?"
        case 3:
            return "This helps us suggest appropriate portion sizes and costs"
        case 4:
            return "Double-check your information before we create your profile"
        default:
            return "Let's get you set up with personalized meal planning"
        }
    }
    
    func getValidationError(for field: String) -> String? {
        return validationErrors[field]
    }

    func hasValidationError(for field: String) -> Bool {
        return validationErrors[field] != nil
    }
} 

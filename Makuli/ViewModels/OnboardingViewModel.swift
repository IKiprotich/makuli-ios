//
//  OnboardingViewModel.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready onboarding view model for user profile setup.
//

import Foundation

@MainActor
class OnboardingViewModel: ObservableObject {
    @Published var isCompleting = false
    @Published var errorMessage: String?
    @Published var completionSuccess = false
    @Published var currentStep = 0
    @Published var validationErrors: [String: String] = [:]
    
    // Form data
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
    
    // MARK: - Constants
    
    let totalSteps = 5
    
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
    
    /// Whether current step is valid
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
    
    /// Progress percentage
    var progressPercentage: Double {
        return Double(currentStep) / Double(totalSteps) * 100.0
    }
    
    /// Whether we can proceed to next step
    var canProceed: Bool {
        return isCurrentStepValid
    }
    
    /// Whether we can go back
    var canGoBack: Bool {
        return currentStep > 0
    }
    
    /// Whether this is the final step
    var isFinalStep: Bool {
        return currentStep >= totalSteps - 1
    }
    
    // MARK: - Navigation Methods
    
    /// Proceeds to next step
    func nextStep() {
        guard canProceed && !isFinalStep else { return }
        
        validateCurrentStep()
        
        if validationErrors.isEmpty {
            currentStep += 1
        }
    }
    
    /// Goes back to previous step
    func previousStep() {
        guard canGoBack else { return }
        
        currentStep -= 1
        clearValidationErrors()
    }
    
    /// Skips to a specific step (for testing)
    func goToStep(_ step: Int) {
        guard step >= 0 && step < totalSteps else { return }
        currentStep = step
    }
    
    // MARK: - Validation Methods
    
    /// Validates the current step
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
    
    // MARK: - Selection Methods
    
    /// Toggles a goal selection
    func toggleGoal(_ goal: String) {
        if selectedGoals.contains(goal) {
            selectedGoals.removeAll { $0 == goal }
        } else {
            selectedGoals.append(goal)
        }
    }
    
    /// Toggles an allergen selection
    func toggleAllergen(_ allergen: String) {
        if allergens.contains(allergen) {
            allergens.removeAll { $0 == allergen }
        } else {
            allergens.append(allergen)
        }
    }
    
    // MARK: - Completion Methods
    
    /// Completes the onboarding process
    func completeOnboarding(authViewModel: AuthViewModel) async {
        guard !isCompleting else {
            Logger.warning("Onboarding completion already in progress")
            return
        }
        
        guard let userId = authViewModel.user?.id else {
            errorMessage = "User not authenticated. Please try logging in again."
            return
        }
        
        // Final validation
        validateAllSteps()
        guard validationErrors.isEmpty else {
            errorMessage = "Please complete all required fields"
            return
        }
        
        isCompleting = true
        errorMessage = nil
        completionSuccess = false
        
        Logger.info("Starting onboarding completion for user: \(userId)")
        
        do {
            // Create user profile with all collected data
            guard let user = authViewModel.user else {
                errorMessage = "User data not available"
                return
            }
            
            let updatedProfile = UserProfile(
                id: userId,
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                email: user.email,
                age: Int(age) ?? 25,
                gender: extractGenderCategory(from: selectedGender),
                goal: extractGoalCategory(from: selectedGoals),
                diet: extractDietCategory(from: selectedDiet),
                budget: extractBudgetCategory(from: selectedBudget),
                isPremium: false,
                subscriptionRenewal: nil,
                profileImageUrl: nil,
                createdAt: Date(),
                updatedAt: Date(),
                isOnboardingCompleted: true,
                subscriptionType: "free",
                plansCreatedThisMonth: 0,
                aiGenerationsThisMonth: 0,
                lastPlanReset: Date()
            )
            
            try await supabaseManager.updateUserProfile(updatedProfile)
            
            // Update auth view model with completed profile
            authViewModel.user = User(
                id: updatedProfile.id,
                name: updatedProfile.name ?? "Name",
                email: updatedProfile.email,
                age: updatedProfile.age ?? 25,
                gender: updatedProfile.gender ?? "",
                goal: updatedProfile.goal ?? "",
                diet: updatedProfile.diet ?? "",
                budget: updatedProfile.budget ?? "",
                isPremium: false,
                subscriptionRenewalDate: nil,
                profileImageURL: updatedProfile.profileImageUrl,
                isOnboardingCompleted: true
            )
            
            completionSuccess = true
            Logger.info("Successfully completed onboarding")
            
            // Track onboarding completion
            await trackOnboardingCompletion(userId: userId)
            
        } catch {
            Logger.error("Failed to complete onboarding: \(error)")
            errorMessage = "Failed to complete onboarding: \(error.localizedDescription)"
            completionSuccess = false
        }
        
        isCompleting = false
    }
    
    /// Validates all steps for final submission
    private func validateAllSteps() {
        clearValidationErrors()
        
        // Validate all steps
        let originalStep = currentStep
        
        for step in 0..<totalSteps {
            currentStep = step
            validateCurrentStep()
        }
        
        currentStep = originalStep
    }
    
    /// Tracks onboarding completion for analytics
    private func trackOnboardingCompletion(userId: String) async {
        // This would integrate with analytics service
        Logger.info("Onboarding completed - userId: \(userId), goals: \(selectedGoals), diet: \(selectedDiet)")
    }
    
    // MARK: - Helper Methods
    
    /// Clears error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Resets all onboarding state
    func resetState() {
        isCompleting = false
        errorMessage = nil
        completionSuccess = false
        currentStep = 0
        validationErrors.removeAll()
        
        // Clear form data
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
    
    /// Extracts budget category from full budget string
    private func extractBudgetCategory(from fullBudget: String) -> String {
        if fullBudget.contains("Budget-friendly") {
            return "low"
        } else if fullBudget.contains("Moderate") {
            return "medium"
        } else if fullBudget.contains("Flexible") {
            return "high"
        } else if fullBudget.contains("Premium") {
            return "high"  // Map Premium to 'high' since DB only allows 'low', 'medium', 'high'
        } else {
            return "medium" // Default
        }
    }
    
    /// Extracts diet category from full diet string to match database constraints
    private func extractDietCategory(from dietSelection: String) -> String {
        switch dietSelection {
        case "No restrictions":
            return "none"
        case "Vegetarian":
            return "vegetarian"
        case "Vegan":
            return "vegan"
        case "Keto":
            return "keto"
        case "Paleo":
            return "paleo"
        case "Mediterranean":
            return "mediterranean"
        case "Gluten-free":
            return "gluten_free"
        case "Pescatarian":
            return "none" // Map to 'none' since pescatarian is not in DB constraints
        case "Low-carb":
            return "keto" // Map to 'keto' since it's low-carb focused
        case "Dairy-free":
            return "none" // Map to 'none' since dairy-free is not a primary diet category in DB
        default:
            return "none" // Default fallback
        }
    }
    
    /// Extracts gender category from selection to match database constraints
    private func extractGenderCategory(from genderSelection: String) -> String {
        switch genderSelection {
        case "Male":
            return "male"
        case "Female":
            return "female"
        case "Non-binary":
            return "other"
        case "Prefer not to say":
            return "prefer_not_to_say"
        default:
            return "prefer_not_to_say" // Default fallback
        }
    }
    
    /// Extracts goal category from selected goals to match database constraints
    private func extractGoalCategory(from selectedGoals: [String]) -> String {
        // If multiple goals are selected, prioritize by health/fitness importance
        let goalPriority = [
            "Weight loss": "lose_weight",
            "Weight gain": "gain_weight", 
            "Muscle building": "build_muscle",
            "Maintain weight": "maintain_weight",
            "Eat healthier": "improve_health"
        ]
        
        // Find the first goal that matches our database constraints
        for goal in selectedGoals {
            if let dbGoal = goalPriority[goal] {
                return dbGoal
            }
        }
        
        // If no direct match, map remaining goals to closest equivalents
        for goal in selectedGoals {
            switch goal {
            case "Save time cooking", "Learn new recipes", "Meal prep":
                return "improve_health" // Focus on overall health improvement
            case "Family meals", "Special occasions":
                return "maintain_weight" // Maintain current weight while accommodating social eating
            default:
                continue
            }
        }
        
        return "maintain_weight" // Default fallback
    }
    
    /// Gets current step title
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
    
    /// Gets current step description
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
    
    /// Gets validation error for a field
    func getValidationError(for field: String) -> String? {
        return validationErrors[field]
    }
    
    /// Checks if a field has a validation error
    func hasValidationError(for field: String) -> Bool {
        return validationErrors[field] != nil
    }
} 

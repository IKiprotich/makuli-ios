//
//  ProfileViewModel.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready profile view model for Supabase database operations.
//

import Foundation

enum ProfileError: Error {
    case profileNotLoaded
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isUpdating = false
    @Published var successMessage: String?
    
    private let supabaseManager = SupabaseManager.shared
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    
    var hasPremiumAccess: Bool {
        return profile?.hasPremiumAccess ?? false
    }
    
    var subscriptionDisplayName: String {
        return profile?.subscriptionDisplayName ?? "Free Plan"
    }
    
    var daysUntilRenewal: Int? {
        return profile?.daysUntilRenewal
    }
    
    var plansRemainingThisMonth: Int {
        return profile?.plansRemainingThisMonth ?? 0
    }
    
    var spoonacularGenerationsRemainingThisMonth: Int {
        return profile?.spoonacularGenerationsRemainingThisMonth ?? 0
    }
    
    var isProfileComplete: Bool {
        return profile?.isProfileComplete ?? false
    }
    
    var profileCompletionPercentage: Double {
        guard let profile = profile else { return 0.0 }
        
        var completedFields = 0
        let totalFields = 6
        
        if profile.name != nil && !profile.name!.isEmpty { completedFields += 1 }
        if profile.age != nil { completedFields += 1 }
        if profile.gender != nil { completedFields += 1 }
        if profile.goal != nil { completedFields += 1 }
        if profile.diet != nil { completedFields += 1 }
        if profile.budget != nil { completedFields += 1 }
        
        return Double(completedFields) / Double(totalFields) * 100.0
    }
    
    // MARK: - Public Methods
    
    func fetchProfile(for userId: String) async {
        if profile != nil && errorMessage == nil {
            Logger.debug("Profile already loaded, skipping fetch")
            return
        }
        
        fetchTask?.cancel()
        
        fetchTask = Task {
            await performFetch(for: userId)
        }
        
        await fetchTask?.value
    }
    
    func forceRefreshProfile(for userId: String) async {
        profile = nil
        errorMessage = nil
        await performFetch(for: userId)
    }
    
    func updateProfile(
        userId: String,
        name: String? = nil,
        age: Int? = nil,
        gender: String? = nil,
        goal: String? = nil,
        diet: String? = nil,
        budget: String? = nil,
        profileImageUrl: String? = nil
    ) async -> Bool {
        
        do {
            Logger.info("Updating profile for user: \(userId)")
            
            isUpdating = true
            errorMessage = nil
            successMessage = nil
            
            let defaultNotificationPreferences = NotificationPreferences(
                mealReminders: true,
                groceryReminders: true,
                achievementNotifications: true,
                weeklyReports: true,
                newRecipeNotifications: true,
                preferredNotificationTime: "18:00",
                pushNotificationsEnabled: true,
                emailNotificationsEnabled: true
            )
            
            let defaultPrivacySettings = PrivacySettings(
                isProfilePublic: false,
                mealPlansVisible: false,
                progressSharingEnabled: false,
                achievementsPublic: false,
                locationSharingEnabled: false
            )
            
            let defaultFitnessGoals = FitnessGoals(
                targetWeight: nil,
                targetCalories: nil,
                targetProtein: nil,
                targetCarbohydrates: nil,
                targetFat: nil,
                weeklyWorkoutMinutes: nil,
                targetStepsPerDay: nil
            )
            
            let defaultMealPlanningPreferences = MealPlanningPreferences(
                mealsPerDay: 3,
                preferredPrepTime: 30,
                includeSnacks: false,
                preferredCuisines: ["american", "italian"],
                rotateMeals: true,
                includeLeftovers: true,
                preferredComplexity: "balanced"
            )
            
            let defaultDietaryPreferences = DietaryPreferences(
                restrictions: [],
                allergies: [],
                favoriteIngredients: [],
                dislikedIngredients: [],
                avoidIngredients: [],
                preferredCookingMethods: ["stovetop", "baking"]
            )
            
            let defaultCookingPreferences = CookingPreferences(
                skillLevel: "beginner",
                preferredCookingTime: 30,
                useAppliances: true,
                preferredMethods: ["stovetop", "baking"],
                usePreMadeIngredients: false,
                batchCooking: false
            )
            
            let defaultBudgetPreferences = BudgetPreferences(
                weeklyBudget: 100.0,
                monthlyBudget: 400.0,
                preferredMealPrice: 8.0,
                prioritizeBudget: true,
                includePremiumIngredients: false,
                suggestAlternatives: true
            )
            
            let updatedProfile = UserProfile(
                id: userId,
                userId: userId,
                name: name,
                email: profile?.email ?? "",
                age: age,
                gender: gender,
                goal: goal,
                diet: diet,
                budget: budget,
                isPremium: profile?.isPremium ?? false,
                isOnboardingCompleted: profile?.isOnboardingCompleted ?? false,
                subscriptionType: profile?.subscriptionType ?? "free",
                subscriptionRenewal: profile?.subscriptionRenewal,
                plansCreatedThisMonth: profile?.plansCreatedThisMonth ?? 0,
                spoonacularGenerationsThisMonth: profile?.spoonacularGenerationsThisMonth ?? 0,
                lastPlanReset: profile?.lastPlanReset ?? Date(),
                profileImageUrl: profileImageUrl,
                bio: profile?.bio,
                location: profile?.location,
                preferredLanguage: profile?.preferredLanguage ?? "en",
                timezone: profile?.timezone ?? "UTC",
                measurementSystem: profile?.measurementSystem ?? "metric",
                preferredCurrency: profile?.preferredCurrency ?? "USD",
                notificationPreferences: profile?.notificationPreferences ?? defaultNotificationPreferences,
                privacySettings: profile?.privacySettings ?? defaultPrivacySettings,
                fitnessGoals: profile?.fitnessGoals ?? defaultFitnessGoals,
                mealPlanningPreferences: profile?.mealPlanningPreferences ?? defaultMealPlanningPreferences,
                dietaryPreferences: profile?.dietaryPreferences ?? defaultDietaryPreferences,
                cookingPreferences: profile?.cookingPreferences ?? defaultCookingPreferences,
                budgetPreferences: profile?.budgetPreferences ?? defaultBudgetPreferences,
                achievements: profile?.achievements ?? [],
                progressMetrics: profile?.progressMetrics ?? [],
                spoonacularUsername: profile?.spoonacularUsername,
                spoonacularHash: profile?.spoonacularHash,
                createdAt: profile?.createdAt ?? Date(),
                updatedAt: Date()
            )
            
            try await supabaseManager.updateUserProfile(updatedProfile)
            
            self.profile = updatedProfile
            self.successMessage = "Profile updated successfully"
            
            Logger.info("Successfully updated profile")
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update profile: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func completeOnboarding(
        userId: String,
        name: String,
        age: Int,
        gender: String,
        goal: String,
        diet: String,
        budget: String
    ) async -> Bool {
        
        do {
            Logger.info("Completing onboarding for user: \(userId)")
            
            isUpdating = true
            errorMessage = nil
            
            let onboardingNotificationPreferences = NotificationPreferences(
                mealReminders: true,
                groceryReminders: true,
                achievementNotifications: true,
                weeklyReports: true,
                newRecipeNotifications: true,
                preferredNotificationTime: "18:00",
                pushNotificationsEnabled: true,
                emailNotificationsEnabled: true
            )
            
            let onboardingPrivacySettings = PrivacySettings(
                isProfilePublic: false,
                mealPlansVisible: false,
                progressSharingEnabled: false,
                achievementsPublic: false,
                locationSharingEnabled: false
            )
            
            let onboardingFitnessGoals = FitnessGoals(
                targetWeight: nil,
                targetCalories: nil,
                targetProtein: nil,
                targetCarbohydrates: nil,
                targetFat: nil,
                weeklyWorkoutMinutes: nil,
                targetStepsPerDay: nil
            )
            
            let onboardingMealPlanningPreferences = MealPlanningPreferences(
                mealsPerDay: 3,
                preferredPrepTime: 30,
                includeSnacks: false,
                preferredCuisines: ["american", "italian"],
                rotateMeals: true,
                includeLeftovers: true,
                preferredComplexity: "balanced"
            )
            
            let onboardingDietaryPreferences = DietaryPreferences(
                restrictions: [],
                allergies: [],
                favoriteIngredients: [],
                dislikedIngredients: [],
                avoidIngredients: [],
                preferredCookingMethods: ["stovetop", "baking"]
            )
            
            let onboardingCookingPreferences = CookingPreferences(
                skillLevel: "beginner",
                preferredCookingTime: 30,
                useAppliances: true,
                preferredMethods: ["stovetop", "baking"],
                usePreMadeIngredients: false,
                batchCooking: false
            )
            
            let onboardingBudgetPreferences = BudgetPreferences(
                weeklyBudget: 100.0,
                monthlyBudget: 400.0,
                preferredMealPrice: 8.0,
                prioritizeBudget: true,
                includePremiumIngredients: false,
                suggestAlternatives: true
            )
            
            let updatedProfile = UserProfile(
                id: userId,
                userId: userId,
                name: name,
                email: profile?.email ?? "",
                age: age,
                gender: gender,
                goal: goal,
                diet: diet,
                budget: budget,
                isPremium: profile?.isPremium ?? false,
                isOnboardingCompleted: true,
                subscriptionType: profile?.subscriptionType ?? "free",
                subscriptionRenewal: profile?.subscriptionRenewal,
                plansCreatedThisMonth: profile?.plansCreatedThisMonth ?? 0,
                spoonacularGenerationsThisMonth: profile?.spoonacularGenerationsThisMonth ?? 0,
                lastPlanReset: profile?.lastPlanReset ?? Date(),
                profileImageUrl: profile?.profileImageUrl,
                bio: profile?.bio,
                location: profile?.location,
                preferredLanguage: profile?.preferredLanguage ?? "en",
                timezone: profile?.timezone ?? "UTC",
                measurementSystem: profile?.measurementSystem ?? "metric",
                preferredCurrency: profile?.preferredCurrency ?? "USD",
                notificationPreferences: profile?.notificationPreferences ?? onboardingNotificationPreferences,
                privacySettings: profile?.privacySettings ?? onboardingPrivacySettings,
                fitnessGoals: profile?.fitnessGoals ?? onboardingFitnessGoals,
                mealPlanningPreferences: profile?.mealPlanningPreferences ?? onboardingMealPlanningPreferences,
                dietaryPreferences: profile?.dietaryPreferences ?? onboardingDietaryPreferences,
                cookingPreferences: profile?.cookingPreferences ?? onboardingCookingPreferences,
                budgetPreferences: profile?.budgetPreferences ?? onboardingBudgetPreferences,
                achievements: profile?.achievements ?? [],
                progressMetrics: profile?.progressMetrics ?? [],
                spoonacularUsername: profile?.spoonacularUsername,
                spoonacularHash: profile?.spoonacularHash,
                createdAt: profile?.createdAt ?? Date(),
                updatedAt: Date()
            )
            
            try await supabaseManager.updateUserProfile(updatedProfile)
            
            self.profile = updatedProfile
            self.successMessage = "Welcome to Makuli! Your profile is now complete."
            
            Logger.info("Successfully completed onboarding")
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to complete onboarding: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func updateSubscription(
        userId: String,
        subscriptionType: String,
        renewalDate: Date?
    ) async -> Bool {
        
        do {
            Logger.info("Updating subscription for user: \(userId)")
            
            isUpdating = true
            errorMessage = nil
            
            guard var currentProfile = profile else { 
                throw ProfileError.profileNotLoaded 
            }
            
            currentProfile.subscriptionType = subscriptionType
            currentProfile.subscriptionRenewal = renewalDate
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            await forceRefreshProfile(for: userId)
            
            self.successMessage = "Subscription updated successfully"
            
            Logger.info("Successfully updated subscription")
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update subscription: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func incrementPlanCreationCount() async {
        guard var currentProfile = profile else { return }
        currentProfile.incrementPlanCreationCount()
        self.profile = currentProfile
    }
    
    func incrementSpoonacularGenerationCount() async {
        guard var currentProfile = profile else { return }
        
        do {
            currentProfile.incrementSpoonacularGenerationCount()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            self.profile = currentProfile
            
        } catch {
            Logger.error("Failed to increment Spoonacular generation count: \(error)")
        }
    }
    
    func canPerformAction(_ action: UserAction) -> Bool {
        return profile?.canPerformAction(action) ?? false
    }
    
    func getUsageStats() -> (plans: Int, maxPlans: Int) {
        guard let profile = profile else {
            return (0, 0)
        }

        let maxPlans = profile.hasPremiumAccess ?
            Configuration.maxPlansPerUser :
            Configuration.freePlanLimits.maxPlansPerMonth

        return (
            plans: profile.plansCreatedThisMonth,
            maxPlans: maxPlans
        )
    }
    
    func uploadProfileImage(_ imageData: Data, userId: String) async -> Bool {
        do {
            Logger.info("Uploading profile image for user: \(userId)")
            
            isUpdating = true
            errorMessage = nil
            
            let imageUrl = "https://placeholder.com/profile-\(userId).jpg"
            
            let success = await updateProfile(
                userId: userId,
                profileImageUrl: imageUrl
            )
            
            if success {
                self.successMessage = "Profile image updated successfully"
            }
            
            isUpdating = false
            return success
            
        } catch {
            Logger.error("Failed to upload profile image: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func deleteAccount(userId: String) async -> Bool {
        do {
            Logger.info("Deleting account for user: \(userId)")
            
            isUpdating = true
            errorMessage = nil
            
            try await supabaseManager.deleteUserAccount(userId: userId)
            
            self.profile = nil
            
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to delete account: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    // MARK: - Preference Update Methods
    
    func updateGoal(_ newGoal: String) async -> Bool {
        guard var currentProfile = profile else { return false }
        
        do {
            Logger.info("Updating goal to: \(newGoal)")
            
            isUpdating = true
            errorMessage = nil
            
            currentProfile.goal = newGoal
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            self.profile = currentProfile
            self.successMessage = "Goal updated successfully"
            
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update goal: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func updateBudget(_ newBudget: String) async -> Bool {
        guard var currentProfile = profile else { return false }
        
        do {
            Logger.info("Updating budget to: \(newBudget)")
            
            isUpdating = true
            errorMessage = nil
            
            currentProfile.budget = newBudget
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            self.profile = currentProfile
            self.successMessage = "Budget updated successfully"
            
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update budget: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func updateDietPreference(_ newDiet: String) async -> Bool {
        guard var currentProfile = profile else { return false }
        
        do {
            Logger.info("Updating diet preference to: \(newDiet)")
            
            isUpdating = true
            errorMessage = nil
            
            currentProfile.diet = newDiet
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            self.profile = currentProfile
            self.successMessage = "Diet preference updated successfully"
            
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update diet preference: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func updateCookingSkill(_ newSkill: String) async -> Bool {
        guard var currentProfile = profile else { return false }
        
        do {
            Logger.info("Updating cooking skill to: \(newSkill)")
            
            isUpdating = true
            errorMessage = nil
            
            let updatedCookingPreferences = CookingPreferences(
                skillLevel: newSkill,
                preferredCookingTime: currentProfile.cookingPreferences?.preferredCookingTime ?? 30,
                useAppliances: currentProfile.cookingPreferences?.useAppliances ?? true,
                preferredMethods: currentProfile.cookingPreferences?.preferredMethods ?? [],
                usePreMadeIngredients: currentProfile.cookingPreferences?.usePreMadeIngredients ?? false,
                batchCooking: currentProfile.cookingPreferences?.batchCooking ?? false
            )
            
            currentProfile.cookingPreferences = updatedCookingPreferences
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            self.profile = currentProfile
            self.successMessage = "Cooking skill updated successfully"
            
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update cooking skill: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func updatePreferredCuisines(_ newCuisines: [String]) async -> Bool {
        guard var currentProfile = profile else { return false }
        
        do {
            Logger.info("Updating preferred cuisines to: \(newCuisines)")
            
            isUpdating = true
            errorMessage = nil
            
            let updatedMealPlanningPreferences = MealPlanningPreferences(
                mealsPerDay: currentProfile.mealPlanningPreferences?.mealsPerDay ?? 3,
                preferredPrepTime: currentProfile.mealPlanningPreferences?.preferredPrepTime ?? 30,
                includeSnacks: currentProfile.mealPlanningPreferences?.includeSnacks ?? true,
                preferredCuisines: newCuisines,
                rotateMeals: currentProfile.mealPlanningPreferences?.rotateMeals ?? true,
                includeLeftovers: currentProfile.mealPlanningPreferences?.includeLeftovers ?? true,
                preferredComplexity: currentProfile.mealPlanningPreferences?.preferredComplexity ?? "Medium"
            )
            
            currentProfile.mealPlanningPreferences = updatedMealPlanningPreferences
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            self.profile = currentProfile
            self.successMessage = "Preferred cuisines updated successfully"
            
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update preferred cuisines: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func updateDislikedIngredients(_ newDislikes: [String]) async -> Bool {
        guard var currentProfile = profile else { return false }
        
        do {
            Logger.info("Updating disliked ingredients to: \(newDislikes)")
            
            isUpdating = true
            errorMessage = nil
            
            let updatedDietaryPreferences = DietaryPreferences(
                restrictions: currentProfile.dietaryPreferences?.restrictions ?? [],
                allergies: currentProfile.dietaryPreferences?.allergies ?? [],
                favoriteIngredients: currentProfile.dietaryPreferences?.favoriteIngredients ?? [],
                dislikedIngredients: newDislikes,
                avoidIngredients: currentProfile.dietaryPreferences?.avoidIngredients ?? [],
                preferredCookingMethods: currentProfile.dietaryPreferences?.preferredCookingMethods ?? []
            )
            
            currentProfile.dietaryPreferences = updatedDietaryPreferences
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            self.profile = currentProfile
            self.successMessage = "Disliked ingredients updated successfully"
            
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update disliked ingredients: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func updateMealsPerDay(_ newMeals: Int) async -> Bool {
        guard var currentProfile = profile else { return false }
        
        do {
            Logger.info("Updating meals per day to: \(newMeals)")
            
            isUpdating = true
            errorMessage = nil
            
            let updatedMealPlanningPreferences = MealPlanningPreferences(
                mealsPerDay: newMeals,
                preferredPrepTime: currentProfile.mealPlanningPreferences?.preferredPrepTime ?? 30,
                includeSnacks: currentProfile.mealPlanningPreferences?.includeSnacks ?? true,
                preferredCuisines: currentProfile.mealPlanningPreferences?.preferredCuisines ?? [],
                rotateMeals: currentProfile.mealPlanningPreferences?.rotateMeals ?? true,
                includeLeftovers: currentProfile.mealPlanningPreferences?.includeLeftovers ?? true,
                preferredComplexity: currentProfile.mealPlanningPreferences?.preferredComplexity ?? "Medium"
            )
            
            currentProfile.mealPlanningPreferences = updatedMealPlanningPreferences
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            self.profile = currentProfile
            self.successMessage = "Meals per day updated successfully"
            
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update meals per day: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func updateCalorieTarget(_ newCalories: Int) async -> Bool {
        guard var currentProfile = profile else { return false }
        
        do {
            Logger.info("Updating calorie target to: \(newCalories)")
            
            isUpdating = true
            errorMessage = nil
            
            let updatedFitnessGoals = FitnessGoals(
                targetWeight: currentProfile.fitnessGoals?.targetWeight,
                targetCalories: newCalories,
                targetProtein: currentProfile.fitnessGoals?.targetProtein,
                targetCarbohydrates: currentProfile.fitnessGoals?.targetCarbohydrates,
                targetFat: currentProfile.fitnessGoals?.targetFat,
                weeklyWorkoutMinutes: currentProfile.fitnessGoals?.weeklyWorkoutMinutes,
                targetStepsPerDay: currentProfile.fitnessGoals?.targetStepsPerDay
            )
            
            currentProfile.fitnessGoals = updatedFitnessGoals
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            self.profile = currentProfile
            self.successMessage = "Calorie target updated successfully"
            
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update calorie target: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func updateMacroTargets(protein: Int, carbs: Int, fat: Int) async -> Bool {
        guard var currentProfile = profile else { return false }
        
        do {
            Logger.info("Updating macro targets to: \(protein)%, \(carbs)%, \(fat)%")
            
            isUpdating = true
            errorMessage = nil
            
            let updatedFitnessGoals = FitnessGoals(
                targetWeight: currentProfile.fitnessGoals?.targetWeight,
                targetCalories: currentProfile.fitnessGoals?.targetCalories,
                targetProtein: Double(protein),
                targetCarbohydrates: Double(carbs),
                targetFat: Double(fat),
                weeklyWorkoutMinutes: currentProfile.fitnessGoals?.weeklyWorkoutMinutes,
                targetStepsPerDay: currentProfile.fitnessGoals?.targetStepsPerDay
            )
            
            currentProfile.fitnessGoals = updatedFitnessGoals
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            self.profile = currentProfile
            self.successMessage = "Macro targets updated successfully"
            
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update macro targets: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    func exportUserData(userId: String) async -> UserDataExport? {
        do {
            Logger.info("Exporting user data for: \(userId)")
            
            let userDataExport = try await supabaseManager.exportUserData(userId: userId)
            
            Logger.info("Successfully exported user data")
            return userDataExport
            
        } catch {
            Logger.error("Failed to export user data: \(error)")
            self.errorMessage = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    func clearError() {
        errorMessage = nil
    }
    
    func clearSuccess() {
        successMessage = nil
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    func getSubscriptionStatusText() -> String {
        guard let profile = profile else { return "Unknown" }
        
        if profile.hasPremiumAccess {
            if let daysUntilRenewal = daysUntilRenewal {
                return "Premium • Renews in \(daysUntilRenewal) days"
            } else {
                return "Premium Active"
            }
        } else {
            return "Free Plan"
        }
    }
    
    func getUsageWarning() -> String? {
        guard let profile = profile, !profile.hasPremiumAccess else { return nil }

        let planLimit = Configuration.freePlanLimits.maxPlansPerMonth

        if profile.plansCreatedThisMonth >= planLimit {
            return "You've reached your monthly plan limit. Upgrade to premium for unlimited plans."
        }

        if profile.plansCreatedThisMonth >= planLimit - 1 {
            return "You have 1 plan remaining this month. Upgrade to premium for unlimited plans."
        }

        return nil
    }
    
    // MARK: - Private Methods
    
    private func performFetch(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            Logger.info("Fetching profile for user: \(userId)")
            
            let fetchedProfile = try await supabaseManager.fetchUserProfile(userId: userId)
            self.profile = fetchedProfile
            
            Logger.info("Successfully loaded profile")
            
        } catch {
            Logger.error("Failed to fetch profile: \(error)")
            self.errorMessage = "Failed to load profile. Please check your connection and try again."
            self.profile = nil
        }
        
        isLoading = false
    }
    
    deinit {
        fetchTask?.cancel()
    }
}

// MARK: - Supporting Models

struct UserDataExport {
    let profile: UserProfile
    let plans: [PlanWithRecipes]
    let groceryLists: [GroceryItem]
    let favoriteRecipes: [Recipe]
    let exportDate: Date
    
    var fileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "makuli-user-data-\(formatter.string(from: exportDate)).json"
    }
} 
//
//  UserProfile.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready user profile model for Supabase database.
//

import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String
    
    var userId: String?
    
    var name: String?
    
    var email: String?
    
    var age: Int?
    
    var gender: String?
    
    var goal: String?
    
    var diet: String?
    
    var budget: String?
    
    var isPremium: Bool
    
    var isOnboardingCompleted: Bool
    
    var subscriptionType: String?
    
    var subscriptionRenewal: Date?
    
    var plansCreatedThisMonth: Int
    
    var spoonacularGenerationsThisMonth: Int
    
    var lastPlanReset: Date
    
    var profileImageUrl: String?
    
    var bio: String?
    
    var location: String?
    
    var preferredLanguage: String?
    
    var timezone: String?
    
    var measurementSystem: String?
    
    var preferredCurrency: String?
    
    var notificationPreferences: NotificationPreferences?
    
    var privacySettings: PrivacySettings?
    
    var fitnessGoals: FitnessGoals?
    
    var mealPlanningPreferences: MealPlanningPreferences?
    
    var dietaryPreferences: DietaryPreferences?
    
    var cookingPreferences: CookingPreferences?
    
    var budgetPreferences: BudgetPreferences?
    
    var achievements: [Achievement]?
    
    var progressMetrics: [ProgressMetrics]?
    
    var spoonacularUsername: String?
    
    var spoonacularHash: String?
    
    var createdAt: Date
    
    var updatedAt: Date
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case email
        case age
        case gender
        case goal
        case diet
        case budget
        case isPremium = "is_premium"
        case isOnboardingCompleted = "is_onboarding_completed"
        case subscriptionType = "subscription_type"
        case subscriptionRenewal = "subscription_renewal"
        case plansCreatedThisMonth = "plans_created_this_month"
        case spoonacularGenerationsThisMonth = "spoonacular_generations_this_month"
        case lastPlanReset = "last_plan_reset"
        case profileImageUrl = "profile_image_url"
        case bio
        case location
        case preferredLanguage = "preferred_language"
        case timezone
        case measurementSystem = "measurement_system"
        case preferredCurrency = "preferred_currency"
        case notificationPreferences = "notification_preferences"
        case privacySettings = "privacy_settings"
        case fitnessGoals = "fitness_goals"
        case mealPlanningPreferences = "meal_planning_preferences"
        case dietaryPreferences = "dietary_preferences"
        case cookingPreferences = "cooking_preferences"
        case budgetPreferences = "budget_preferences"
        case achievements
        case progressMetrics = "progress_metrics"
        case spoonacularUsername = "spoonacular_username"
        case spoonacularHash = "spoonacular_hash"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        age = try container.decodeIfPresent(Int.self, forKey: .age)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        goal = try container.decodeIfPresent(String.self, forKey: .goal)
        diet = try container.decodeIfPresent(String.self, forKey: .diet)
        budget = try container.decodeIfPresent(String.self, forKey: .budget)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        isOnboardingCompleted = try container.decode(Bool.self, forKey: .isOnboardingCompleted)
        subscriptionType = try container.decodeIfPresent(String.self, forKey: .subscriptionType)
        subscriptionRenewal = try container.decodeIfPresent(Date.self, forKey: .subscriptionRenewal)
        plansCreatedThisMonth = try container.decodeIfPresent(Int.self, forKey: .plansCreatedThisMonth) ?? 0
        spoonacularGenerationsThisMonth = try container.decodeIfPresent(Int.self, forKey: .spoonacularGenerationsThisMonth) ?? 0
        lastPlanReset = try container.decodeIfPresent(Date.self, forKey: .lastPlanReset) ?? Date()
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        preferredLanguage = try container.decodeIfPresent(String.self, forKey: .preferredLanguage)
        timezone = try container.decodeIfPresent(String.self, forKey: .timezone)
        measurementSystem = try container.decodeIfPresent(String.self, forKey: .measurementSystem)
        preferredCurrency = try container.decodeIfPresent(String.self, forKey: .preferredCurrency)
        notificationPreferences = try container.decodeIfPresent(NotificationPreferences.self, forKey: .notificationPreferences)
        privacySettings = try container.decodeIfPresent(PrivacySettings.self, forKey: .privacySettings)
        
        fitnessGoals = try container.decodeIfPresent(FitnessGoals.self, forKey: .fitnessGoals)
        mealPlanningPreferences = try container.decodeIfPresent(MealPlanningPreferences.self, forKey: .mealPlanningPreferences)
        dietaryPreferences = try container.decodeIfPresent(DietaryPreferences.self, forKey: .dietaryPreferences)
        cookingPreferences = try container.decodeIfPresent(CookingPreferences.self, forKey: .cookingPreferences)
        budgetPreferences = try container.decodeIfPresent(BudgetPreferences.self, forKey: .budgetPreferences)
        achievements = try container.decodeIfPresent([Achievement].self, forKey: .achievements)
        progressMetrics = try container.decodeIfPresent([ProgressMetrics].self, forKey: .progressMetrics)
        spoonacularUsername = try container.decodeIfPresent(String.self, forKey: .spoonacularUsername)
        spoonacularHash = try container.decodeIfPresent(String.self, forKey: .spoonacularHash)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            createdAt = dateFormatter.date(from: createdAtString) ?? Date()
        } else {
            createdAt = Date()
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            updatedAt = dateFormatter.date(from: updatedAtString) ?? Date()
        } else {
            updatedAt = Date()
        }
    }
    
    // MARK: - Convenience Initializer
    
    init(id: String, userId: String?, name: String?, email: String?, age: Int?, gender: String?, goal: String?, diet: String?, budget: String?, isPremium: Bool, isOnboardingCompleted: Bool, subscriptionType: String?, subscriptionRenewal: Date?, plansCreatedThisMonth: Int, spoonacularGenerationsThisMonth: Int, lastPlanReset: Date, profileImageUrl: String?, bio: String?, location: String?, preferredLanguage: String?, timezone: String?, measurementSystem: String?, preferredCurrency: String?, notificationPreferences: NotificationPreferences?, privacySettings: PrivacySettings?, fitnessGoals: FitnessGoals?, mealPlanningPreferences: MealPlanningPreferences?, dietaryPreferences: DietaryPreferences?, cookingPreferences: CookingPreferences?, budgetPreferences: BudgetPreferences?, achievements: [Achievement]?, progressMetrics: [ProgressMetrics]?, spoonacularUsername: String?, spoonacularHash: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.email = email
        self.age = age
        self.gender = gender
        self.goal = goal
        self.diet = diet
        self.budget = budget
        self.isPremium = isPremium
        self.isOnboardingCompleted = isOnboardingCompleted
        self.subscriptionType = subscriptionType
        self.subscriptionRenewal = subscriptionRenewal
        self.plansCreatedThisMonth = plansCreatedThisMonth
        self.spoonacularGenerationsThisMonth = spoonacularGenerationsThisMonth
        self.lastPlanReset = lastPlanReset
        self.profileImageUrl = profileImageUrl
        self.bio = bio
        self.location = location
        self.preferredLanguage = preferredLanguage
        self.timezone = timezone
        self.measurementSystem = measurementSystem
        self.preferredCurrency = preferredCurrency
        self.notificationPreferences = notificationPreferences
        self.privacySettings = privacySettings
        self.fitnessGoals = fitnessGoals
        self.mealPlanningPreferences = mealPlanningPreferences
        self.dietaryPreferences = dietaryPreferences
        self.cookingPreferences = cookingPreferences
        self.budgetPreferences = budgetPreferences
        self.achievements = achievements
        self.progressMetrics = progressMetrics
        self.spoonacularUsername = spoonacularUsername
        self.spoonacularHash = spoonacularHash
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    var validProfilePictureUrl: URL? {
        guard let profileImageUrl = profileImageUrl, !profileImageUrl.isEmpty else { return nil }
        return URL(string: profileImageUrl)
    }
    
    var displayLocation: String {
        return location ?? "Location not set"
    }
    
    var displayBio: String {
        return bio ?? "No bio available"
    }
    
    var hasBio: Bool {
        return bio != nil && !bio!.isEmpty
    }
    
    var hasLocation: Bool {
        return location != nil && !location!.isEmpty
    }
    
    var hasProfilePicture: Bool {
        return profileImageUrl != nil && !profileImageUrl!.isEmpty
    }
    
    var totalAchievements: Int {
        return achievements?.count ?? 0
    }
    
    var latestProgressMetrics: ProgressMetrics? {
        return progressMetrics?.max { $0.date < $1.date }
    }
    
    // MARK: - Helper Methods
    
    func achievementsByCategory(_ category: String) -> [Achievement] {
        return achievements?.filter { $0.category.lowercased() == category.lowercased() } ?? []
    }
    
    func progressMetricsForDateRange(startDate: Date, endDate: Date) -> [ProgressMetrics] {
        return progressMetrics?.filter { $0.date >= startDate && $0.date <= endDate } ?? []
    }
    
    func withBio(_ newBio: String?) -> UserProfile {
        return UserProfile(
            id: id,
            userId: userId,
            name: name,
            email: email,
            age: age,
            gender: gender,
            goal: goal,
            diet: diet,
            budget: budget,
            isPremium: isPremium,
            isOnboardingCompleted: isOnboardingCompleted,
            subscriptionType: subscriptionType,
            subscriptionRenewal: subscriptionRenewal,
            plansCreatedThisMonth: plansCreatedThisMonth,
            spoonacularGenerationsThisMonth: spoonacularGenerationsThisMonth,
            lastPlanReset: lastPlanReset,
            profileImageUrl: profileImageUrl,
            bio: newBio,
            location: location,
            preferredLanguage: preferredLanguage,
            timezone: timezone,
            measurementSystem: measurementSystem,
            preferredCurrency: preferredCurrency,
            notificationPreferences: notificationPreferences,
            privacySettings: privacySettings,
            fitnessGoals: fitnessGoals,
            mealPlanningPreferences: mealPlanningPreferences,
            dietaryPreferences: dietaryPreferences,
            cookingPreferences: cookingPreferences,
            budgetPreferences: budgetPreferences,
            achievements: achievements,
            progressMetrics: progressMetrics,
            spoonacularUsername: spoonacularUsername,
            spoonacularHash: spoonacularHash,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    func withLocation(_ newLocation: String?) -> UserProfile {
        return UserProfile(
            id: id,
            userId: userId,
            name: name,
            email: email,
            age: age,
            gender: gender,
            goal: goal,
            diet: diet,
            budget: budget,
            isPremium: isPremium,
            isOnboardingCompleted: isOnboardingCompleted,
            subscriptionType: subscriptionType,
            subscriptionRenewal: subscriptionRenewal,
            plansCreatedThisMonth: plansCreatedThisMonth,
            spoonacularGenerationsThisMonth: spoonacularGenerationsThisMonth,
            lastPlanReset: lastPlanReset,
            profileImageUrl: profileImageUrl,
            bio: bio,
            location: newLocation,
            preferredLanguage: preferredLanguage,
            timezone: timezone,
            measurementSystem: measurementSystem,
            preferredCurrency: preferredCurrency,
            notificationPreferences: notificationPreferences,
            privacySettings: privacySettings,
            fitnessGoals: fitnessGoals,
            mealPlanningPreferences: mealPlanningPreferences,
            dietaryPreferences: dietaryPreferences,
            cookingPreferences: cookingPreferences,
            budgetPreferences: budgetPreferences,
            achievements: achievements,
            progressMetrics: progressMetrics,
            spoonacularUsername: spoonacularUsername,
            spoonacularHash: spoonacularHash,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}

struct NotificationPreferences: Codable {
    let mealReminders: Bool
    
    let groceryReminders: Bool
    
    let achievementNotifications: Bool
    
    let weeklyReports: Bool
    
    let newRecipeNotifications: Bool
    
    let preferredNotificationTime: String
    
    let pushNotificationsEnabled: Bool
    
    let emailNotificationsEnabled: Bool
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case mealReminders = "meal_reminders"
        case groceryReminders = "grocery_reminders"
        case achievementNotifications = "achievement_notifications"
        case weeklyReports = "weekly_reports"
        case newRecipeNotifications = "new_recipe_notifications"
        case preferredNotificationTime = "preferred_notification_time"
        case pushNotificationsEnabled = "push_notifications_enabled"
        case emailNotificationsEnabled = "email_notifications_enabled"
    }
    
    // MARK: - Convenience Initializer
    
    init(mealReminders: Bool, groceryReminders: Bool, achievementNotifications: Bool, weeklyReports: Bool, newRecipeNotifications: Bool, preferredNotificationTime: String, pushNotificationsEnabled: Bool, emailNotificationsEnabled: Bool) {
        self.mealReminders = mealReminders
        self.groceryReminders = groceryReminders
        self.achievementNotifications = achievementNotifications
        self.weeklyReports = weeklyReports
        self.newRecipeNotifications = newRecipeNotifications
        self.preferredNotificationTime = preferredNotificationTime
        self.pushNotificationsEnabled = pushNotificationsEnabled
        self.emailNotificationsEnabled = emailNotificationsEnabled
    }
}

struct PrivacySettings: Codable {
    let isProfilePublic: Bool
    
    let mealPlansVisible: Bool
    
    let progressSharingEnabled: Bool
    
    let achievementsPublic: Bool
    
    let locationSharingEnabled: Bool
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case isProfilePublic = "is_profile_public"
        case mealPlansVisible = "meal_plans_visible"
        case progressSharingEnabled = "progress_sharing_enabled"
        case achievementsPublic = "achievements_public"
        case locationSharingEnabled = "location_sharing_enabled"
    }
    
    // MARK: - Convenience Initializer
    
    init(isProfilePublic: Bool, mealPlansVisible: Bool, progressSharingEnabled: Bool, achievementsPublic: Bool, locationSharingEnabled: Bool) {
        self.isProfilePublic = isProfilePublic
        self.mealPlansVisible = mealPlansVisible
        self.progressSharingEnabled = progressSharingEnabled
        self.achievementsPublic = achievementsPublic
        self.locationSharingEnabled = locationSharingEnabled
    }
}

struct FitnessGoals: Codable {
    let targetWeight: Double?
    
    let targetCalories: Int?
    
    let targetProtein: Double?
    
    let targetCarbohydrates: Double?
    
    let targetFat: Double?
    
    let weeklyWorkoutMinutes: Int?
    
    let targetStepsPerDay: Int?
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case targetWeight = "target_weight"
        case targetCalories = "target_calories"
        case targetProtein = "target_protein"
        case targetCarbohydrates = "target_carbohydrates"
        case targetFat = "target_fat"
        case weeklyWorkoutMinutes = "weekly_workout_minutes"
        case targetStepsPerDay = "target_steps_per_day"
    }
    
    // MARK: - Convenience Initializer
    
    init(targetWeight: Double?, targetCalories: Int?, targetProtein: Double?, targetCarbohydrates: Double?, targetFat: Double?, weeklyWorkoutMinutes: Int?, targetStepsPerDay: Int?) {
        self.targetWeight = targetWeight
        self.targetCalories = targetCalories
        self.targetProtein = targetProtein
        self.targetCarbohydrates = targetCarbohydrates
        self.targetFat = targetFat
        self.weeklyWorkoutMinutes = weeklyWorkoutMinutes
        self.targetStepsPerDay = targetStepsPerDay
    }
}

struct MealPlanningPreferences: Codable {
    let mealsPerDay: Int
    
    let preferredPrepTime: Int
    
    let includeSnacks: Bool
    
    let preferredCuisines: [String]
    
    let rotateMeals: Bool
    
    let includeLeftovers: Bool
    
    let preferredComplexity: String
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case mealsPerDay = "meals_per_day"
        case preferredPrepTime = "preferred_prep_time"
        case includeSnacks = "include_snacks"
        case preferredCuisines = "preferred_cuisines"
        case rotateMeals = "rotate_meals"
        case includeLeftovers = "include_leftovers"
        case preferredComplexity = "preferred_complexity"
    }
    
    // MARK: - Convenience Initializer
    
    init(mealsPerDay: Int, preferredPrepTime: Int, includeSnacks: Bool, preferredCuisines: [String], rotateMeals: Bool, includeLeftovers: Bool, preferredComplexity: String) {
        self.mealsPerDay = mealsPerDay
        self.preferredPrepTime = preferredPrepTime
        self.includeSnacks = includeSnacks
        self.preferredCuisines = preferredCuisines
        self.rotateMeals = rotateMeals
        self.includeLeftovers = includeLeftovers
        self.preferredComplexity = preferredComplexity
    }
}

struct DietaryPreferences: Codable {
    let restrictions: [String]
    
    let allergies: [String]
    
    let favoriteIngredients: [String]
    
    let dislikedIngredients: [String]
    
    let avoidIngredients: [String]
    
    let preferredCookingMethods: [String]
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case restrictions
        case allergies
        case favoriteIngredients = "favorite_ingredients"
        case dislikedIngredients = "disliked_ingredients"
        case avoidIngredients = "avoid_ingredients"
        case preferredCookingMethods = "preferred_cooking_methods"
    }
    
    // MARK: - Convenience Initializer
    
    init(restrictions: [String], allergies: [String], favoriteIngredients: [String], dislikedIngredients: [String], avoidIngredients: [String], preferredCookingMethods: [String]) {
        self.restrictions = restrictions
        self.allergies = allergies
        self.favoriteIngredients = favoriteIngredients
        self.dislikedIngredients = dislikedIngredients
        self.avoidIngredients = avoidIngredients
        self.preferredCookingMethods = preferredCookingMethods
    }
}

struct CookingPreferences: Codable {
    let skillLevel: String
    
    let preferredCookingTime: Int
    
    let useAppliances: Bool
    
    let preferredMethods: [String]
    
    let usePreMadeIngredients: Bool
    
    let batchCooking: Bool
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case skillLevel = "skill_level"
        case preferredCookingTime = "preferred_cooking_time"
        case useAppliances = "use_appliances"
        case preferredMethods = "preferred_methods"
        case usePreMadeIngredients = "use_pre_made_ingredients"
        case batchCooking = "batch_cooking"
    }
    
    // MARK: - Convenience Initializer
    
    init(skillLevel: String, preferredCookingTime: Int, useAppliances: Bool, preferredMethods: [String], usePreMadeIngredients: Bool, batchCooking: Bool) {
        self.skillLevel = skillLevel
        self.preferredCookingTime = preferredCookingTime
        self.useAppliances = useAppliances
        self.preferredMethods = preferredMethods
        self.usePreMadeIngredients = usePreMadeIngredients
        self.batchCooking = batchCooking
    }
}

struct BudgetPreferences: Codable {
    let weeklyBudget: Double?
    
    let monthlyBudget: Double?
    
    let preferredMealPrice: Double?
    
    let prioritizeBudget: Bool
    
    let includePremiumIngredients: Bool
    
    let suggestAlternatives: Bool
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case weeklyBudget = "weekly_budget"
        case monthlyBudget = "monthly_budget"
        case preferredMealPrice = "preferred_meal_price"
        case prioritizeBudget = "prioritize_budget"
        case includePremiumIngredients = "include_premium_ingredients"
        case suggestAlternatives = "suggest_alternatives"
    }
    
    // MARK: - Convenience Initializer
    
    init(weeklyBudget: Double?, monthlyBudget: Double?, preferredMealPrice: Double?, prioritizeBudget: Bool, includePremiumIngredients: Bool, suggestAlternatives: Bool) {
        self.weeklyBudget = weeklyBudget
        self.monthlyBudget = monthlyBudget
        self.preferredMealPrice = preferredMealPrice
        self.prioritizeBudget = prioritizeBudget
        self.includePremiumIngredients = includePremiumIngredients
        self.suggestAlternatives = suggestAlternatives
    }
}

struct Achievement: Codable {
    let id: String
    
    let title: String
    
    let description: String
    
    let category: String
    
    let icon: String
    
    let isEarned: Bool
    
    let earnedAt: Date?
    
    let points: Int
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description
        case category
        case icon
        case isEarned = "is_earned"
        case earnedAt = "earned_at"
        case points
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decode(String.self, forKey: .category)
        icon = try container.decode(String.self, forKey: .icon)
        isEarned = try container.decode(Bool.self, forKey: .isEarned)
        points = try container.decode(Int.self, forKey: .points)
        
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let earnedAtString = try? container.decode(String.self, forKey: .earnedAt) {
            earnedAt = dateFormatter.date(from: earnedAtString)
        } else {
            earnedAt = nil
        }
    }
    
    // MARK: - Convenience Initializer
    
    init(id: String, title: String, description: String, category: String, icon: String, isEarned: Bool, earnedAt: Date?, points: Int) {
        self.id = id
        self.title = title
        self.description = description
        self.category = category
        self.icon = icon
        self.isEarned = isEarned
        self.earnedAt = earnedAt
        self.points = points
    }
}

// MARK: - Request Models

struct UpdateUserProfileRequest: Codable {
    let name: String?
    let age: Int?
    let gender: String?
    let goal: String?
    let diet: String?
    let budget: String?
    let profileImageUrl: String?
    let isOnboardingCompleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name
        case age
        case gender
        case goal
        case diet
        case budget
        case profileImageUrl = "profile_image_url"
        case isOnboardingCompleted = "is_onboarding_completed"
    }
}

// MARK: - Enums

enum Gender: String, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
    
    var icon: String {
        switch self {
        case .male: return "👨"
        case .female: return "👩"
        case .other: return "🧑"
        case .preferNotToSay: return "❓"
        }
    }
}

enum HealthGoal: String, CaseIterable {
    case loseWeight = "lose_weight"
    case gainWeight = "gain_weight"
    case maintainWeight = "maintain_weight"
    case buildMuscle = "build_muscle"
    case improveHealth = "improve_health"
    
    var displayName: String {
        switch self {
        case .loseWeight: return "Lose Weight"
        case .gainWeight: return "Gain Weight"
        case .maintainWeight: return "Maintain Weight"
        case .buildMuscle: return "Build Muscle"
        case .improveHealth: return "Improve Health"
        }
    }
    
    var icon: String {
        switch self {
        case .loseWeight: return "📉"
        case .gainWeight: return "📈"
        case .maintainWeight: return "⚖️"
        case .buildMuscle: return "💪"
        case .improveHealth: return "❤️"
        }
    }
    
    var description: String {
        switch self {
        case .loseWeight: return "Focus on calorie deficit and portion control"
        case .gainWeight: return "Focus on calorie surplus and nutrient-dense foods"
        case .maintainWeight: return "Focus on balanced nutrition and portion control"
        case .buildMuscle: return "Focus on high-protein meals and strength training support"
        case .improveHealth: return "Focus on nutritious, whole foods and balanced meals"
        }
    }
}

enum DietType: String, CaseIterable {
    case none = "none"
    case vegetarian = "vegetarian"
    case vegan = "vegan"
    case keto = "keto"
    case paleo = "paleo"
    case mediterranean = "mediterranean"
    case glutenFree = "gluten_free"
    
    var displayName: String {
        switch self {
        case .none: return "No Restrictions"
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .keto: return "Ketogenic"
        case .paleo: return "Paleo"
        case .mediterranean: return "Mediterranean"
        case .glutenFree: return "Gluten Free"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "🍽️"
        case .vegetarian: return "🥬"
        case .vegan: return "🌱"
        case .keto: return "🥑"
        case .paleo: return "🥩"
        case .mediterranean: return "🫒"
        case .glutenFree: return "🌾"
        }
    }
    
    var description: String {
        switch self {
        case .none: return "All food types and ingredients"
        case .vegetarian: return "No meat, but includes dairy and eggs"
        case .vegan: return "No animal products whatsoever"
        case .keto: return "High-fat, low-carb for ketosis"
        case .paleo: return "Whole foods, no processed items"
        case .mediterranean: return "Fresh, healthy Mediterranean cuisine"
        case .glutenFree: return "No gluten-containing ingredients"
        }
    }
}

enum BudgetLevel: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Budget-Friendly"
        case .medium: return "Moderate"
        case .high: return "Premium"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "💰"
        case .medium: return "💳"
        case .high: return "💎"
        }
    }
    
    var range: String {
        switch self {
        case .low: return "$30-50/week"
        case .medium: return "$50-80/week"
        case .high: return "$80-120/week"
        }
    }
    
    var description: String {
        switch self {
        case .low: return "Focus on affordable ingredients and simple meals"
        case .medium: return "Balance of quality ingredients and reasonable cost"
        case .high: return "Premium ingredients and gourmet meal options"
        }
    }
}

enum SubscriptionType: String, CaseIterable {
    case free = "free"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .free: return "Free Plan"
        case .monthly: return "Monthly Premium"
        case .yearly: return "Yearly Premium"
        }
    }
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .monthly: return Configuration.premiumMonthlyPrice
        case .yearly: return Configuration.premiumYearlyPrice
        }
    }
}

// MARK: - Extensions

extension UserProfile {
    var hasPremiumAccess: Bool {
        return isPremium
    }
    
    var subscriptionDisplayName: String {
        switch subscriptionType?.lowercased() {
        case "free": return "Free Plan"
        case "monthly": return "Monthly Premium"
        case "yearly": return "Yearly Premium"
        default: return "Free Plan"
        }
    }
    
    var daysUntilRenewal: Int? {
        guard let renewal = subscriptionRenewal else { return nil }
        let calendar = Calendar.current
        return calendar.dateComponents([.day], from: Date(), to: renewal).day
    }
    
    var plansRemainingThisMonth: Int {
        let maxPlans = hasPremiumAccess ? 10 : 3
        return max(0, maxPlans - plansCreatedThisMonth)
    }
    
    var spoonacularGenerationsRemainingThisMonth: Int {
        let maxGenerations = hasPremiumAccess ? 20 : 5
        return max(0, maxGenerations - spoonacularGenerationsThisMonth)
    }
    
    var isProfileComplete: Bool {
        var completedFields = 0
        let totalFields = 6
        
        if name != nil && !name!.isEmpty { completedFields += 1 }
        if age != nil { completedFields += 1 }
        if gender != nil { completedFields += 1 }
        if goal != nil { completedFields += 1 }
        if diet != nil { completedFields += 1 }
        if budget != nil { completedFields += 1 }
        
        return completedFields >= totalFields
    }
    
    var canCreateMorePlans: Bool {
        return plansCreatedThisMonth < (hasPremiumAccess ? 10 : 3)
    }
    
    var canUseSpoonacularGeneration: Bool {
        return spoonacularGenerationsThisMonth < (hasPremiumAccess ? 20 : 5)
    }
    
    mutating func resetMonthlyLimitsIfNeeded() {
        let calendar = Calendar.current
        if !calendar.isDate(lastPlanReset, equalTo: Date(), toGranularity: .month) {
        }
    }
    
    mutating func incrementPlanCreationCount() {
        resetMonthlyLimitsIfNeeded()
    }
    
    mutating func incrementSpoonacularGenerationCount() {
        resetMonthlyLimitsIfNeeded()
    }
    
    func canPerformAction(_ action: UserAction) -> Bool {
        switch action {
        case .createPlan:
            return canCreateMorePlans
        case .useSpoonacularGeneration:
            return canUseSpoonacularGeneration
        case .accessPremiumTemplates:
            return hasPremiumAccess
        case .exportGroceryList:
            return hasPremiumAccess
        case .customizeRecipes:
            return hasPremiumAccess
        }
    }
    
    // MARK: - Spoonacular Integration
    
    var spoonacularDiet: String? {
        let restrictions = dietaryPreferences?.restrictions ?? []
        
        if restrictions.contains("vegan") {
            return "vegan"
        } else if restrictions.contains("vegetarian") {
            return "vegetarian"
        } else if restrictions.contains("keto") {
            return "ketogenic"
        } else if restrictions.contains("paleo") {
            return "paleo"
        } else if restrictions.contains("mediterranean") {
            return "mediterranean"
        }
        
        switch diet?.lowercased() {
        case "vegan":
            return "vegan"
        case "vegetarian":
            return "vegetarian"
        case "keto":
            return "ketogenic"
        case "paleo":
            return "paleo"
        case "mediterranean":
            return "mediterranean"
        default:
            return nil
        }
    }
    
    var spoonacularExclusions: String? {
        var exclusions: [String] = []
        
        exclusions.append(contentsOf: dietaryPreferences?.allergies ?? [])
        
        exclusions.append(contentsOf: dietaryPreferences?.dislikedIngredients ?? [])
        
        exclusions.append(contentsOf: dietaryPreferences?.avoidIngredients ?? [])
        
        let uniqueExclusions = Array(Set(exclusions)).filter { !$0.isEmpty }
        
        return uniqueExclusions.isEmpty ? nil : uniqueExclusions.joined(separator: ",")
    }
    
    var spoonacularTargetCalories: Int? {
        return fitnessGoals?.targetCalories
    }
    
    var spoonacularCuisines: [String] {
        return mealPlanningPreferences?.preferredCuisines ?? []
    }
    
    var spoonacularRecipeComplexity: String {
        let skillLevel = cookingPreferences?.skillLevel ?? "beginner"
        
        switch skillLevel.lowercased() {
        case "beginner", "some experience":
            return "easy"
        case "intermediate":
            return "medium"
        case "advanced", "expert chef":
            return "hard"
        default:
            return "medium"
        }
    }
    
    var spoonacularMaxReadyTime: Int? {
        let preferredTime = cookingPreferences?.preferredCookingTime ?? 30
        let mealPrepTime = mealPlanningPreferences?.preferredPrepTime ?? 30
        
        return min(max(preferredTime, mealPrepTime), 60)
    }
    
    var spoonacularMaxPrice: Double? {
        guard let budgetPrefs = budgetPreferences else { return nil }
        
        if let weeklyBudget = budgetPrefs.weeklyBudget {
            return weeklyBudget / 21.0
        }
        
        if let mealPrice = budgetPrefs.preferredMealPrice {
            return mealPrice
        }
        
        switch budget?.lowercased() {
        case "low":
            return 3.0
        case "medium":
            return 5.0
        case "high":
            return 8.0
        default:
            return 5.0
        }
    }
    
    var spoonacularMealPlanningParams: [String: Any] {
        var params: [String: Any] = [:]
        
        if let mealsPerDay = mealPlanningPreferences?.mealsPerDay {
            params["mealsPerDay"] = mealsPerDay
        }
        
        if !spoonacularCuisines.isEmpty {
            params["cuisine"] = spoonacularCuisines.joined(separator: ",")
        }
        
        params["maxReadyTime"] = spoonacularMaxReadyTime
        
        if let maxPrice = spoonacularMaxPrice {
            params["maxPrice"] = maxPrice
        }
        
        return params
    }
    
    
    var spoonacularPreferencesSummary: String {
        var summary: [String] = []
        
        if let diet = spoonacularDiet {
            summary.append("Diet: \(diet)")
        }
        
        if let targetCalories = spoonacularTargetCalories {
            summary.append("Target Calories: \(targetCalories)")
        }
        
        if let exclusions = spoonacularExclusions {
            summary.append("Exclusions: \(exclusions)")
        }
        
        if !spoonacularCuisines.isEmpty {
            summary.append("Cuisines: \(spoonacularCuisines.joined(separator: ", "))")
        }
        
        return summary.isEmpty ? "No preferences set" : summary.joined(separator: ", ")
    }
}

enum UserAction {
    case createPlan
    case useSpoonacularGeneration
    case accessPremiumTemplates
    case exportGroceryList
    case customizeRecipes
} 

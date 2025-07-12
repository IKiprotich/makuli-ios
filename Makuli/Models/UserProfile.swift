//
//  UserProfile.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready user profile model for Supabase database.
//

import Foundation

/**
 * UserProfile Model
 * 
 * Represents extended user profile information and preferences.
 * This model contains additional user data beyond basic authentication information.
 * 
 * Key Features:
 * - Extended user preferences and settings
 * - Fitness and health tracking data
 * - Meal planning preferences and history
 * - Achievement and progress tracking
 * - Notification and privacy settings
 * 
 * Database Relationships:
 * - Belongs to a User (one-to-one relationship)
 * - Can have multiple progress metrics
 * - Can have multiple achievements
 */
struct UserProfile: Identifiable, Codable {
    /// Unique identifier for the user profile
    let id: String
    
    /// Reference to the user this profile belongs to
    let userId: String
    
    /// User's profile picture URL
    let profilePictureUrl: String?
    
    /// User's bio or description
    let bio: String?
    
    /// User's location/city
    let location: String?
    
    /// User's preferred language
    let preferredLanguage: String
    
    /// User's timezone
    let timezone: String
    
    /// User's preferred measurement system (Metric, Imperial)
    let measurementSystem: String
    
    /// User's preferred currency
    let preferredCurrency: String
    
    /// User's notification preferences
    let notificationPreferences: NotificationPreferences
    
    /// User's privacy settings
    let privacySettings: PrivacySettings
    
    /// User's fitness goals and targets
    let fitnessGoals: FitnessGoals
    
    /// User's meal planning preferences
    let mealPlanningPreferences: MealPlanningPreferences
    
    /// User's dietary restrictions and preferences
    let dietaryPreferences: DietaryPreferences
    
    /// User's cooking experience and preferences
    let cookingPreferences: CookingPreferences
    
    /// User's budget and cost preferences
    let budgetPreferences: BudgetPreferences
    
    /// User's achievement and progress data
    let achievements: [Achievement]
    
    /// User's progress metrics over time
    let progressMetrics: [ProgressMetrics]
    
    /// Timestamp when the profile was created
    let createdAt: Date
    
    /// Timestamp when the profile was last updated
    let updatedAt: Date
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case profilePictureUrl = "profile_picture_url"
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
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        profilePictureUrl = try container.decodeIfPresent(String.self, forKey: .profilePictureUrl)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        preferredLanguage = try container.decode(String.self, forKey: .preferredLanguage)
        timezone = try container.decode(String.self, forKey: .timezone)
        measurementSystem = try container.decode(String.self, forKey: .measurementSystem)
        preferredCurrency = try container.decode(String.self, forKey: .preferredCurrency)
        notificationPreferences = try container.decode(NotificationPreferences.self, forKey: .notificationPreferences)
        privacySettings = try container.decode(PrivacySettings.self, forKey: .privacySettings)
        fitnessGoals = try container.decode(FitnessGoals.self, forKey: .fitnessGoals)
        mealPlanningPreferences = try container.decode(MealPlanningPreferences.self, forKey: .mealPlanningPreferences)
        dietaryPreferences = try container.decode(DietaryPreferences.self, forKey: .dietaryPreferences)
        cookingPreferences = try container.decode(CookingPreferences.self, forKey: .cookingPreferences)
        budgetPreferences = try container.decode(BudgetPreferences.self, forKey: .budgetPreferences)
        achievements = try container.decode([Achievement].self, forKey: .achievements)
        progressMetrics = try container.decode([ProgressMetrics].self, forKey: .progressMetrics)
        
        // Handle date decoding with ISO8601 format
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
    
    /**
     * Creates a new UserProfile instance
     * 
     * - Parameters:
     *   - id: Unique identifier
     *   - userId: Reference to the user
     *   - profilePictureUrl: Optional profile picture URL
     *   - bio: Optional bio text
     *   - location: Optional location
     *   - preferredLanguage: Preferred language
     *   - timezone: User's timezone
     *   - measurementSystem: Preferred measurement system
     *   - preferredCurrency: Preferred currency
     *   - notificationPreferences: Notification settings
     *   - privacySettings: Privacy settings
     *   - fitnessGoals: Fitness goals
     *   - mealPlanningPreferences: Meal planning preferences
     *   - dietaryPreferences: Dietary preferences
     *   - cookingPreferences: Cooking preferences
     *   - budgetPreferences: Budget preferences
     *   - achievements: Array of achievements
     *   - progressMetrics: Array of progress metrics
     *   - createdAt: Creation timestamp
     *   - updatedAt: Last update timestamp
     */
    init(id: String, userId: String, profilePictureUrl: String?, bio: String?, location: String?, preferredLanguage: String, timezone: String, measurementSystem: String, preferredCurrency: String, notificationPreferences: NotificationPreferences, privacySettings: PrivacySettings, fitnessGoals: FitnessGoals, mealPlanningPreferences: MealPlanningPreferences, dietaryPreferences: DietaryPreferences, cookingPreferences: CookingPreferences, budgetPreferences: BudgetPreferences, achievements: [Achievement], progressMetrics: [ProgressMetrics], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.profilePictureUrl = profilePictureUrl
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
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    /**
     * Validated profile picture URL that can be safely loaded
     * 
     * - Returns: URL if valid, nil otherwise
     */
    var validProfilePictureUrl: URL? {
        guard let profilePictureUrl = profilePictureUrl, !profilePictureUrl.isEmpty else { return nil }
        return URL(string: profilePictureUrl)
    }
    
    /**
     * Display name for the profile
     * 
     * - Returns: Location if available, otherwise "Location not set"
     */
    var displayLocation: String {
        return location ?? "Location not set"
    }
    
    /**
     * Display bio for the profile
     * 
     * - Returns: Bio if available, otherwise "No bio available"
     */
    var displayBio: String {
        return bio ?? "No bio available"
    }
    
    /**
     * Whether the profile has a bio
     * 
     * - Returns: True if bio is not empty
     */
    var hasBio: Bool {
        return bio != nil && !bio!.isEmpty
    }
    
    /**
     * Whether the profile has a location
     * 
     * - Returns: True if location is set
     */
    var hasLocation: Bool {
        return location != nil && !location!.isEmpty
    }
    
    /**
     * Whether the profile has a profile picture
     * 
     * - Returns: True if profile picture URL is set
     */
    var hasProfilePicture: Bool {
        return profilePictureUrl != nil && !profilePictureUrl!.isEmpty
    }
    
    /**
     * Total number of achievements earned
     * 
     * - Returns: Count of earned achievements
     */
    var totalAchievements: Int {
        return achievements.count
    }
    
    /**
     * Latest progress metrics
     * 
     * - Returns: Most recent progress metrics or nil
     */
    var latestProgressMetrics: ProgressMetrics? {
        return progressMetrics.max { $0.date < $1.date }
    }
    
    // MARK: - Helper Methods
    
    /**
     * Gets achievements by category
     * 
     * - Parameter category: The achievement category to filter by
     * - Returns: Array of achievements in the specified category
     */
    func achievementsByCategory(_ category: String) -> [Achievement] {
        return achievements.filter { $0.category.lowercased() == category.lowercased() }
    }
    
    /**
     * Gets progress metrics for a specific date range
     * 
     * - Parameters:
     *   - startDate: Start date for the range
     *   - endDate: End date for the range
     * - Returns: Array of progress metrics within the date range
     */
    func progressMetricsForDateRange(startDate: Date, endDate: Date) -> [ProgressMetrics] {
        return progressMetrics.filter { $0.date >= startDate && $0.date <= endDate }
    }
    
    /**
     * Creates a copy of this profile with updated bio
     * 
     * - Parameter newBio: New bio text
     * - Returns: New UserProfile instance with updated bio
     */
    func withBio(_ newBio: String?) -> UserProfile {
        return UserProfile(
            id: id,
            userId: userId,
            profilePictureUrl: profilePictureUrl,
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
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    /**
     * Creates a copy of this profile with updated location
     * 
     * - Parameter newLocation: New location
     * - Returns: New UserProfile instance with updated location
     */
    func withLocation(_ newLocation: String?) -> UserProfile {
        return UserProfile(
            id: id,
            userId: userId,
            profilePictureUrl: profilePictureUrl,
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
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}

/**
 * NotificationPreferences Model
 * 
 * Represents user's notification preferences and settings.
 */
struct NotificationPreferences: Codable {
    /// Whether meal reminders are enabled
    let mealReminders: Bool
    
    /// Whether grocery list reminders are enabled
    let groceryReminders: Bool
    
    /// Whether achievement notifications are enabled
    let achievementNotifications: Bool
    
    /// Whether weekly progress reports are enabled
    let weeklyReports: Bool
    
    /// Whether new recipe notifications are enabled
    let newRecipeNotifications: Bool
    
    /// Preferred notification time (24-hour format)
    let preferredNotificationTime: String
    
    /// Whether push notifications are enabled
    let pushNotificationsEnabled: Bool
    
    /// Whether email notifications are enabled
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
    
    /**
     * Creates a new NotificationPreferences instance
     * 
     * - Parameters:
     *   - mealReminders: Whether meal reminders are enabled
     *   - groceryReminders: Whether grocery reminders are enabled
     *   - achievementNotifications: Whether achievement notifications are enabled
     *   - weeklyReports: Whether weekly reports are enabled
     *   - newRecipeNotifications: Whether new recipe notifications are enabled
     *   - preferredNotificationTime: Preferred notification time
     *   - pushNotificationsEnabled: Whether push notifications are enabled
     *   - emailNotificationsEnabled: Whether email notifications are enabled
     */
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

/**
 * PrivacySettings Model
 * 
 * Represents user's privacy settings and preferences.
 */
struct PrivacySettings: Codable {
    /// Whether profile is public
    let isProfilePublic: Bool
    
    /// Whether meal plans are visible to others
    let mealPlansVisible: Bool
    
    /// Whether progress is shared with friends
    let progressSharingEnabled: Bool
    
    /// Whether achievements are public
    let achievementsPublic: Bool
    
    /// Whether location is shared
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
    
    /**
     * Creates a new PrivacySettings instance
     * 
     * - Parameters:
     *   - isProfilePublic: Whether profile is public
     *   - mealPlansVisible: Whether meal plans are visible
     *   - progressSharingEnabled: Whether progress sharing is enabled
     *   - achievementsPublic: Whether achievements are public
     *   - locationSharingEnabled: Whether location sharing is enabled
     */
    init(isProfilePublic: Bool, mealPlansVisible: Bool, progressSharingEnabled: Bool, achievementsPublic: Bool, locationSharingEnabled: Bool) {
        self.isProfilePublic = isProfilePublic
        self.mealPlansVisible = mealPlansVisible
        self.progressSharingEnabled = progressSharingEnabled
        self.achievementsPublic = achievementsPublic
        self.locationSharingEnabled = locationSharingEnabled
    }
}

/**
 * FitnessGoals Model
 * 
 * Represents user's fitness goals and targets.
 */
struct FitnessGoals: Codable {
    /// Target weight in kilograms
    let targetWeight: Double?
    
    /// Target daily calorie intake
    let targetCalories: Int?
    
    /// Target protein intake in grams
    let targetProtein: Double?
    
    /// Target carbohydrate intake in grams
    let targetCarbohydrates: Double?
    
    /// Target fat intake in grams
    let targetFat: Double?
    
    /// Weekly workout goal in minutes
    let weeklyWorkoutMinutes: Int?
    
    /// Target steps per day
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
    
    /**
     * Creates a new FitnessGoals instance
     * 
     * - Parameters:
     *   - targetWeight: Target weight in kilograms
     *   - targetCalories: Target daily calorie intake
     *   - targetProtein: Target protein intake in grams
     *   - targetCarbohydrates: Target carbohydrate intake in grams
     *   - targetFat: Target fat intake in grams
     *   - weeklyWorkoutMinutes: Weekly workout goal in minutes
     *   - targetStepsPerDay: Target steps per day
     */
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

/**
 * MealPlanningPreferences Model
 * 
 * Represents user's meal planning preferences and settings.
 */
struct MealPlanningPreferences: Codable {
    /// Preferred number of meals per day
    let mealsPerDay: Int
    
    /// Preferred meal prep time in minutes
    let preferredPrepTime: Int
    
    /// Whether to include snacks
    let includeSnacks: Bool
    
    /// Preferred cuisine types
    let preferredCuisines: [String]
    
    /// Whether to rotate meals
    let rotateMeals: Bool
    
    /// Whether to include leftovers
    let includeLeftovers: Bool
    
    /// Preferred meal complexity (Easy, Medium, Hard)
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
    
    /**
     * Creates a new MealPlanningPreferences instance
     * 
     * - Parameters:
     *   - mealsPerDay: Preferred number of meals per day
     *   - preferredPrepTime: Preferred meal prep time in minutes
     *   - includeSnacks: Whether to include snacks
     *   - preferredCuisines: Array of preferred cuisine types
     *   - rotateMeals: Whether to rotate meals
     *   - includeLeftovers: Whether to include leftovers
     *   - preferredComplexity: Preferred meal complexity
     */
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

/**
 * DietaryPreferences Model
 * 
 * Represents user's dietary preferences and restrictions.
 */
struct DietaryPreferences: Codable {
    /// Dietary restrictions (e.g., ["Vegetarian", "Gluten-Free"])
    let restrictions: [String]
    
    /// Allergies and intolerances
    let allergies: [String]
    
    /// Favorite ingredients
    let favoriteIngredients: [String]
    
    /// Disliked ingredients
    let dislikedIngredients: [String]
    
    /// Whether to avoid certain ingredients
    let avoidIngredients: [String]
    
    /// Preferred cooking methods
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
    
    /**
     * Creates a new DietaryPreferences instance
     * 
     * - Parameters:
     *   - restrictions: Array of dietary restrictions
     *   - allergies: Array of allergies and intolerances
     *   - favoriteIngredients: Array of favorite ingredients
     *   - dislikedIngredients: Array of disliked ingredients
     *   - avoidIngredients: Array of ingredients to avoid
     *   - preferredCookingMethods: Array of preferred cooking methods
     */
    init(restrictions: [String], allergies: [String], favoriteIngredients: [String], dislikedIngredients: [String], avoidIngredients: [String], preferredCookingMethods: [String]) {
        self.restrictions = restrictions
        self.allergies = allergies
        self.favoriteIngredients = favoriteIngredients
        self.dislikedIngredients = dislikedIngredients
        self.avoidIngredients = avoidIngredients
        self.preferredCookingMethods = preferredCookingMethods
    }
}

/**
 * CookingPreferences Model
 * 
 * Represents user's cooking preferences and experience level.
 */
struct CookingPreferences: Codable {
    /// Cooking skill level (Beginner, Intermediate, Advanced)
    let skillLevel: String
    
    /// Preferred cooking time in minutes
    let preferredCookingTime: Int
    
    /// Whether to use kitchen appliances
    let useAppliances: Bool
    
    /// Preferred cooking methods
    let preferredMethods: [String]
    
    /// Whether to use pre-made ingredients
    let usePreMadeIngredients: Bool
    
    /// Whether to batch cook
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
    
    /**
     * Creates a new CookingPreferences instance
     * 
     * - Parameters:
     *   - skillLevel: Cooking skill level
     *   - preferredCookingTime: Preferred cooking time in minutes
     *   - useAppliances: Whether to use kitchen appliances
     *   - preferredMethods: Array of preferred cooking methods
     *   - usePreMadeIngredients: Whether to use pre-made ingredients
     *   - batchCooking: Whether to batch cook
     */
    init(skillLevel: String, preferredCookingTime: Int, useAppliances: Bool, preferredMethods: [String], usePreMadeIngredients: Bool, batchCooking: Bool) {
        self.skillLevel = skillLevel
        self.preferredCookingTime = preferredCookingTime
        self.useAppliances = useAppliances
        self.preferredMethods = preferredMethods
        self.usePreMadeIngredients = usePreMadeIngredients
        self.batchCooking = batchCooking
    }
}

/**
 * BudgetPreferences Model
 * 
 * Represents user's budget preferences and cost constraints.
 */
struct BudgetPreferences: Codable {
    /// Weekly budget for groceries
    let weeklyBudget: Double?
    
    /// Monthly budget for groceries
    let monthlyBudget: Double?
    
    /// Preferred price range per meal
    let preferredMealPrice: Double?
    
    /// Whether to prioritize budget-friendly recipes
    let prioritizeBudget: Bool
    
    /// Whether to include premium ingredients
    let includePremiumIngredients: Bool
    
    /// Whether to suggest budget alternatives
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
    
    /**
     * Creates a new BudgetPreferences instance
     * 
     * - Parameters:
     *   - weeklyBudget: Weekly budget for groceries
     *   - monthlyBudget: Monthly budget for groceries
     *   - preferredMealPrice: Preferred price range per meal
     *   - prioritizeBudget: Whether to prioritize budget-friendly recipes
     *   - includePremiumIngredients: Whether to include premium ingredients
     *   - suggestAlternatives: Whether to suggest budget alternatives
     */
    init(weeklyBudget: Double?, monthlyBudget: Double?, preferredMealPrice: Double?, prioritizeBudget: Bool, includePremiumIngredients: Bool, suggestAlternatives: Bool) {
        self.weeklyBudget = weeklyBudget
        self.monthlyBudget = monthlyBudget
        self.preferredMealPrice = preferredMealPrice
        self.prioritizeBudget = prioritizeBudget
        self.includePremiumIngredients = includePremiumIngredients
        self.suggestAlternatives = suggestAlternatives
    }
}

/**
 * Achievement Model
 * 
 * Represents a user achievement or milestone.
 */
struct Achievement: Codable {
    /// Unique identifier for the achievement
    let id: String
    
    /// Achievement title
    let title: String
    
    /// Achievement description
    let description: String
    
    /// Achievement category
    let category: String
    
    /// Achievement icon or emoji
    let icon: String
    
    /// Whether the achievement has been earned
    let isEarned: Bool
    
    /// Date when the achievement was earned
    let earnedAt: Date?
    
    /// Achievement points or value
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
        
        // Handle date decoding with ISO8601 format
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let earnedAtString = try? container.decode(String.self, forKey: .earnedAt) {
            earnedAt = dateFormatter.date(from: earnedAtString)
        } else {
            earnedAt = nil
        }
    }
    
    // MARK: - Convenience Initializer
    
    /**
     * Creates a new Achievement instance
     * 
     * - Parameters:
     *   - id: Unique identifier
     *   - title: Achievement title
     *   - description: Achievement description
     *   - category: Achievement category
     *   - icon: Achievement icon
     *   - isEarned: Whether achievement is earned
     *   - earnedAt: Date when earned
     *   - points: Achievement points
     */
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
    /// Check if user needs to reset monthly limits
    mutating func resetMonthlyLimitsIfNeeded() {
        let calendar = Calendar.current
        if !calendar.isDate(lastPlanReset, equalTo: Date(), toGranularity: .month) {
            plansCreatedThisMonth = 0
            aiGenerationsThisMonth = 0
            lastPlanReset = Date()
        }
    }
    
    /// Increment plan creation count
    mutating func incrementPlanCreationCount() {
        resetMonthlyLimitsIfNeeded()
        plansCreatedThisMonth += 1
    }
    
    /// Increment AI generation count
    mutating func incrementAIGenerationCount() {
        resetMonthlyLimitsIfNeeded()
        aiGenerationsThisMonth += 1
    }
    
    /// Check if user can perform action based on subscription
    func canPerformAction(_ action: UserAction) -> Bool {
        switch action {
        case .createPlan:
            return canCreateMorePlans
        case .useAIGeneration:
            return canUseAIGeneration
        case .accessPremiumTemplates:
            return hasPremiumAccess
        case .exportGroceryList:
            return hasPremiumAccess
        case .customizeRecipes:
            return hasPremiumAccess
        }
    }
}

enum UserAction {
    case createPlan
    case useAIGeneration
    case accessPremiumTemplates
    case exportGroceryList
    case customizeRecipes
} 
//
//  MealPlanTemplate.swift
//  Makuli
//
//  Created by Ian on 2025-01-08.
//
//  Models for meal plan templates stored in Supabase database.
//

import Foundation

/**
 * MealPlanTemplate Model
 * 
 * Represents a template for generating meal plans with predefined preferences and settings.
 * This model allows users to create reusable templates that can be used to generate
 * consistent meal plans with specific dietary, budget, and preference constraints.
 * 
 * Key Features:
 * - Predefined meal planning preferences
 * - Dietary restrictions and preferences
 * - Budget and cost constraints
 * - Meal variety and rotation settings
 * - Template categorization and organization
 * 
 * Database Relationships:
 * - Belongs to a User (via user_id)
 * - Can be used to generate multiple Plans
 * - Contains predefined preferences and settings
 */
struct MealPlanTemplate: Identifiable, Codable {
    /// Unique identifier for the meal plan template
    let id: String
    
    /// Reference to the user who owns this template
    let userId: String
    
    /// Name of the template
    let name: String
    
    /// Description of the template
    let description: String?
    
    /// Category of the template (e.g., "Weight Loss", "Muscle Gain", "Maintenance")
    let category: String
    
    /// Whether this template is the user's default template
    let isDefault: Bool
    
    /// Whether this template is public and can be shared
    let isPublic: Bool
    
    /// Template icon or emoji
    let icon: String?
    
    /// Template color theme
    let colorTheme: String?
    
    /// Number of days the template covers
    let durationDays: Int
    
    /// Number of meals per day
    let mealsPerDay: Int
    
    /// Whether to include snacks
    let includeSnacks: Bool
    
    /// Target daily calorie intake
    let targetCalories: Int?
    
    /// Target protein intake in grams
    let targetProtein: Double?
    
    /// Target carbohydrate intake in grams
    let targetCarbohydrates: Double?
    
    /// Target fat intake in grams
    let targetFat: Double?
    
    /// Dietary restrictions for this template
    let dietaryRestrictions: [String]
    
    /// Allergies and intolerances
    let allergies: [String]
    
    /// Preferred cuisine types
    let preferredCuisines: [String]
    
    /// Disliked ingredients
    let dislikedIngredients: [String]
    
    /// Favorite ingredients
    let favoriteIngredients: [String]
    
    /// Budget range for this template (Low, Medium, High)
    let budgetRange: String
    
    /// Maximum cost per meal
    let maxCostPerMeal: Double?
    
    /// Weekly budget limit
    let weeklyBudget: Double?
    
    /// Cooking skill level required (Beginner, Intermediate, Advanced)
    let cookingSkillLevel: String
    
    /// Maximum preparation time per meal in minutes
    let maxPrepTime: Int?
    
    /// Maximum cooking time per meal in minutes
    let maxCookTime: Int?
    
    /// Whether to include meal prep instructions
    let includeMealPrep: Bool
    
    /// Whether to include shopping lists
    let includeShoppingList: Bool
    
    /// Whether to include nutritional information
    let includeNutritionInfo: Bool
    
    /// Whether to rotate meals to avoid repetition
    let rotateMeals: Bool
    
    /// Number of different recipes to include per week
    let recipeVariety: Int?
    
    /// Whether to include leftovers in planning
    let includeLeftovers: Bool
    
    /// Preferred meal complexity (Easy, Medium, Hard)
    let preferredComplexity: String
    
    /// Special instructions or notes for this template
    let specialInstructions: String?
    
    /// Tags for organizing templates
    let tags: [String]
    
    /// Usage count - how many times this template has been used
    let usageCount: Int
    
    /// Rating of the template (1-5 stars)
    let rating: Double?
    
    /// Number of ratings received
    let ratingCount: Int
    
    /// Timestamp when the template was created
    let createdAt: Date
    
    /// Timestamp when the template was last updated
    let updatedAt: Date
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case description
        case category
        case isDefault = "is_default"
        case isPublic = "is_public"
        case icon
        case colorTheme = "color_theme"
        case durationDays = "duration_days"
        case mealsPerDay = "meals_per_day"
        case includeSnacks = "include_snacks"
        case targetCalories = "target_calories"
        case targetProtein = "target_protein"
        case targetCarbohydrates = "target_carbohydrates"
        case targetFat = "target_fat"
        case dietaryRestrictions = "dietary_restrictions"
        case allergies
        case preferredCuisines = "preferred_cuisines"
        case dislikedIngredients = "disliked_ingredients"
        case favoriteIngredients = "favorite_ingredients"
        case budgetRange = "budget_range"
        case maxCostPerMeal = "max_cost_per_meal"
        case weeklyBudget = "weekly_budget"
        case cookingSkillLevel = "cooking_skill_level"
        case maxPrepTime = "max_prep_time"
        case maxCookTime = "max_cook_time"
        case includeMealPrep = "include_meal_prep"
        case includeShoppingList = "include_shopping_list"
        case includeNutritionInfo = "include_nutrition_info"
        case rotateMeals = "rotate_meals"
        case recipeVariety = "recipe_variety"
        case includeLeftovers = "include_leftovers"
        case preferredComplexity = "preferred_complexity"
        case specialInstructions = "special_instructions"
        case tags
        case usageCount = "usage_count"
        case rating
        case ratingCount = "rating_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        category = try container.decode(String.self, forKey: .category)
        isDefault = try container.decode(Bool.self, forKey: .isDefault)
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        colorTheme = try container.decodeIfPresent(String.self, forKey: .colorTheme)
        durationDays = try container.decode(Int.self, forKey: .durationDays)
        mealsPerDay = try container.decode(Int.self, forKey: .mealsPerDay)
        includeSnacks = try container.decode(Bool.self, forKey: .includeSnacks)
        targetCalories = try container.decodeIfPresent(Int.self, forKey: .targetCalories)
        targetProtein = try container.decodeIfPresent(Double.self, forKey: .targetProtein)
        targetCarbohydrates = try container.decodeIfPresent(Double.self, forKey: .targetCarbohydrates)
        targetFat = try container.decodeIfPresent(Double.self, forKey: .targetFat)
        dietaryRestrictions = try container.decode([String].self, forKey: .dietaryRestrictions)
        allergies = try container.decode([String].self, forKey: .allergies)
        preferredCuisines = try container.decode([String].self, forKey: .preferredCuisines)
        dislikedIngredients = try container.decode([String].self, forKey: .dislikedIngredients)
        favoriteIngredients = try container.decode([String].self, forKey: .favoriteIngredients)
        budgetRange = try container.decode(String.self, forKey: .budgetRange)
        maxCostPerMeal = try container.decodeIfPresent(Double.self, forKey: .maxCostPerMeal)
        weeklyBudget = try container.decodeIfPresent(Double.self, forKey: .weeklyBudget)
        cookingSkillLevel = try container.decode(String.self, forKey: .cookingSkillLevel)
        maxPrepTime = try container.decodeIfPresent(Int.self, forKey: .maxPrepTime)
        maxCookTime = try container.decodeIfPresent(Int.self, forKey: .maxCookTime)
        includeMealPrep = try container.decode(Bool.self, forKey: .includeMealPrep)
        includeShoppingList = try container.decode(Bool.self, forKey: .includeShoppingList)
        includeNutritionInfo = try container.decode(Bool.self, forKey: .includeNutritionInfo)
        rotateMeals = try container.decode(Bool.self, forKey: .rotateMeals)
        recipeVariety = try container.decodeIfPresent(Int.self, forKey: .recipeVariety)
        includeLeftovers = try container.decode(Bool.self, forKey: .includeLeftovers)
        preferredComplexity = try container.decode(String.self, forKey: .preferredComplexity)
        specialInstructions = try container.decodeIfPresent(String.self, forKey: .specialInstructions)
        tags = try container.decode([String].self, forKey: .tags)
        usageCount = try container.decode(Int.self, forKey: .usageCount)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        ratingCount = try container.decode(Int.self, forKey: .ratingCount)
        
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
     * Creates a new MealPlanTemplate instance
     * 
     * - Parameters:
     *   - id: Unique identifier
     *   - userId: Reference to the user
     *   - name: Template name
     *   - description: Optional description
     *   - category: Template category
     *   - isDefault: Whether this is the default template
     *   - isPublic: Whether template is public
     *   - icon: Optional icon
     *   - colorTheme: Optional color theme
     *   - durationDays: Number of days covered
     *   - mealsPerDay: Meals per day
     *   - includeSnacks: Whether to include snacks
     *   - targetCalories: Target daily calories
     *   - targetProtein: Target protein in grams
     *   - targetCarbohydrates: Target carbs in grams
     *   - targetFat: Target fat in grams
     *   - dietaryRestrictions: Array of dietary restrictions
     *   - allergies: Array of allergies
     *   - preferredCuisines: Array of preferred cuisines
     *   - dislikedIngredients: Array of disliked ingredients
     *   - favoriteIngredients: Array of favorite ingredients
     *   - budgetRange: Budget range
     *   - maxCostPerMeal: Maximum cost per meal
     *   - weeklyBudget: Weekly budget limit
     *   - cookingSkillLevel: Required cooking skill level
     *   - maxPrepTime: Maximum prep time in minutes
     *   - maxCookTime: Maximum cook time in minutes
     *   - includeMealPrep: Whether to include meal prep
     *   - includeShoppingList: Whether to include shopping list
     *   - includeNutritionInfo: Whether to include nutrition info
     *   - rotateMeals: Whether to rotate meals
     *   - recipeVariety: Number of different recipes per week
     *   - includeLeftovers: Whether to include leftovers
     *   - preferredComplexity: Preferred meal complexity
     *   - specialInstructions: Optional special instructions
     *   - tags: Array of tags
     *   - usageCount: Number of times used
     *   - rating: Average rating
     *   - ratingCount: Number of ratings
     *   - createdAt: Creation timestamp
     *   - updatedAt: Last update timestamp
     */
    init(id: String, userId: String, name: String, description: String?, category: String, isDefault: Bool, isPublic: Bool, icon: String?, colorTheme: String?, durationDays: Int, mealsPerDay: Int, includeSnacks: Bool, targetCalories: Int?, targetProtein: Double?, targetCarbohydrates: Double?, targetFat: Double?, dietaryRestrictions: [String], allergies: [String], preferredCuisines: [String], dislikedIngredients: [String], favoriteIngredients: [String], budgetRange: String, maxCostPerMeal: Double?, weeklyBudget: Double?, cookingSkillLevel: String, maxPrepTime: Int?, maxCookTime: Int?, includeMealPrep: Bool, includeShoppingList: Bool, includeNutritionInfo: Bool, rotateMeals: Bool, recipeVariety: Int?, includeLeftovers: Bool, preferredComplexity: String, specialInstructions: String?, tags: [String], usageCount: Int, rating: Double?, ratingCount: Int, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.category = category
        self.isDefault = isDefault
        self.isPublic = isPublic
        self.icon = icon
        self.colorTheme = colorTheme
        self.durationDays = durationDays
        self.mealsPerDay = mealsPerDay
        self.includeSnacks = includeSnacks
        self.targetCalories = targetCalories
        self.targetProtein = targetProtein
        self.targetCarbohydrates = targetCarbohydrates
        self.targetFat = targetFat
        self.dietaryRestrictions = dietaryRestrictions
        self.allergies = allergies
        self.preferredCuisines = preferredCuisines
        self.dislikedIngredients = dislikedIngredients
        self.favoriteIngredients = favoriteIngredients
        self.budgetRange = budgetRange
        self.maxCostPerMeal = maxCostPerMeal
        self.weeklyBudget = weeklyBudget
        self.cookingSkillLevel = cookingSkillLevel
        self.maxPrepTime = maxPrepTime
        self.maxCookTime = maxCookTime
        self.includeMealPrep = includeMealPrep
        self.includeShoppingList = includeShoppingList
        self.includeNutritionInfo = includeNutritionInfo
        self.rotateMeals = rotateMeals
        self.recipeVariety = recipeVariety
        self.includeLeftovers = includeLeftovers
        self.preferredComplexity = preferredComplexity
        self.specialInstructions = specialInstructions
        self.tags = tags
        self.usageCount = usageCount
        self.rating = rating
        self.ratingCount = ratingCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    /**
     * Total number of meals in the template
     * 
     * - Returns: Total meals (including snacks if enabled)
     */
    var totalMeals: Int {
        let baseMeals = durationDays * mealsPerDay
        return includeSnacks ? baseMeals + durationDays : baseMeals
    }
    
    /**
     * Formatted duration string
     * 
     * - Returns: Duration formatted as "X days" or "X weeks"
     */
    var formattedDuration: String {
        if durationDays == 7 {
            return "1 week"
        } else if durationDays % 7 == 0 {
            let weeks = durationDays / 7
            return "\(weeks) week\(weeks == 1 ? "" : "s")"
        } else {
            return "\(durationDays) day\(durationDays == 1 ? "" : "s")"
        }
    }
    
    /**
     * Display description
     * 
     * - Returns: Description if available, otherwise default text
     */
    var displayDescription: String {
        return description ?? "A meal plan template for \(category.lowercased())"
    }
    
    /**
     * Whether template has any dietary restrictions
     * 
     * - Returns: True if template has dietary restrictions
     */
    var hasDietaryRestrictions: Bool {
        return !dietaryRestrictions.isEmpty
    }
    
    /**
     * Whether template has any allergies
     * 
     * - Returns: True if template has allergies
     */
    var hasAllergies: Bool {
        return !allergies.isEmpty
    }
    
    /**
     * Whether template has budget constraints
     * 
     * - Returns: True if template has budget limits
     */
    var hasBudgetConstraints: Bool {
        return maxCostPerMeal != nil || weeklyBudget != nil
    }
    
    /**
     * Whether template has time constraints
     * 
     * - Returns: True if template has time limits
     */
    var hasTimeConstraints: Bool {
        return maxPrepTime != nil || maxCookTime != nil
    }
    
    /**
     * Formatted rating string
     * 
     * - Returns: Rating formatted as "X.X stars" or "No ratings"
     */
    var formattedRating: String {
        guard let rating = rating, ratingCount > 0 else {
            return "No ratings"
        }
        return String(format: "%.1f stars", rating)
    }
    
    /**
     * Category color for UI display
     * 
     * - Returns: Color name based on category
     */
    var categoryColor: String {
        switch category.lowercased() {
        case "weight loss":
            return "SuccessGreen"
        case "muscle gain":
            return "PrimaryOrange"
        case "maintenance":
            return "BackgroundCream"
        case "vegetarian":
            return "SuccessGreen"
        case "vegan":
            return "SuccessGreen"
        case "keto":
            return "WarnRed"
        case "paleo":
            return "PrimaryOrange"
        default:
            return "TextCharcoal"
        }
    }
    
    /**
     * Budget range color for UI display
     * 
     * - Returns: Color name based on budget range
     */
    var budgetColor: String {
        switch budgetRange.lowercased() {
        case "low":
            return "SuccessGreen"
        case "medium":
            return "PrimaryOrange"
        case "high":
            return "WarnRed"
        default:
            return "TextCharcoal"
        }
    }
    
    /**
     * Complexity color for UI display
     * 
     * - Returns: Color name based on complexity
     */
    var complexityColor: String {
        switch preferredComplexity.lowercased() {
        case "easy":
            return "SuccessGreen"
        case "medium":
            return "PrimaryOrange"
        case "hard":
            return "WarnRed"
        default:
            return "TextCharcoal"
        }
    }
    
    /**
     * Whether template is suitable for beginners
     * 
     * - Returns: True if cooking skill level is beginner
     */
    var isBeginnerFriendly: Bool {
        return cookingSkillLevel.lowercased() == "beginner"
    }
    
    /**
     * Whether template is suitable for advanced cooks
     * 
     * - Returns: True if cooking skill level is advanced
     */
    var isAdvancedLevel: Bool {
        return cookingSkillLevel.lowercased() == "advanced"
    }
    
    // MARK: - Helper Methods
    
    /**
     * Checks if template has a specific dietary restriction
     * 
     * - Parameter restriction: The dietary restriction to check
     * - Returns: True if template has this restriction
     */
    func hasDietaryRestriction(_ restriction: String) -> Bool {
        return dietaryRestrictions.contains { $0.lowercased() == restriction.lowercased() }
    }
    
    /**
     * Checks if template has a specific allergy
     * 
     * - Parameter allergy: The allergy to check
     * - Returns: True if template has this allergy
     */
    func hasAllergy(_ allergy: String) -> Bool {
        return allergies.contains { $0.lowercased() == allergy.lowercased() }
    }
    
    /**
     * Checks if template prefers a specific cuisine
     * 
     * - Parameter cuisine: The cuisine to check
     * - Returns: True if template prefers this cuisine
     */
    func prefersCuisine(_ cuisine: String) -> Bool {
        return preferredCuisines.contains { $0.lowercased() == cuisine.lowercased() }
    }
    
    /**
     * Checks if template dislikes a specific ingredient
     * 
     * - Parameter ingredient: The ingredient to check
     * - Returns: True if template dislikes this ingredient
     */
    func dislikesIngredient(_ ingredient: String) -> Bool {
        return dislikedIngredients.contains { $0.lowercased() == ingredient.lowercased() }
    }
    
    /**
     * Checks if template likes a specific ingredient
     * 
     * - Parameter ingredient: The ingredient to check
     * - Returns: True if template likes this ingredient
     */
    func likesIngredient(_ ingredient: String) -> Bool {
        return favoriteIngredients.contains { $0.lowercased() == ingredient.lowercased() }
    }
    
    /**
     * Creates a copy of this template with updated usage count
     * 
     * - Parameter newUsageCount: New usage count
     * - Returns: New MealPlanTemplate instance with updated usage count
     */
    func withUsageCount(_ newUsageCount: Int) -> MealPlanTemplate {
        return MealPlanTemplate(
            id: id,
            userId: userId,
            name: name,
            description: description,
            category: category,
            isDefault: isDefault,
            isPublic: isPublic,
            icon: icon,
            colorTheme: colorTheme,
            durationDays: durationDays,
            mealsPerDay: mealsPerDay,
            includeSnacks: includeSnacks,
            targetCalories: targetCalories,
            targetProtein: targetProtein,
            targetCarbohydrates: targetCarbohydrates,
            targetFat: targetFat,
            dietaryRestrictions: dietaryRestrictions,
            allergies: allergies,
            preferredCuisines: preferredCuisines,
            dislikedIngredients: dislikedIngredients,
            favoriteIngredients: favoriteIngredients,
            budgetRange: budgetRange,
            maxCostPerMeal: maxCostPerMeal,
            weeklyBudget: weeklyBudget,
            cookingSkillLevel: cookingSkillLevel,
            maxPrepTime: maxPrepTime,
            maxCookTime: maxCookTime,
            includeMealPrep: includeMealPrep,
            includeShoppingList: includeShoppingList,
            includeNutritionInfo: includeNutritionInfo,
            rotateMeals: rotateMeals,
            recipeVariety: recipeVariety,
            includeLeftovers: includeLeftovers,
            preferredComplexity: preferredComplexity,
            specialInstructions: specialInstructions,
            tags: tags,
            usageCount: newUsageCount,
            rating: rating,
            ratingCount: ratingCount,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    /**
     * Creates a copy of this template with updated rating
     * 
     * - Parameters:
     *   - newRating: New average rating
     *   - newRatingCount: New rating count
     * - Returns: New MealPlanTemplate instance with updated rating
     */
    func withRating(_ newRating: Double?, ratingCount newRatingCount: Int) -> MealPlanTemplate {
        return MealPlanTemplate(
            id: id,
            userId: userId,
            name: name,
            description: description,
            category: category,
            isDefault: isDefault,
            isPublic: isPublic,
            icon: icon,
            colorTheme: colorTheme,
            durationDays: durationDays,
            mealsPerDay: mealsPerDay,
            includeSnacks: includeSnacks,
            targetCalories: targetCalories,
            targetProtein: targetProtein,
            targetCarbohydrates: targetCarbohydrates,
            targetFat: targetFat,
            dietaryRestrictions: dietaryRestrictions,
            allergies: allergies,
            preferredCuisines: preferredCuisines,
            dislikedIngredients: dislikedIngredients,
            favoriteIngredients: favoriteIngredients,
            budgetRange: budgetRange,
            maxCostPerMeal: maxCostPerMeal,
            weeklyBudget: weeklyBudget,
            cookingSkillLevel: cookingSkillLevel,
            maxPrepTime: maxPrepTime,
            maxCookTime: maxCookTime,
            includeMealPrep: includeMealPrep,
            includeShoppingList: includeShoppingList,
            includeNutritionInfo: includeNutritionInfo,
            rotateMeals: rotateMeals,
            recipeVariety: recipeVariety,
            includeLeftovers: includeLeftovers,
            preferredComplexity: preferredComplexity,
            specialInstructions: specialInstructions,
            tags: tags,
            usageCount: usageCount,
            rating: newRating,
            ratingCount: newRatingCount,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}

// MARK: - MealPlanTemplate Extensions

extension MealPlanTemplate {
    /**
     * Standard template categories
     */
    static let standardCategories = [
        "Weight Loss",
        "Muscle Gain",
        "Maintenance",
        "Vegetarian",
        "Vegan",
        "Keto",
        "Paleo",
        "Mediterranean",
        "Low Carb",
        "High Protein",
        "Budget Friendly",
        "Quick & Easy",
        "Family Friendly",
        "Athlete",
        "Senior",
        "Pregnancy",
        "Other"
    ]
    
    /**
     * Standard budget ranges
     */
    static let budgetRanges = ["Low", "Medium", "High"]
    
    /**
     * Standard cooking skill levels
     */
    static let cookingSkillLevels = ["Beginner", "Intermediate", "Advanced"]
    
    /**
     * Standard meal complexities
     */
    static let mealComplexities = ["Easy", "Medium", "Hard"]
    
    /**
     * Standard duration options in days
     */
    static let durationOptions = [7, 14, 21, 28, 30]
    
    /**
     * Standard meals per day options
     */
    static let mealsPerDayOptions = [3, 4, 5, 6]
} 
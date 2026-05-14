//
//  MealPlanTemplate.swift
//  Makuli
//
//  Created by Ian on 2025-01-08.
//
//

import Foundation


struct MealPlanTemplate: Identifiable, Codable {
    let id: String
    
    let userId: String
    
    let name: String
    
    let description: String?
    
    let category: String
    
    let isDefault: Bool
    
    let isPublic: Bool
    
    let icon: String?
    
    let colorTheme: String?
    
    let durationDays: Int
    
    let mealsPerDay: Int
    
    let includeSnacks: Bool
    
    let targetCalories: Int?
    
    let targetProtein: Double?
    
    let targetCarbohydrates: Double?
    
    let targetFat: Double?
    
    let dietaryRestrictions: [String]
    
    let allergies: [String]
    
    let preferredCuisines: [String]
    
    let dislikedIngredients: [String]
    
    let favoriteIngredients: [String]
    
    let budgetRange: String
    
    let maxCostPerMeal: Double?
    
    let weeklyBudget: Double?
    
    let cookingSkillLevel: String
    
    let maxPrepTime: Int?
    
    let maxCookTime: Int?
    
    let includeMealPrep: Bool
    
    let includeShoppingList: Bool
    
    let includeNutritionInfo: Bool
    
    let rotateMeals: Bool
    
    let recipeVariety: Int?
    
    let includeLeftovers: Bool
    
    let preferredComplexity: String
    
    let specialInstructions: String?
    
    let tags: [String]
    
    let usageCount: Int
    
    let rating: Double?
    
    let ratingCount: Int
    
    let createdAt: Date
    
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
   
    var totalMeals: Int {
        let baseMeals = durationDays * mealsPerDay
        return includeSnacks ? baseMeals + durationDays : baseMeals
    }
    
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
    
    
    var displayDescription: String {
        return description ?? "A meal plan template for \(category.lowercased())"
    }

    var hasDietaryRestrictions: Bool {
        return !dietaryRestrictions.isEmpty
    }

    var hasAllergies: Bool {
        return !allergies.isEmpty
    }

    var hasBudgetConstraints: Bool {
        return maxCostPerMeal != nil || weeklyBudget != nil
    }

    var hasTimeConstraints: Bool {
        return maxPrepTime != nil || maxCookTime != nil
    }

    var formattedRating: String {
        guard let rating = rating, ratingCount > 0 else {
            return "No ratings"
        }
        return String(format: "%.1f stars", rating)
    }
    

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

    var isBeginnerFriendly: Bool {
        return cookingSkillLevel.lowercased() == "beginner"
    }

    var isAdvancedLevel: Bool {
        return cookingSkillLevel.lowercased() == "advanced"
    }
    
    // MARK: - Helper Methods
    
    func hasDietaryRestriction(_ restriction: String) -> Bool {
        return dietaryRestrictions.contains { $0.lowercased() == restriction.lowercased() }
    }
    
    func hasAllergy(_ allergy: String) -> Bool {
        return allergies.contains { $0.lowercased() == allergy.lowercased() }
    }

    func prefersCuisine(_ cuisine: String) -> Bool {
        return preferredCuisines.contains { $0.lowercased() == cuisine.lowercased() }
    }
    
    func dislikesIngredient(_ ingredient: String) -> Bool {
        return dislikedIngredients.contains { $0.lowercased() == ingredient.lowercased() }
    }

    func likesIngredient(_ ingredient: String) -> Bool {
        return favoriteIngredients.contains { $0.lowercased() == ingredient.lowercased() }
    }

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
    
    static let budgetRanges = ["Low", "Medium", "High"]
    

    static let cookingSkillLevels = ["Beginner", "Intermediate", "Advanced"]
    
    static let mealComplexities = ["Easy", "Medium", "Hard"]
    
    static let durationOptions = [7, 14, 21, 28, 30]
    
    static let mealsPerDayOptions = [3, 4, 5, 6]
} 

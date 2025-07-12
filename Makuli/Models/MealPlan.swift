//
//  MealPlan.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import Foundation

/**
 * MealPlan Model
 * 
 * Represents a meal plan entity that contains multiple meals organized by day and meal type.
 * This model is used for displaying meal plans in the UI and managing meal plan data.
 * 
 * Key Features:
 * - Links to a user's plan via plan_id
 * - Contains meals organized by day and meal type (breakfast, lunch, dinner, snacks)
 * - Supports meal plan generation and management
 * 
 * Database Relationships:
 * - Belongs to a Plan (via plan_id)
 * - Contains multiple meals organized by day and meal type
 */
struct MealPlan: Identifiable, Codable {
    /// Unique identifier for the meal plan
    let id: String
    
    /// Reference to the parent plan
    let planId: String
    
    /// Collection of meals organized by day and meal type
    let meals: [String: [String: [Meal]]]
    
    /// Timestamp when the meal plan was created
    let createdAt: Date
    
    /// Timestamp when the meal plan was last updated
    let updatedAt: Date
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case planId = "plan_id"
        case meals
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        planId = try container.decode(String.self, forKey: .planId)
        
        // Decode meals with proper date handling
        let mealsData = try container.decode([String: [String: [Meal]]].self, forKey: .meals)
        meals = mealsData
        
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
     * Creates a new MealPlan instance
     * 
     * - Parameters:
     *   - id: Unique identifier
     *   - planId: Reference to the parent plan
     *   - meals: Dictionary of meals organized by day and meal type
     *   - createdAt: Creation timestamp
     *   - updatedAt: Last update timestamp
     */
    init(id: String, planId: String, meals: [String: [String: [Meal]]], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.planId = planId
        self.meals = meals
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Helper Methods
    
    /**
     * Gets meals for a specific day
     * 
     * - Parameter day: The day to get meals for (e.g., "Monday", "Tuesday")
     * - Returns: Dictionary of meals organized by meal type, or empty dictionary if no meals found
     */
    func mealsForDay(_ day: String) -> [String: [Meal]] {
        return meals[day] ?? [:]
    }
    
    /**
     * Gets meals for a specific day and meal type
     * 
     * - Parameters:
     *   - day: The day to get meals for
     *   - mealType: The meal type (breakfast, lunch, dinner, snacks)
     * - Returns: Array of meals, or empty array if no meals found
     */
    func mealsForDay(_ day: String, mealType: String) -> [Meal] {
        return meals[day]?[mealType] ?? []
    }
    
    /**
     * Gets all unique days that have meals
     * 
     * - Returns: Array of day names
     */
    var allDays: [String] {
        return Array(meals.keys).sorted()
    }
    
    /**
     * Gets all meal types available in the meal plan
     * 
     * - Returns: Array of meal type names
     */
    var allMealTypes: [String] {
        let allTypes = Set(meals.values.flatMap { $0.keys })
        return Array(allTypes).sorted()
    }
    
    /**
     * Gets the total number of meals in the plan
     * 
     * - Returns: Total count of all meals across all days and types
     */
    var totalMealCount: Int {
        return meals.values.flatMap { $0.values }.flatMap { $0 }.count
    }
}

/**
 * Meal Model
 * 
 * Represents an individual meal within a meal plan.
 * Contains recipe information and meal-specific details.
 */
struct Meal: Identifiable, Codable {
    /// Unique identifier for the meal
    let id: String
    
    /// Reference to the recipe
    let recipeId: String
    
    /// Name of the meal
    let name: String
    
    /// Description of the meal
    let description: String
    
    /// Image URL for the meal
    let imageUrl: String?
    
    /// Preparation time in minutes
    let prepTime: Int
    
    /// Cooking time in minutes
    let cookTime: Int
    
    /// Number of servings
    let servings: Int
    
    /// Difficulty level (Easy, Medium, Hard)
    let difficulty: String
    
    /// Cuisine type
    let cuisine: String
    
    /// Dietary tags (e.g., ["Vegetarian", "Gluten-Free"])
    let dietaryTags: [String]
    
    /// Nutritional information
    let nutrition: Nutrition
    
    /// Timestamp when the meal was created
    let createdAt: Date
    
    /// Timestamp when the meal was last updated
    let updatedAt: Date
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case name
        case description
        case imageUrl = "image_url"
        case prepTime = "prep_time"
        case cookTime = "cook_time"
        case servings
        case difficulty
        case cuisine
        case dietaryTags = "dietary_tags"
        case nutrition
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        recipeId = try container.decode(String.self, forKey: .recipeId)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        prepTime = try container.decode(Int.self, forKey: .prepTime)
        cookTime = try container.decode(Int.self, forKey: .cookTime)
        servings = try container.decode(Int.self, forKey: .servings)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        cuisine = try container.decode(String.self, forKey: .cuisine)
        dietaryTags = try container.decode([String].self, forKey: .dietaryTags)
        nutrition = try container.decode(Nutrition.self, forKey: .nutrition)
        
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
     * Creates a new Meal instance
     * 
     * - Parameters:
     *   - id: Unique identifier
     *   - recipeId: Reference to the recipe
     *   - name: Meal name
     *   - description: Meal description
     *   - imageUrl: Optional image URL
     *   - prepTime: Preparation time in minutes
     *   - cookTime: Cooking time in minutes
     *   - servings: Number of servings
     *   - difficulty: Difficulty level
     *   - cuisine: Cuisine type
     *   - dietaryTags: Array of dietary tags
     *   - nutrition: Nutritional information
     *   - createdAt: Creation timestamp
     *   - updatedAt: Last update timestamp
     */
    init(id: String, recipeId: String, name: String, description: String, imageUrl: String?, prepTime: Int, cookTime: Int, servings: Int, difficulty: String, cuisine: String, dietaryTags: [String], nutrition: Nutrition, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.recipeId = recipeId
        self.name = name
        self.description = description
        self.imageUrl = imageUrl
        self.prepTime = prepTime
        self.cookTime = cookTime
        self.servings = servings
        self.difficulty = difficulty
        self.cuisine = cuisine
        self.dietaryTags = dietaryTags
        self.nutrition = nutrition
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    /**
     * Total time required for the meal (prep + cook time)
     */
    var totalTime: Int {
        return prepTime + cookTime
    }
    
    /**
     * Formatted total time string
     */
    var formattedTotalTime: String {
        let hours = totalTime / 60
        let minutes = totalTime % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    /**
     * Validated image URL that can be safely loaded
     */
    var validImageUrl: URL? {
        guard let imageUrl = imageUrl, !imageUrl.isEmpty else { return nil }
        
        // Skip placeholder or invalid URLs
        if imageUrl.contains("placeholder") || imageUrl.contains("meal_placeholder") {
            return nil
        }
        
        return URL(string: imageUrl)
    }
}

/**
 * Nutrition Model
 * 
 * Represents nutritional information for a meal.
 * Contains macronutrients and other nutritional data.
 */
struct Nutrition: Codable {
    /// Calories per serving
    let calories: Int
    
    /// Protein content in grams
    let protein: Double
    
    /// Carbohydrate content in grams
    let carbohydrates: Double
    
    /// Fat content in grams
    let fat: Double
    
    /// Fiber content in grams
    let fiber: Double
    
    /// Sugar content in grams
    let sugar: Double
    
    /// Sodium content in milligrams
    let sodium: Int
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case calories
        case protein
        case carbohydrates
        case fat
        case fiber
        case sugar
        case sodium
    }
    
    // MARK: - Convenience Initializer
    
    /**
     * Creates a new Nutrition instance
     * 
     * - Parameters:
     *   - calories: Calories per serving
     *   - protein: Protein content in grams
     *   - carbohydrates: Carbohydrate content in grams
     *   - fat: Fat content in grams
     *   - fiber: Fiber content in grams
     *   - sugar: Sugar content in grams
     *   - sodium: Sodium content in milligrams
     */
    init(calories: Int, protein: Double, carbohydrates: Double, fat: Double, fiber: Double, sugar: Double, sodium: Int) {
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
    }
}

//
//  OnboardingData.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import Foundation

/**
 * OnboardingData Model
 * 
 * Represents the data collected during the user onboarding process.
 * This model captures user preferences, goals, and initial setup information
 * that will be used to personalize their meal planning experience.
 * 
 * Key Features:
 * - User demographic information
 * - Fitness and health goals
 * - Dietary preferences and restrictions
 * - Budget and lifestyle preferences
 * - Cooking experience and preferences
 * 
 * Database Relationships:
 * - Belongs to a User (via user_id)
 * - Used to create initial UserProfile
 * - Used to generate personalized meal plans
 */
struct OnboardingData: Identifiable, Codable {
    /// Unique identifier for the onboarding data
    let id: String
    
    /// Reference to the user this onboarding data belongs to
    let userId: String
    
    /// User's age in years
    let age: Int
    
    /// User's gender (Male, Female, Other, Prefer not to say)
    let gender: String
    
    /// User's height in centimeters
    let height: Double
    
    /// User's weight in kilograms
    let weight: Double
    
    /// User's activity level (Sedentary, Lightly Active, Moderately Active, Very Active, Extremely Active)
    let activityLevel: String
    
    /// User's fitness goal (Lose Weight, Maintain Weight, Gain Weight, Build Muscle)
    let fitnessGoal: String
    
    /// User's dietary preferences (e.g., ["Vegetarian", "Gluten-Free"])
    let dietaryPreferences: [String]
    
    /// User's budget range for meal planning (Low, Medium, High)
    let budgetRange: String
    
    /// User's preferred cuisine types (e.g., ["Italian", "Mexican", "Asian"])
    let preferredCuisines: [String]
    
    /// User's cooking skill level (Beginner, Intermediate, Advanced)
    let cookingSkillLevel: String
    
    /// User's preferred meal prep time in minutes
    let preferredPrepTime: Int
    
    /// User's preferred number of servings per meal
    let preferredServings: Int
    
    /// User's allergies and intolerances (e.g., ["Peanuts", "Lactose"])
    let allergies: [String]
    
    /// User's favorite ingredients (e.g., ["Chicken", "Quinoa", "Avocado"])
    let favoriteIngredients: [String]
    
    /// User's disliked ingredients (e.g., ["Mushrooms", "Olives"])
    let dislikedIngredients: [String]
    
    /// Whether the user wants to include meal prep instructions
    let includeMealPrep: Bool
    
    /// Whether the user wants to include shopping lists
    let includeShoppingList: Bool
    
    /// Whether the user wants to include nutritional information
    let includeNutritionInfo: Bool
    
    /// Whether the user wants to rotate meals to avoid repetition
    let rotateMeals: Bool
    
    /// Whether the user wants to include leftovers in planning
    let includeLeftovers: Bool
    
    /// User's preferred meal complexity (Easy, Medium, Hard)
    let preferredComplexity: String
    
    /// Additional notes or preferences from the user
    let additionalNotes: String?
    
    /// Whether the user has completed the onboarding process
    let isCompleted: Bool
    
    /// Current step in the onboarding process
    let currentStep: Int
    
    /// Total number of steps in the onboarding process
    let totalSteps: Int
    
    /// Timestamp when the onboarding data was created
    let createdAt: Date
    
    /// Timestamp when the onboarding data was last updated
    let updatedAt: Date
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case age
        case gender
        case height
        case weight
        case activityLevel = "activity_level"
        case fitnessGoal = "fitness_goal"
        case dietaryPreferences = "dietary_preferences"
        case budgetRange = "budget_range"
        case preferredCuisines = "preferred_cuisines"
        case cookingSkillLevel = "cooking_skill_level"
        case preferredPrepTime = "preferred_prep_time"
        case preferredServings = "preferred_servings"
        case allergies
        case favoriteIngredients = "favorite_ingredients"
        case dislikedIngredients = "disliked_ingredients"
        case includeMealPrep = "include_meal_prep"
        case includeShoppingList = "include_shopping_list"
        case includeNutritionInfo = "include_nutrition_info"
        case rotateMeals = "rotate_meals"
        case includeLeftovers = "include_leftovers"
        case preferredComplexity = "preferred_complexity"
        case additionalNotes = "additional_notes"
        case isCompleted = "is_completed"
        case currentStep = "current_step"
        case totalSteps = "total_steps"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        age = try container.decode(Int.self, forKey: .age)
        gender = try container.decode(String.self, forKey: .gender)
        height = try container.decode(Double.self, forKey: .height)
        weight = try container.decode(Double.self, forKey: .weight)
        activityLevel = try container.decode(String.self, forKey: .activityLevel)
        fitnessGoal = try container.decode(String.self, forKey: .fitnessGoal)
        dietaryPreferences = try container.decode([String].self, forKey: .dietaryPreferences)
        budgetRange = try container.decode(String.self, forKey: .budgetRange)
        preferredCuisines = try container.decode([String].self, forKey: .preferredCuisines)
        cookingSkillLevel = try container.decode(String.self, forKey: .cookingSkillLevel)
        preferredPrepTime = try container.decode(Int.self, forKey: .preferredPrepTime)
        preferredServings = try container.decode(Int.self, forKey: .preferredServings)
        allergies = try container.decode([String].self, forKey: .allergies)
        favoriteIngredients = try container.decode([String].self, forKey: .favoriteIngredients)
        dislikedIngredients = try container.decode([String].self, forKey: .dislikedIngredients)
        includeMealPrep = try container.decode(Bool.self, forKey: .includeMealPrep)
        includeShoppingList = try container.decode(Bool.self, forKey: .includeShoppingList)
        includeNutritionInfo = try container.decode(Bool.self, forKey: .includeNutritionInfo)
        rotateMeals = try container.decode(Bool.self, forKey: .rotateMeals)
        includeLeftovers = try container.decode(Bool.self, forKey: .includeLeftovers)
        preferredComplexity = try container.decode(String.self, forKey: .preferredComplexity)
        additionalNotes = try container.decodeIfPresent(String.self, forKey: .additionalNotes)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        currentStep = try container.decode(Int.self, forKey: .currentStep)
        totalSteps = try container.decode(Int.self, forKey: .totalSteps)
        
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
     * Creates a new OnboardingData instance
     * 
     * - Parameters:
     *   - id: Unique identifier
     *   - userId: Reference to the user
     *   - age: User's age in years
     *   - gender: User's gender
     *   - height: User's height in centimeters
     *   - weight: User's weight in kilograms
     *   - activityLevel: User's activity level
     *   - fitnessGoal: User's fitness goal
     *   - dietaryPreferences: Array of dietary preferences
     *   - budgetRange: User's budget range
     *   - preferredCuisines: Array of preferred cuisines
     *   - cookingSkillLevel: User's cooking skill level
     *   - preferredPrepTime: Preferred meal prep time in minutes
     *   - preferredServings: Preferred number of servings
     *   - allergies: Array of allergies and intolerances
     *   - favoriteIngredients: Array of favorite ingredients
     *   - dislikedIngredients: Array of disliked ingredients
     *   - includeMealPrep: Whether to include meal prep
     *   - includeShoppingList: Whether to include shopping list
     *   - includeNutritionInfo: Whether to include nutrition info
     *   - rotateMeals: Whether to rotate meals
     *   - includeLeftovers: Whether to include leftovers
     *   - preferredComplexity: Preferred meal complexity
     *   - additionalNotes: Optional additional notes
     *   - isCompleted: Whether onboarding is completed
     *   - currentStep: Current step in onboarding
     *   - totalSteps: Total number of steps
     *   - createdAt: Creation timestamp
     *   - updatedAt: Last update timestamp
     */
    init(id: String, userId: String, age: Int, gender: String, height: Double, weight: Double, activityLevel: String, fitnessGoal: String, dietaryPreferences: [String], budgetRange: String, preferredCuisines: [String], cookingSkillLevel: String, preferredPrepTime: Int, preferredServings: Int, allergies: [String], favoriteIngredients: [String], dislikedIngredients: [String], includeMealPrep: Bool, includeShoppingList: Bool, includeNutritionInfo: Bool, rotateMeals: Bool, includeLeftovers: Bool, preferredComplexity: String, additionalNotes: String?, isCompleted: Bool, currentStep: Int, totalSteps: Int, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.age = age
        self.gender = gender
        self.height = height
        self.weight = weight
        self.activityLevel = activityLevel
        self.fitnessGoal = fitnessGoal
        self.dietaryPreferences = dietaryPreferences
        self.budgetRange = budgetRange
        self.preferredCuisines = preferredCuisines
        self.cookingSkillLevel = cookingSkillLevel
        self.preferredPrepTime = preferredPrepTime
        self.preferredServings = preferredServings
        self.allergies = allergies
        self.favoriteIngredients = favoriteIngredients
        self.dislikedIngredients = dislikedIngredients
        self.includeMealPrep = includeMealPrep
        self.includeShoppingList = includeShoppingList
        self.includeNutritionInfo = includeNutritionInfo
        self.rotateMeals = rotateMeals
        self.includeLeftovers = includeLeftovers
        self.preferredComplexity = preferredComplexity
        self.additionalNotes = additionalNotes
        self.isCompleted = isCompleted
        self.currentStep = currentStep
        self.totalSteps = totalSteps
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    /**
     * User's Body Mass Index (BMI)
     * 
     * - Returns: BMI value calculated from height and weight
     */
    var bmi: Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
    /**
     * User's BMI category
     * 
     * - Returns: BMI category string (Underweight, Normal, Overweight, Obese)
     */
    var bmiCategory: String {
        switch bmi {
        case ..<18.5:
            return "Underweight"
        case 18.5..<25:
            return "Normal"
        case 25..<30:
            return "Overweight"
        default:
            return "Obese"
        }
    }
    
    /**
     * User's estimated daily calorie needs based on BMR and activity level
     * 
     * - Returns: Estimated daily calorie needs
     */
    var estimatedDailyCalories: Int {
        // Calculate Basal Metabolic Rate (BMR) using Mifflin-St Jeor Equation
        let bmr: Double
        if gender.lowercased() == "male" {
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
        }
        
        // Apply activity level multiplier
        let activityMultiplier: Double
        switch activityLevel.lowercased() {
        case "sedentary":
            activityMultiplier = 1.2
        case "lightly active":
            activityMultiplier = 1.375
        case "moderately active":
            activityMultiplier = 1.55
        case "very active":
            activityMultiplier = 1.725
        case "extremely active":
            activityMultiplier = 1.9
        default:
            activityMultiplier = 1.2
        }
        
        return Int(bmr * activityMultiplier)
    }
    
    /**
     * Onboarding progress percentage
     * 
     * - Returns: Percentage of onboarding completion
     */
    var progressPercentage: Double {
        guard totalSteps > 0 else { return 0.0 }
        return Double(currentStep) / Double(totalSteps) * 100.0
    }
    
    /**
     * Whether onboarding is in progress
     * 
     * - Returns: True if onboarding is not completed
     */
    var isInProgress: Bool {
        return !isCompleted && currentStep > 0
    }
    
    /**
     * Whether onboarding has started
     * 
     * - Returns: True if current step is greater than 0
     */
    var hasStarted: Bool {
        return currentStep > 0
    }
    
    /**
     * Whether user has any dietary restrictions
     * 
     * - Returns: True if user has dietary preferences
     */
    var hasDietaryRestrictions: Bool {
        return !dietaryPreferences.isEmpty
    }
    
    /**
     * Whether user has any allergies
     * 
     * - Returns: True if user has allergies
     */
    var hasAllergies: Bool {
        return !allergies.isEmpty
    }
    
    /**
     * Whether user has favorite ingredients
     * 
     * - Returns: True if user has favorite ingredients
     */
    var hasFavoriteIngredients: Bool {
        return !favoriteIngredients.isEmpty
    }
    
    /**
     * Whether user has disliked ingredients
     * 
     * - Returns: True if user has disliked ingredients
     */
    var hasDislikedIngredients: Bool {
        return !dislikedIngredients.isEmpty
    }
    
    /**
     * Whether user has preferred cuisines
     * 
     * - Returns: True if user has preferred cuisines
     */
    var hasPreferredCuisines: Bool {
        return !preferredCuisines.isEmpty
    }
    
    /**
     * Formatted height string
     * 
     * - Returns: Height formatted as "X cm" or "X'Y\""
     */
    var formattedHeight: String {
        // Convert to feet and inches for display
        let totalInches = height / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return "\(feet)'\(inches)\" (\(Int(height)) cm)"
    }
    
    /**
     * Formatted weight string
     * 
     * - Returns: Weight formatted as "X kg" or "X lbs"
     */
    var formattedWeight: String {
        let pounds = weight * 2.20462
        return "\(Int(pounds)) lbs (\(Int(weight)) kg)"
    }
    
    /**
     * Formatted prep time string
     * 
     * - Returns: Prep time formatted as "X minutes" or "X hours Y minutes"
     */
    var formattedPrepTime: String {
        let hours = preferredPrepTime / 60
        let minutes = preferredPrepTime % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    // MARK: - Helper Methods
    
    /**
     * Checks if user has a specific dietary preference
     * 
     * - Parameter preference: The dietary preference to check
     * - Returns: True if user has this preference
     */
    func hasDietaryPreference(_ preference: String) -> Bool {
        return dietaryPreferences.contains { $0.lowercased() == preference.lowercased() }
    }
    
    /**
     * Checks if user has a specific allergy
     * 
     * - Parameter allergy: The allergy to check
     * - Returns: True if user has this allergy
     */
    func hasAllergy(_ allergy: String) -> Bool {
        return allergies.contains { $0.lowercased() == allergy.lowercased() }
    }
    
    /**
     * Checks if user likes a specific ingredient
     * 
     * - Parameter ingredient: The ingredient to check
     * - Returns: True if user likes this ingredient
     */
    func likesIngredient(_ ingredient: String) -> Bool {
        return favoriteIngredients.contains { $0.lowercased() == ingredient.lowercased() }
    }
    
    /**
     * Checks if user dislikes a specific ingredient
     * 
     * - Parameter ingredient: The ingredient to check
     * - Returns: True if user dislikes this ingredient
     */
    func dislikesIngredient(_ ingredient: String) -> Bool {
        return dislikedIngredients.contains { $0.lowercased() == ingredient.lowercased() }
    }
    
    /**
     * Checks if user prefers a specific cuisine
     * 
     * - Parameter cuisine: The cuisine to check
     * - Returns: True if user prefers this cuisine
     */
    func prefersCuisine(_ cuisine: String) -> Bool {
        return preferredCuisines.contains { $0.lowercased() == cuisine.lowercased() }
    }
    
    /**
     * Creates a copy of this onboarding data with updated step
     * 
     * - Parameter newStep: New current step
     * - Returns: New OnboardingData instance with updated step
     */
    func withStep(_ newStep: Int) -> OnboardingData {
        return OnboardingData(
            id: id,
            userId: userId,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            activityLevel: activityLevel,
            fitnessGoal: fitnessGoal,
            dietaryPreferences: dietaryPreferences,
            budgetRange: budgetRange,
            preferredCuisines: preferredCuisines,
            cookingSkillLevel: cookingSkillLevel,
            preferredPrepTime: preferredPrepTime,
            preferredServings: preferredServings,
            allergies: allergies,
            favoriteIngredients: favoriteIngredients,
            dislikedIngredients: dislikedIngredients,
            includeMealPrep: includeMealPrep,
            includeShoppingList: includeShoppingList,
            includeNutritionInfo: includeNutritionInfo,
            rotateMeals: rotateMeals,
            includeLeftovers: includeLeftovers,
            preferredComplexity: preferredComplexity,
            additionalNotes: additionalNotes,
            isCompleted: isCompleted,
            currentStep: newStep,
            totalSteps: totalSteps,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    /**
     * Creates a copy of this onboarding data with completion status
     * 
     * - Parameter completed: New completion status
     * - Returns: New OnboardingData instance with updated completion status
     */
    func withCompletionStatus(_ completed: Bool) -> OnboardingData {
        return OnboardingData(
            id: id,
            userId: userId,
            age: age,
            gender: gender,
            height: height,
            weight: weight,
            activityLevel: activityLevel,
            fitnessGoal: fitnessGoal,
            dietaryPreferences: dietaryPreferences,
            budgetRange: budgetRange,
            preferredCuisines: preferredCuisines,
            cookingSkillLevel: cookingSkillLevel,
            preferredPrepTime: preferredPrepTime,
            preferredServings: preferredServings,
            allergies: allergies,
            favoriteIngredients: favoriteIngredients,
            dislikedIngredients: dislikedIngredients,
            includeMealPrep: includeMealPrep,
            includeShoppingList: includeShoppingList,
            includeNutritionInfo: includeNutritionInfo,
            rotateMeals: rotateMeals,
            includeLeftovers: includeLeftovers,
            preferredComplexity: preferredComplexity,
            additionalNotes: additionalNotes,
            isCompleted: completed,
            currentStep: currentStep,
            totalSteps: totalSteps,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}

// MARK: - OnboardingData Extensions

extension OnboardingData {
    /**
     * Standard gender options
     */
    static let genderOptions = [
        "Male",
        "Female",
        "Other",
        "Prefer not to say"
    ]
    
    /**
     * Standard activity levels
     */
    static let activityLevels = [
        "Sedentary",
        "Lightly Active",
        "Moderately Active",
        "Very Active",
        "Extremely Active"
    ]
    
    /**
     * Standard fitness goals
     */
    static let fitnessGoals = [
        "Lose Weight",
        "Maintain Weight",
        "Gain Weight",
        "Build Muscle"
    ]
    
    /**
     * Standard dietary preferences
     */
    static let dietaryPreferences = [
        "Vegetarian",
        "Vegan",
        "Gluten-Free",
        "Dairy-Free",
        "Keto",
        "Paleo",
        "Mediterranean",
        "Low Carb",
        "High Protein",
        "Low Fat",
        "Low Sodium",
        "None"
    ]
    
    /**
     * Standard budget ranges
     */
    static let budgetRanges = ["Low", "Medium", "High"]
    
    /**
     * Standard cuisine types
     */
    static let cuisineTypes = [
        "Italian",
        "Mexican",
        "Asian",
        "Mediterranean",
        "American",
        "Indian",
        "French",
        "Thai",
        "Japanese",
        "Greek",
        "Spanish",
        "Middle Eastern",
        "African",
        "Caribbean",
        "Other"
    ]
    
    /**
     * Standard cooking skill levels
     */
    static let cookingSkillLevels = ["Beginner", "Intermediate", "Advanced"]
    
    /**
     * Standard meal complexities
     */
    static let mealComplexities = ["Easy", "Medium", "Hard"]
    
    /**
     * Standard prep time options in minutes
     */
    static let prepTimeOptions = [15, 30, 45, 60, 90, 120]
    
    /**
     * Standard serving size options
     */
    static let servingSizeOptions = [1, 2, 3, 4, 5, 6, 8, 10]
    
    /**
     * Common allergies
     */
    static let commonAllergies = [
        "Peanuts",
        "Tree Nuts",
        "Milk",
        "Eggs",
        "Soy",
        "Fish",
        "Shellfish",
        "Wheat",
        "Gluten",
        "Lactose",
        "Sesame",
        "None"
    ]
    
    /**
     * Common ingredients for favorites/dislikes
     */
    static let commonIngredients = [
        "Chicken",
        "Beef",
        "Fish",
        "Shrimp",
        "Tofu",
        "Quinoa",
        "Rice",
        "Pasta",
        "Bread",
        "Avocado",
        "Tomatoes",
        "Onions",
        "Garlic",
        "Mushrooms",
        "Spinach",
        "Kale",
        "Broccoli",
        "Carrots",
        "Potatoes",
        "Sweet Potatoes",
        "Olives",
        "Cheese",
        "Yogurt",
        "Eggs",
        "Nuts",
        "Seeds",
        "Herbs",
        "Spices"
    ]
}

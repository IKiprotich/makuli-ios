//
//  OnboardingData.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import Foundation

/// Data collected across all onboarding screens. Used to personalize the user's
/// initial meal plan and to populate their profile in the database.
final class OnboardingData: Identifiable, Codable, ObservableObject {
    let id: String
    let userId: String
    var age: Int
    var gender: String
    var height: Double
    var weight: Double
    var activityLevel: String
    var fitnessGoal: String
    var dietaryPreferences: [String]
    var budgetRange: String
    var preferredCuisines: [String]
    var cookingSkillLevel: String
    var preferredPrepTime: Int
    var preferredServings: Int
    var allergies: [String]
    var favoriteIngredients: [String]
    var dislikedIngredients: [String]
    var includeMealPrep: Bool
    var includeShoppingList: Bool
    var includeNutritionInfo: Bool
    var rotateMeals: Bool
    var includeLeftovers: Bool
    var preferredComplexity: String
    var additionalNotes: String?
    var isCompleted: Bool
    var currentStep: Int
    let totalSteps: Int
    let createdAt: Date
    var updatedAt: Date
    var onboardingGoals: [String]
    var foodPreference: String
    var dislikedCuisines: [String]
    var pantryStatus: String
    var avatarEmoji: String
    /// Explicit daily calorie override; falls back to `estimatedDailyCalories` when nil.
    var calorieGoal: Int?

    // Maps Swift property names to Supabase column names for decoding/encoding.
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
        case onboardingGoals = "onboarding_goals"
        case foodPreference = "food_preference"
        case dislikedCuisines = "disliked_cuisines"
        case pantryStatus = "pantry_status"
        case avatarEmoji = "avatar_emoji"
        case calorieGoal = "calorie_goal"
    }
    
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
        
        onboardingGoals = (try? container.decode([String].self, forKey: .onboardingGoals)) ?? []
        foodPreference = (try? container.decode(String.self, forKey: .foodPreference)) ?? "Flexible"
        dislikedCuisines = (try? container.decode([String].self, forKey: .dislikedCuisines)) ?? []
        pantryStatus = (try? container.decode(String.self, forKey: .pantryStatus)) ?? "Basic"
        avatarEmoji = (try? container.decode(String.self, forKey: .avatarEmoji)) ?? ""
        calorieGoal = try? container.decodeIfPresent(Int.self, forKey: .calorieGoal)
        
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
    
    init(id: String, userId: String, age: Int, gender: String, height: Double, weight: Double, activityLevel: String, fitnessGoal: String, dietaryPreferences: [String], budgetRange: String, preferredCuisines: [String], cookingSkillLevel: String, preferredPrepTime: Int, preferredServings: Int, allergies: [String], favoriteIngredients: [String], dislikedIngredients: [String], includeMealPrep: Bool, includeShoppingList: Bool, includeNutritionInfo: Bool, rotateMeals: Bool, includeLeftovers: Bool, preferredComplexity: String, additionalNotes: String?, isCompleted: Bool, currentStep: Int, totalSteps: Int, createdAt: Date, updatedAt: Date, onboardingGoals: [String] = [], foodPreference: String = "Flexible", dislikedCuisines: [String] = [], pantryStatus: String = "Basic", avatarEmoji: String = "", calorieGoal: Int? = nil) {
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
        self.onboardingGoals = onboardingGoals
        self.foodPreference = foodPreference
        self.dislikedCuisines = dislikedCuisines
        self.pantryStatus = pantryStatus
        self.avatarEmoji = avatarEmoji
        self.calorieGoal = calorieGoal
    }
    
    // MARK: - Computed Properties

    var bmi: Double {
        let heightInMeters = height / 100.0
        return weight / (heightInMeters * heightInMeters)
    }
    
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
    
    /// Estimated daily calorie needs using Mifflin-St Jeor equation + activity multiplier.
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
    
    var progressPercentage: Double {
        guard totalSteps > 0 else { return 0.0 }
        return Double(currentStep) / Double(totalSteps) * 100.0
    }

    var isInProgress: Bool { !isCompleted && currentStep > 0 }
    var hasStarted: Bool { currentStep > 0 }
    var hasDietaryRestrictions: Bool { !dietaryPreferences.isEmpty }
    var hasAllergies: Bool { !allergies.isEmpty }
    var hasFavoriteIngredients: Bool { !favoriteIngredients.isEmpty }
    var hasDislikedIngredients: Bool { !dislikedIngredients.isEmpty }
    var hasPreferredCuisines: Bool { !preferredCuisines.isEmpty }

    var formattedHeight: String {
        // Convert to feet and inches for display
        let totalInches = height / 2.54
        let feet = Int(totalInches / 12)
        let inches = Int(totalInches.truncatingRemainder(dividingBy: 12))
        return "\(feet)'\(inches)\" (\(Int(height)) cm)"
    }
    
    var formattedWeight: String {
        let pounds = weight * 2.20462
        return "\(Int(pounds)) lbs (\(Int(weight)) kg)"
    }
    
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

    func hasDietaryPreference(_ preference: String) -> Bool {
        return dietaryPreferences.contains { $0.lowercased() == preference.lowercased() }
    }

    func hasAllergy(_ allergy: String) -> Bool {
        return allergies.contains { $0.lowercased() == allergy.lowercased() }
    }

    func likesIngredient(_ ingredient: String) -> Bool {
        return favoriteIngredients.contains { $0.lowercased() == ingredient.lowercased() }
    }

    func dislikesIngredient(_ ingredient: String) -> Bool {
        return dislikedIngredients.contains { $0.lowercased() == ingredient.lowercased() }
    }

    func prefersCuisine(_ cuisine: String) -> Bool {
        return preferredCuisines.contains { $0.lowercased() == cuisine.lowercased() }
    }

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

// MARK: - Static Options

extension OnboardingData {
    static let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]
    static let activityLevels = ["Sedentary", "Lightly Active", "Moderately Active", "Very Active", "Extremely Active"]
    static let fitnessGoals = ["Lose Weight", "Maintain Weight", "Gain Weight", "Build Muscle"]
    static let dietaryPreferences = ["Vegetarian", "Vegan", "Gluten-Free", "Dairy-Free", "Keto", "Paleo", "Mediterranean", "Low Carb", "High Protein", "Low Fat", "Low Sodium", "None"]
    static let budgetRanges = ["Low", "Medium", "High"]
    static let cuisineTypes = ["Italian", "Mexican", "Asian", "Mediterranean", "American", "Indian", "French", "Thai", "Japanese", "Greek", "Spanish", "Middle Eastern", "African", "Caribbean", "Other"]
    static let cookingSkillLevels = ["Beginner", "Intermediate", "Advanced"]
    static let mealComplexities = ["Easy", "Medium", "Hard"]
    static let prepTimeOptions = [15, 30, 45, 60, 90, 120]
    static let servingSizeOptions = [1, 2, 3, 4, 5, 6, 8, 10]
    static let commonAllergies = ["Peanuts", "Tree Nuts", "Milk", "Eggs", "Soy", "Fish", "Shellfish", "Wheat", "Gluten", "Lactose", "Sesame", "None"]
    static let commonIngredients = ["Chicken", "Beef", "Fish", "Shrimp", "Tofu", "Quinoa", "Rice", "Pasta", "Bread", "Avocado", "Tomatoes", "Onions", "Garlic", "Mushrooms", "Spinach", "Kale", "Broccoli", "Carrots", "Potatoes", "Sweet Potatoes", "Olives", "Cheese", "Yogurt", "Eggs", "Nuts", "Seeds", "Herbs", "Spices"]
}

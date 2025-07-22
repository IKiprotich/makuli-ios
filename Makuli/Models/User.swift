//
//  User.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import Foundation

/**
 * User Model
 * 
 * Represents a user entity in the Makuli meal planning application.
 * This model contains user profile information, preferences, and authentication data.
 * 
 * Key Features:
 * - User authentication and profile management
 * - Dietary preferences and restrictions
 * - Fitness goals and metrics
 * - Budget and meal planning preferences
 * 
 * Database Relationships:
 * - Has many Plans (one-to-many)
 * - Has one UserProfile (one-to-one)
 * - Has many GroceryItems (one-to-many)
 */
struct User: Identifiable, Codable {
    /// Unique identifier for the user
    let id: String
    
    /// User's email address (used for authentication)
    let email: String
    
    /// User's full name
    let fullName: String
    
    /// User's profile picture URL (optional)
    let profileImageUrl: String?
    
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
    
    /// Whether the user has completed onboarding
    let hasCompletedOnboarding: Bool
    
    /// Timestamp when the user was created
    let createdAt: Date
    
    /// Timestamp when the user was last updated
    let updatedAt: Date
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case fullName = "full_name"
        case profileImageUrl = "profile_picture_url"
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
        case hasCompletedOnboarding = "has_completed_onboarding"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        email = try container.decode(String.self, forKey: .email)
        fullName = try container.decode(String.self, forKey: .fullName)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
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
        hasCompletedOnboarding = try container.decode(Bool.self, forKey: .hasCompletedOnboarding)
        
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
     * Creates a new User instance
     * 
     * - Parameters:
     *   - id: Unique identifier
     *   - email: User's email address
     *   - fullName: User's full name
     *   - profileImageUrl: Optional profile picture URL
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
     *   - hasCompletedOnboarding: Whether onboarding is complete
     *   - createdAt: Creation timestamp
     *   - updatedAt: Last update timestamp
     */
    init(id: String, email: String, fullName: String, profileImageUrl: String?, age: Int, gender: String, height: Double, weight: Double, activityLevel: String, fitnessGoal: String, dietaryPreferences: [String], budgetRange: String, preferredCuisines: [String], cookingSkillLevel: String, preferredPrepTime: Int, preferredServings: Int, allergies: [String], favoriteIngredients: [String], dislikedIngredients: [String], hasCompletedOnboarding: Bool, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.email = email
        self.fullName = fullName
        self.profileImageUrl = profileImageUrl
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
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    /// User's name (alias for fullName)
    var name: String {
        return fullName
    }
    
    /// User's goal (alias for fitnessGoal)
    var goal: String {
        return fitnessGoal
    }
    
    /// User's diet (first dietary preference or default)
    var diet: String {
        return dietaryPreferences.first ?? "Balanced"
    }
    
    /// User's budget (alias for budgetRange)
    var budget: String {
        return budgetRange
    }
    
    /// Whether user has premium access (placeholder - would be from subscription)
    var isPremium: Bool {
        return false // Placeholder - would be determined by subscription status
    }
    
    /// Subscription renewal date (placeholder - would be from subscription)
    var subscriptionRenewalDate: String? {
        return nil // Placeholder - would be from subscription data
    }
    
    /// Whether user has completed onboarding (alias for hasCompletedOnboarding)
    var isOnboardingCompleted: Bool {
        return hasCompletedOnboarding
    }
    
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
     * Validated profile picture URL that can be safely loaded
     * 
     * - Returns: URL if valid, nil otherwise
     */
    var validProfileImageUrl: URL? {
        guard let profileImageUrl = profileImageUrl, !profileImageUrl.isEmpty else { return nil }
        return URL(string: profileImageUrl)
    }
    
    /**
     * User's display name (first name only)
     * 
     * - Returns: First name extracted from full name
     */
    var displayName: String {
        let components = fullName.components(separatedBy: " ")
        return components.first ?? fullName
    }
    
    /**
     * User's initials for avatar display
     * 
     * - Returns: First letter of first and last name
     */
    var initials: String {
        let components = fullName.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.last?.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
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
}

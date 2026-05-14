//
//  User.swift
//  Makuli
//
//  Created by Ian on 2025-06-25.
//

import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    let fullName: String
    let profileImageUrl: String?
    let age: Int
    let gender: String
    let height: Double
    let weight: Double
    let activityLevel: String
    let fitnessGoal: String
    let dietaryPreferences: [String]
    let budgetRange: String
    let preferredCuisines: [String]
    let cookingSkillLevel: String
    let preferredPrepTime: Int
    let preferredServings: Int
    let allergies: [String]
    let favoriteIngredients: [String]
    let dislikedIngredients: [String]
    let hasCompletedOnboarding: Bool
    let createdAt: Date
    let updatedAt: Date

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

    var name: String { fullName }
    var goal: String { fitnessGoal }
    var diet: String { dietaryPreferences.first ?? "Balanced" }
    var budget: String { budgetRange }
    var isOnboardingCompleted: Bool { hasCompletedOnboarding }

    var isPremium: Bool { false }
    var subscriptionRenewalDate: String? { nil }

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
    
    var estimatedDailyCalories: Int {
        let bmr: Double
        if gender.lowercased() == "male" {
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) + 5
        } else {
            bmr = (10 * weight) + (6.25 * height) - (5 * Double(age)) - 161
        }
        
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
    
    var validProfileImageUrl: URL? {
        guard let profileImageUrl = profileImageUrl, !profileImageUrl.isEmpty else { return nil }
        return URL(string: profileImageUrl)
    }

    var displayName: String {
        let components = fullName.components(separatedBy: " ")
        return components.first ?? fullName
    }

    var initials: String {
        let components = fullName.components(separatedBy: " ")
        let firstInitial = components.first?.first?.uppercased() ?? ""
        let lastInitial = components.last?.first?.uppercased() ?? ""
        return "\(firstInitial)\(lastInitial)"
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
}

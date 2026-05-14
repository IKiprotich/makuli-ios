//
//  TemplateTypes.swift
//  Makuli
//
//  Created by Ian on 2025-07-22.
//

import Foundation

struct TemplateMeal: Codable, Identifiable {
    let id: UUID
    let dayOfWeek: String
    let mealType: String
    let day: String
    let mealName: String
    let ingredients: [String]
    let instructions: [String]
    let cookingTime: Int
    let recipeId: String?
    let difficulty: String?
    let position: Int
    let estimatedCost: Double?
    let calories: Int?
    let prepTime: Int?
}

struct FullMealPlanTemplate: Codable, Identifiable {
    let id: UUID
    let templateName: String
    let meals: [TemplateMeal]
}

struct CreateMealPlanTemplateRequest: Codable {
    let name: String
    let description: String
    let category: String
    let difficulty: String
    let durationDays: Int
    let estimatedCostMin: Double
    let estimatedCostMax: Double
    let imageUrl: String?
    let tags: [String]
    let icon: String
    let colorScheme: String?
    let targetCaloriesPerDay: Int?
    let macros: String?

    enum CodingKeys: String, CodingKey {
        case name
        case description
        case category
        case difficulty
        case durationDays = "duration_days"
        case estimatedCostMin = "estimated_cost_min"
        case estimatedCostMax = "estimated_cost_max"
        case imageUrl = "image_url"
        case tags
        case icon
        case colorScheme = "color_scheme"
        case targetCaloriesPerDay = "target_calories_per_day"
        case macros
    }
}

struct CreateTemplateMealRequest: Codable {
    let templateId: String
    let dayOfWeek: Int
    let mealType: String
    let mealName: String
    let recipeId: String?
    let cookingTime: Int?
    let difficulty: String?
    let position: Int
    let day: String
    let estimatedCost: Double?
    let calories: Int?
    let prepTime: Int?
    let ingredients: [String]?
    let instructions: [String]?

    enum CodingKeys: String, CodingKey {
        case templateId = "template_id"
        case dayOfWeek = "day_of_week"
        case mealType = "meal_type"
        case mealName = "meal_name"
        case recipeId = "recipe_id"
        case cookingTime = "cooking_time"
        case difficulty
        case position
        case day
        case estimatedCost = "estimated_cost"
        case calories
        case prepTime = "prep_time"
        case ingredients
        case instructions
    }
}

enum TemplateCategory: String, Codable, CaseIterable {
    case mediterranean, budget, keto, vegan, other, asianFusion, mexican, italian, highProtein, mealPrep, globalCuisine, quick, healthy, comfort, vegetarian, family

    var icon: String {
        switch self {
        case .mediterranean: return " 957"
        case .budget: return " 4b8"
        case .keto: return " 969"
        case .vegan: return " 331"
        case .other: return " 66c"
        case .asianFusion: return " 35c"
        case .mexican: return " 32e"
        case .italian: return " 35d"
        case .highProtein: return " 4aa"
        case .mealPrep: return " 9d1 00d 373"
        case .globalCuisine: return " 30d"
        case .quick: return " 6a1"
        case .healthy: return " 34f"
        case .comfort: return " 372"
        case .vegetarian: return " 966"
        case .family: return " 468 00d 469 00d 467 00d 466"
        }
    }
}

struct DayMeals: Codable {
    let breakfast: TemplateMeal?
    let lunch: TemplateMeal?
    let dinner: TemplateMeal?
}

struct PlanDayMeals: Codable {
    let day: String
    let dayOfWeek: Int
    let breakfast: [PlanRecipe]
    let lunch: [PlanRecipe]
    let dinner: [PlanRecipe]
    let snacks: [PlanRecipe]
}

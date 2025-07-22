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
    // Add more properties as needed
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
    let isActive: Bool
    let icon: String
    let colorScheme: String?
    let targetCaloriesPerDay: Int?
    let macros: String?
    let createdBy: String
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
    // Add more properties as needed
}

struct PlanDayMeals: Codable {
    let day: String
    let dayOfWeek: Int
    let breakfast: [PlanRecipe]
    let lunch: [PlanRecipe]
    let dinner: [PlanRecipe]
    let snacks: [PlanRecipe]
}

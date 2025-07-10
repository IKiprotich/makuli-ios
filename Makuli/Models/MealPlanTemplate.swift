//
//  MealPlanTemplate.swift
//  Makuli
//
//  Created by Ian on 2025-01-08.
//
//  Models for meal plan templates stored in Supabase database.
//

import Foundation

// MARK: - Database Models

/// Represents a meal plan template stored in Supabase 'meal_plan_templates' table
struct MealPlanTemplate: Codable, Identifiable {
    let id: String
    let name: String
    let description: String
    let category: String // "mediterranean", "keto", "budget", etc.
    let difficulty: String // "beginner", "intermediate", "advanced"
    let durationDays: Int // Usually 7 for weekly plans
    let estimatedCostMin: Double
    let estimatedCostMax: Double
    let imageUrl: String?
    let tags: [String] // ["healthy", "quick", "vegetarian", etc.]
    let isActive: Bool
    let popularityScore: Int? // For ranking popular templates
    let createdAt: String
    let updatedAt: String?
    let createdBy: String?
    
    // Template metadata from production schema
    let icon: String?
    let colorScheme: String?
    let targetCaloriesPerDay: Int?
    let macros: MacroDistribution?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case category
        case difficulty
        case durationDays = "duration_days"
        case estimatedCostMin = "estimated_cost_min"
        case estimatedCostMax = "estimated_cost_max"
        case imageUrl = "image_url"
        case tags
        case isActive = "is_active"
        case popularityScore = "popularity_score"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case icon
        case colorScheme = "color_scheme"
        case targetCaloriesPerDay = "target_calories_per_day"
        case macros
    }
    
    // MARK: - Custom Decoding
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode simple fields
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        category = try container.decode(String.self, forKey: .category)
        difficulty = try container.decode(String.self, forKey: .difficulty)
        durationDays = try container.decode(Int.self, forKey: .durationDays)
        estimatedCostMin = try container.decode(Double.self, forKey: .estimatedCostMin)
        estimatedCostMax = try container.decode(Double.self, forKey: .estimatedCostMax)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        isActive = try container.decode(Bool.self, forKey: .isActive)
        popularityScore = try container.decodeIfPresent(Int.self, forKey: .popularityScore)
        createdAt = try container.decode(String.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(String.self, forKey: .updatedAt)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        icon = try container.decodeIfPresent(String.self, forKey: .icon)
        colorScheme = try container.decodeIfPresent(String.self, forKey: .colorScheme)
        targetCaloriesPerDay = try container.decodeIfPresent(Int.self, forKey: .targetCaloriesPerDay)
        macros = try container.decodeIfPresent(MacroDistribution.self, forKey: .macros)
        
        // Custom decoding for tags - handle both string and array formats
        do {
            // Try to decode as array first
            tags = try container.decode([String].self, forKey: .tags)
        } catch {
            // If that fails, try to decode as string and split by comma
            do {
                let tagsString = try container.decode(String.self, forKey: .tags)
                if tagsString.isEmpty {
                    tags = []
                } else {
                    tags = tagsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                }
            } catch {
                // If both fail, default to empty array
                tags = []
            }
        }
    }
}

/// Macro distribution for nutrition tracking
struct MacroDistribution: Codable {
    let protein: Int // Percentage
    let carbs: Int // Percentage
    let fat: Int // Percentage
}

/// Represents template meals stored in Supabase 'template_meals' table
struct TemplateMeal: Codable, Identifiable {
    let id: String
    let templateId: String
    let dayOfWeek: Int // 0-6 (Sunday-Saturday)
    let mealType: String // "breakfast", "lunch", "dinner", "snack"
    let mealName: String
    let recipeId: String?
    let cookingTime: Int?
    let difficulty: String?
    let position: Int // Order within the day
    let day: String // "Monday", "Tuesday", etc.
    let estimatedCost: Double?
    
    // Meal metadata from production schema
    let calories: Int?
    let prepTime: Int?
    let ingredients: [String]?
    let instructions: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
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
    
    // MARK: - Custom Decoding
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode simple fields
        id = try container.decode(String.self, forKey: .id)
        templateId = try container.decode(String.self, forKey: .templateId)
        dayOfWeek = try container.decode(Int.self, forKey: .dayOfWeek)
        mealType = try container.decode(String.self, forKey: .mealType)
        mealName = try container.decode(String.self, forKey: .mealName)
        recipeId = try container.decodeIfPresent(String.self, forKey: .recipeId)
        cookingTime = try container.decodeIfPresent(Int.self, forKey: .cookingTime)
        difficulty = try container.decodeIfPresent(String.self, forKey: .difficulty)
        position = try container.decode(Int.self, forKey: .position)
        day = try container.decode(String.self, forKey: .day)
        estimatedCost = try container.decodeIfPresent(Double.self, forKey: .estimatedCost)
        calories = try container.decodeIfPresent(Int.self, forKey: .calories)
        prepTime = try container.decodeIfPresent(Int.self, forKey: .prepTime)
        
        // Custom decoding for ingredients array
        do {
            ingredients = try container.decodeIfPresent([String].self, forKey: .ingredients)
        } catch {
            // If array decoding fails, try string and split by comma
            if let ingredientsString = try? container.decodeIfPresent(String.self, forKey: .ingredients) {
                if ingredientsString.isEmpty {
                    ingredients = []
                } else {
                    ingredients = ingredientsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                }
            } else {
                ingredients = nil
            }
        }
        
        // Custom decoding for instructions array
        do {
            instructions = try container.decodeIfPresent([String].self, forKey: .instructions)
        } catch {
            // If array decoding fails, try string and split by comma
            if let instructionsString = try? container.decodeIfPresent(String.self, forKey: .instructions) {
                if instructionsString.isEmpty {
                    instructions = []
                } else {
                    instructions = instructionsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                }
            } else {
                instructions = nil
            }
        }
    }
}

// MARK: - Request Models

/// Request model for creating a new template
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
    let icon: String?
    let colorScheme: String?
    let targetCaloriesPerDay: Int?
    let macros: MacroDistribution?
    let createdBy: String?
    
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
        case isActive = "is_active"
        case icon
        case colorScheme = "color_scheme"
        case targetCaloriesPerDay = "target_calories_per_day"
        case macros
        case createdBy = "created_by"
    }
    
    // MARK: - Initializers
    
    init(
        name: String,
        description: String,
        category: String,
        difficulty: String,
        durationDays: Int,
        estimatedCostMin: Double,
        estimatedCostMax: Double,
        imageUrl: String? = nil,
        tags: [String],
        isActive: Bool,
        icon: String? = nil,
        colorScheme: String? = nil,
        targetCaloriesPerDay: Int? = nil,
        macros: MacroDistribution? = nil,
        createdBy: String? = nil
    ) {
        self.name = name
        self.description = description
        self.category = category
        self.difficulty = difficulty
        self.durationDays = durationDays
        self.estimatedCostMin = estimatedCostMin
        self.estimatedCostMax = estimatedCostMax
        self.imageUrl = imageUrl
        self.tags = tags
        self.isActive = isActive
        self.icon = icon
        self.colorScheme = colorScheme
        self.targetCaloriesPerDay = targetCaloriesPerDay
        self.macros = macros
        self.createdBy = createdBy
    }
}

/// Request model for adding meals to a template
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

// MARK: - Response Models

/// Full template with meals for UI display
struct FullMealPlanTemplate: Identifiable {
    let id: String
    let template: MealPlanTemplate
    let meals: [TemplateMeal]
    
    /// Groups meals by day for easier UI consumption
    var mealsByDay: [String: [TemplateMeal]] {
        Dictionary(grouping: meals) { $0.day }
    }
    
    /// Gets meals for a specific day and meal type
    func meals(for day: String, type: String) -> [TemplateMeal] {
        return meals.filter { $0.day == day && $0.mealType == type }
    }
    
    /// Total estimated cost for the template
    var totalEstimatedCost: Double {
        let mealCosts = meals.compactMap { $0.estimatedCost }.reduce(0, +)
        return mealCosts
    }
    
    /// Total calories per day (average)
    var averageCaloriesPerDay: Int {
        let totalCalories = meals.compactMap { $0.calories }.reduce(0, +)
        return totalCalories / max(template.durationDays, 1)
    }
}

// MARK: - Template Categories

enum TemplateCategory: String, CaseIterable {
    case mediterranean = "mediterranean"
    case keto = "keto"
    case budget = "budget"
    case vegetarian = "vegetarian"
    case quick = "quick"
    case comfort = "comfort"
    case healthy = "healthy"
    case family = "family"
    case asian = "asian"
    case mexican = "mexican"
    case italian = "italian"
    case fitness = "fitness"
    case mealPrep = "meal-prep"
    case international = "international"
    
    var displayName: String {
        switch self {
        case .mediterranean: return "Mediterranean Week"
        case .keto: return "Ketogenic Lifestyle"
        case .budget: return "Budget-Friendly Week"
        case .vegetarian: return "Plant-Powered Vegetarian"
        case .quick: return "Quick & Easy Week"
        case .comfort: return "Ultimate Comfort Food"
        case .healthy: return "Healthy & Balanced Week"
        case .family: return "Family-Style Favorites"
        case .asian: return "Asian Fusion Week"
        case .mexican: return "Mexican Fiesta Week"
        case .italian: return "Italian Classics Week"
        case .fitness: return "High-Protein Fitness Week"
        case .mealPrep: return "Meal Prep Master"
        case .international: return "Around the World"
        }
    }
    
    var description: String {
        switch self {
        case .mediterranean:
            return "Fresh, healthy Mediterranean cuisine with olive oil, fish, and vegetables"
        case .keto:
            return "Low-carb, high-fat meals for the keto lifestyle"
        case .budget:
            return "Delicious meals on a budget using affordable ingredients"
        case .vegetarian:
            return "Delicious vegetarian meals packed with plant-based nutrition"
        case .quick:
            return "Fast meals for busy lifestyles, most under 30 minutes"
        case .comfort:
            return "Hearty, soul-warming dishes perfect for cozy nights"
        case .healthy:
            return "Nutritionally balanced meals with proper portions and variety"
        case .family:
            return "Kid-friendly meals that the whole family will love"
        case .asian:
            return "Authentic Asian flavors with modern twists"
        case .mexican:
            return "Vibrant Mexican cuisine with bold flavors and spices"
        case .italian:
            return "Traditional Italian dishes with authentic ingredients"
        case .fitness:
            return "Protein-rich meals designed for fitness enthusiasts"
        case .mealPrep:
            return "Batch-cookable meals perfect for weekly meal prep"
        case .international:
            return "A culinary journey featuring dishes from different countries"
        }
    }
    
    var icon: String {
        switch self {
        case .mediterranean: return "🫒"
        case .keto: return "🥑"
        case .budget: return "💰"
        case .vegetarian: return "🥬"
        case .quick: return "⚡"
        case .comfort: return "🍲"
        case .healthy: return "🥗"
        case .family: return "👨‍👩‍👧‍👦"
        case .asian: return "🥢"
        case .mexican: return "🌮"
        case .italian: return "🍝"
        case .fitness: return "💪"
        case .mealPrep: return "📦"
        case .international: return "🌍"
        }
    }
    
    var difficulty: String {
        switch self {
        case .budget, .quick, .comfort, .family, .mexican:
            return "beginner"
        case .mediterranean, .vegetarian, .healthy, .asian, .italian, .fitness, .keto, .mealPrep:
            return "intermediate"
        case .international:
            return "advanced"
        }
    }
    
    var estimatedCostRange: (min: Double, max: Double) {
        switch self {
        case .budget: return (35.0, 50.0)
        case .mexican: return (55.0, 75.0)
        case .vegetarian: return (60.0, 80.0)
        case .quick: return (60.0, 80.0)
        case .mealPrep: return (65.0, 90.0)
        case .comfort: return (65.0, 85.0)
        case .asian: return (70.0, 95.0)
        case .family: return (70.0, 100.0)
        case .mediterranean: return (75.0, 100.0)
        case .italian: return (80.0, 120.0)
        case .keto: return (85.0, 115.0)
        case .healthy: return (85.0, 110.0)
        case .fitness: return (90.0, 130.0)
        case .international: return (95.0, 140.0)
        }
    }
} 
//
//  SpoonacularModels.swift
//  Makuli
//
//  Created by ian on 2025-08-05.
//
//  Clean, well-architected models for Spoonacular API responses.
//  These models represent the raw data from Spoonacular API calls
//  and will be mapped to the app's existing data structures.
//

import Foundation

// MARK: - Core Spoonacular Response Models

/// Represents a meal plan response from Spoonacular's `/mealplanner/generate` endpoint.
/// This contains the weekly meal plan with meals organized by day and meal type.
struct SpoonacularMealPlan: Codable {
    let week: SpoonacularWeek
    
    /// Maps to the app's Plan model structure
    var toPlan: Plan {
        // This is now handled by SpoonacularMapper.mapMealPlan()
        fatalError("Use SpoonacularMapper.mapMealPlan() instead")
    }
}

/// Represents a week of meals in the Spoonacular meal plan response.
struct SpoonacularWeek: Codable {
    let monday: SpoonacularDayMeals?
    let tuesday: SpoonacularDayMeals?
    let wednesday: SpoonacularDayMeals?
    let thursday: SpoonacularDayMeals?
    let friday: SpoonacularDayMeals?
    let saturday: SpoonacularDayMeals?
    let sunday: SpoonacularDayMeals?
    
    /// Returns all days as an array for easier processing
    var allDays: [SpoonacularDayMeals] {
        return [monday, tuesday, wednesday, thursday, friday, saturday, sunday]
            .compactMap { $0 }
    }
    
    /// Returns meals for a specific day of the week (0 = Sunday, 1 = Monday, etc.)
    func mealsForDay(_ dayOfWeek: Int) -> SpoonacularDayMeals? {
        switch dayOfWeek {
        case 0: return sunday
        case 1: return monday
        case 2: return tuesday
        case 3: return wednesday
        case 4: return thursday
        case 5: return friday
        case 6: return saturday
        default: return nil
        }
    }
}

/// Represents meals for a single day in the Spoonacular meal plan.
struct SpoonacularDayMeals: Codable {
    let meals: [SpoonacularMeal]
    let nutrients: SpoonacularNutrients
    
    /// Returns all meals (no longer separated by slot since API doesn't provide slot info)
    var allMeals: [SpoonacularMeal] {
        return meals
    }
}

/// Represents a single meal in the Spoonacular meal plan.
struct SpoonacularMeal: Codable {
    let id: Int
    let imageType: String
    let title: String
    let readyInMinutes: Int
    let servings: Int
    let sourceUrl: String?
    
    /// Maps to the app's PlanRecipe model
    var toPlanRecipe: PlanRecipe {
        // This is now handled by SpoonacularMapper.createPlanRecipe()
        fatalError("Use SpoonacularMapper.createPlanRecipe() instead")
    }
}

/// Represents nutritional information for a day's meals.
struct SpoonacularNutrients: Codable {
    let calories: Double
    let protein: Double
    let fat: Double
    let carbohydrates: Double
    
    /// Custom decoding to handle both string and number formats
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode calories (should always be a number)
        calories = try container.decode(Double.self, forKey: .calories)
        
        // Decode protein (can be string or number)
        if let proteinString = try? container.decode(String.self, forKey: .protein) {
            protein = Double(proteinString.replacingOccurrences(of: "g", with: "")) ?? 0.0
        } else {
            protein = try container.decode(Double.self, forKey: .protein)
        }
        
        // Decode fat (can be string or number)
        if let fatString = try? container.decode(String.self, forKey: .fat) {
            fat = Double(fatString.replacingOccurrences(of: "g", with: "")) ?? 0.0
        } else {
            fat = try container.decode(Double.self, forKey: .fat)
        }
        
        // Decode carbohydrates (can be string or number)
        if let carbsString = try? container.decode(String.self, forKey: .carbohydrates) {
            carbohydrates = Double(carbsString.replacingOccurrences(of: "g", with: "")) ?? 0.0
        } else {
            carbohydrates = try container.decode(Double.self, forKey: .carbohydrates)
        }
    }
    
    /// Returns protein as a formatted string
    var proteinString: String {
        return "\(Int(protein))g"
    }
    
    /// Returns fat as a formatted string
    var fatString: String {
        return "\(Int(fat))g"
    }
    
    /// Returns carbohydrates as a formatted string
    var carbohydratesString: String {
        return "\(Int(carbohydrates))g"
    }
    
    /// Extracts numeric values (already numbers, so just return them)
    var proteinValue: Double {
        return protein
    }
    
    var fatValue: Double {
        return fat
    }
    
    var carbohydratesValue: Double {
        return carbohydrates
    }
}

// MARK: - Recipe Information Models

/// Represents a detailed recipe response from Spoonacular's `/recipes/{id}/information` endpoint.
/// This contains comprehensive recipe information including ingredients, instructions, and nutrition.
struct SpoonacularRecipe: Codable {
    let id: Int
    let title: String
    let image: String?
    let imageType: String?
    let servings: Int
    let readyInMinutes: Int
    let license: String?
    let sourceName: String?
    let sourceUrl: String?
    let spoonacularSourceUrl: String?
    let aggregateLikes: Int
    let healthScore: Double
    let spoonacularScore: Double
    let pricePerServing: Double
    let analyzedInstructions: [SpoonacularAnalyzedInstruction]
    let cheap: Bool
    let creditsText: String?
    let cuisines: [String]
    let dairyFree: Bool
    let diets: [String]
    let gaps: String?
    let glutenFree: Bool
    let instructions: String?
    let ketogenic: Bool?
    let lowFodmap: Bool
    let occasions: [String]
    let sustainable: Bool
    let vegan: Bool
    let vegetarian: Bool
    let veryHealthy: Bool
    let veryPopular: Bool
    let whole30: Bool?
    let weightWatcherSmartPoints: Int
    let dishTypes: [String]
    let extendedIngredients: [SpoonacularExtendedIngredient]
    let summary: String?
    let winePairing: SpoonacularWinePairing?
    
    /// Maps to the app's Recipe model
    var toRecipe: Recipe {
        // This is now handled by SpoonacularMapper.mapRecipe()
        fatalError("Use SpoonacularMapper.mapRecipe() instead")
    }
}

/// Represents an analyzed cooking instruction with steps.
struct SpoonacularAnalyzedInstruction: Codable {
    let name: String
    let steps: [SpoonacularStep]
}

/// Represents a single step in a recipe instruction.
struct SpoonacularStep: Codable {
    let number: Int
    let step: String
    let ingredients: [SpoonacularStepIngredient]
    let equipment: [SpoonacularStepEquipment]
    let length: SpoonacularStepLength?
}

/// Represents an ingredient used in a recipe step.
struct SpoonacularStepIngredient: Codable {
    let id: Int
    let name: String
    let localizedName: String
    let image: String
}

/// Represents equipment used in a recipe step.
struct SpoonacularStepEquipment: Codable {
    let id: Int
    let name: String
    let localizedName: String
    let image: String
    let temperature: SpoonacularStepTemperature?
}

/// Represents the length of time for a recipe step.
struct SpoonacularStepLength: Codable {
    let number: Int
    let unit: String
}

/// Represents temperature for cooking equipment.
struct SpoonacularStepTemperature: Codable {
    let number: Double
    let unit: String
}

/// Represents an extended ingredient with detailed information.
struct SpoonacularExtendedIngredient: Codable {
    let id: Int?
    let aisle: String?
    let amount: Double
    let unit: String
    let name: String
    let original: String
    let originalName: String
    let meta: [String]
    let image: String?
    
    /// Maps to the app's Ingredient model
    var toIngredient: Ingredient {
        // This is now handled by SpoonacularMapper.mapRecipe() which extracts ingredients
        fatalError("Use SpoonacularMapper.mapRecipe() instead")
    }
}

/// Represents wine pairing information for a recipe.
struct SpoonacularWinePairing: Codable {
    let pairedWines: [String]
    let pairingText: String
    let productMatches: [SpoonacularProductMatch]
}

/// Represents a product match for wine pairing.
struct SpoonacularProductMatch: Codable {
    let id: Int
    let title: String
    let description: String
    let price: String
    let imageUrl: String
    let averageRating: Double
    let ratingCount: Int
    let score: Double
    let link: String
}

// MARK: - Shopping List Models

/// Represents a shopping list response from Spoonacular's `/mealplanner/{username}/shopping-list` endpoint.
/// This contains aggregated ingredients for the user's meal plan.
struct SpoonacularShoppingList: Codable {
    let aisles: [SpoonacularAisle]
    let cost: Double
    let startDate: Int
    let endDate: Int
    
    /// Maps to the app's GroceryItem model array
    var toGroceryItems: [GroceryItem] {
        // This is now handled by SpoonacularMapper.mapGroceryList()
        fatalError("Use SpoonacularMapper.mapGroceryList() instead")
    }
}

/// Represents an aisle in the shopping list with grouped items.
struct SpoonacularAisle: Codable {
    let aisle: String
    let items: [SpoonacularShoppingItem]
}

/// Represents a single item in the shopping list.
struct SpoonacularShoppingItem: Codable {
    let id: Int
    let name: String
    let measures: SpoonacularMeasures
    let pantryItem: Bool
    let aisle: String
    let cost: Double
    let ingredientId: Int?
    
    /// Maps to the app's GroceryItem model
    var toGroceryItem: GroceryItem {
        // This is now handled by SpoonacularMapper.mapGroceryList()
        fatalError("Use SpoonacularMapper.mapGroceryList() instead")
    }
}

/// Represents measurement information for a shopping list item.
struct SpoonacularMeasures: Codable {
    let original: SpoonacularMeasure
    let metric: SpoonacularMeasure
    let us: SpoonacularMeasure
}

/// Represents a single measurement with amount and unit.
struct SpoonacularMeasure: Codable {
    let amount: Double
    let unitShort: String
    let unitLong: String
}

// MARK: - User Management Models

/// Represents a user connection response from Spoonacular's Connect User endpoint.
/// This provides the username and hash needed for user-specific operations.
struct SpoonacularUserConnection: Codable {
    let username: String
    let hash: String
    let status: String
    
    /// Maps to the app's UserProfile model fields
    var toUserProfileFields: (username: String, hash: String) {
        return (username: username, hash: hash)
    }
}

// MARK: - Error Models

/// Represents an error response from the Spoonacular API.
struct SpoonacularErrorResponse: Codable {
    let code: String?
    let message: String
    let status: String?
}

// MARK: - Request Models

/// Represents parameters for meal plan generation request.
struct SpoonacularMealPlanRequest {
    let timeFrame: String = "week"
    let targetCalories: Int?
    let diet: String?
    let exclude: String?
    let apiKey: String
    
    /// Creates query parameters for the API request
    var queryParameters: [String: String] {
        var params: [String: String] = [
            "timeFrame": timeFrame,
            "apiKey": apiKey
        ]
        
        if let targetCalories = targetCalories {
            params["targetCalories"] = String(targetCalories)
        }
        
        if let diet = diet {
            params["diet"] = diet
        }
        
        if let exclude = exclude {
            params["exclude"] = exclude
        }
        
        return params
    }
}

/// Represents parameters for recipe information request.
struct SpoonacularRecipeRequest {
    let recipeId: Int
    let includeNutrition: Bool
    let apiKey: String
    
    /// Creates query parameters for the API request
    var queryParameters: [String: String] {
        var params: [String: String] = [
            "apiKey": apiKey
        ]
        
        if includeNutrition {
            params["includeNutrition"] = "true"
        }
        
        return params
    }
}

/// Represents parameters for shopping list generation request.
struct SpoonacularShoppingListRequest {
    let username: String
    let hash: String
    let startDate: String
    let endDate: String
    let apiKey: String
    
    /// Creates query parameters for the API request
    var queryParameters: [String: String] {
        return [
            "username": username,
            "hash": hash,
            "start-date": startDate,
            "end-date": endDate,
            "apiKey": apiKey
        ]
    }
} 
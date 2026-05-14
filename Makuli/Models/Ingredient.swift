//
//  Ingredient.swift
//  Makuli
//
//  Created by Ian on 2025-06-22.
//

import Foundation

struct Ingredient: Identifiable, Codable {
    let id: String

    let recipeId: String
    
    let name: String
    
    let quantity: Double
    
    let unit: String

    let category: String
    
    let preparation: String?
    
    let notes: String?
    
    let isOptional: Bool
    
    let isGarnish: Bool
    
    var isCompleted: Bool
    
    let nutrition: IngredientNutrition?
    
    let allergens: [String]
    
    let substitutions: [IngredientSubstitution]
    
    let createdAt: Date
    
    let updatedAt: Date
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case recipeId = "recipe_id"
        case name
        case quantity
        case unit
        case category
        case preparation
        case notes
        case isOptional = "is_optional"
        case isGarnish = "is_garnish"
        case isCompleted = "is_completed"
        case nutrition
        case allergens
        case substitutions
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        recipeId = try container.decode(String.self, forKey: .recipeId)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(Double.self, forKey: .quantity)
        unit = try container.decode(String.self, forKey: .unit)
        category = try container.decode(String.self, forKey: .category)
        preparation = try container.decodeIfPresent(String.self, forKey: .preparation)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        isOptional = try container.decode(Bool.self, forKey: .isOptional)
        isGarnish = try container.decode(Bool.self, forKey: .isGarnish)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        nutrition = try container.decodeIfPresent(IngredientNutrition.self, forKey: .nutrition)
        allergens = try container.decode([String].self, forKey: .allergens)
        substitutions = try container.decode([IngredientSubstitution].self, forKey: .substitutions)
        
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
    
    init(id: String, recipeId: String, name: String, quantity: Double, unit: String, category: String, preparation: String?, notes: String?, isOptional: Bool, isGarnish: Bool, isCompleted: Bool, nutrition: IngredientNutrition?, allergens: [String], substitutions: [IngredientSubstitution], createdAt: Date, updatedAt: Date) {
        self.id = id
        self.recipeId = recipeId
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.preparation = preparation
        self.notes = notes
        self.isOptional = isOptional
        self.isGarnish = isGarnish
        self.isCompleted = isCompleted
        self.nutrition = nutrition
        self.allergens = allergens
        self.substitutions = substitutions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    var formattedQuantity: String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(quantity)) \(unit)"
        } else {
            return "\(quantity) \(unit)"
        }
    }
    

    var displayName: String {
        if isOptional {
            return "\(name) (optional)"
        } else {
            return name
        }
    }
    
    var hasAllergens: Bool {
        return !allergens.isEmpty
    }
    
    var hasSubstitutions: Bool {
        return !substitutions.isEmpty
    }
    

    var categoryColor: String {
        switch category.lowercased() {
        case "produce", "vegetables", "fruits":
            return "SuccessGreen"
        case "dairy", "milk", "cheese":
            return "BackgroundCream"
        case "protein", "meat", "fish":
            return "WarnRed"
        case "pantry", "grains", "canned":
            return "PrimaryOrange"
        case "spices", "herbs", "seasonings":
            return "WarmSand"
        default:
            return "TextCharcoal"
        }
    }
    
    
    var allergenWarning: String {
        guard !allergens.isEmpty else { return "" }
        return "Contains: \(allergens.joined(separator: ", "))"
    }
    
    // MARK: - Helper Methods
    
    func containsAllergen(_ allergen: String) -> Bool {
        return allergens.contains { $0.lowercased() == allergen.lowercased() }
    }
    
    func substitutionsForRestriction(_ restriction: String) -> [IngredientSubstitution] {
        return substitutions.filter { $0.dietaryRestrictions.contains { $0.lowercased() == restriction.lowercased() } }
    }

    func withQuantity(_ newQuantity: Double) -> Ingredient {
        return Ingredient(
            id: id,
            recipeId: recipeId,
            name: name,
            quantity: newQuantity,
            unit: unit,
            category: category,
            preparation: preparation,
            notes: notes,
            isOptional: isOptional,
            isGarnish: isGarnish,
            isCompleted: isCompleted,
            nutrition: nutrition,
            allergens: allergens,
            substitutions: substitutions,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    func withPreparation(_ newPreparation: String?) -> Ingredient {
        return Ingredient(
            id: id,
            recipeId: recipeId,
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            preparation: newPreparation,
            notes: notes,
            isOptional: isOptional,
            isGarnish: isGarnish,
            isCompleted: isCompleted,
            nutrition: nutrition,
            allergens: allergens,
            substitutions: substitutions,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}

struct IngredientNutrition: Codable {
    let calories: Double
    
    let protein: Double
    
    let carbohydrates: Double
    
    let fat: Double
    
    let fiber: Double
    
    let sugar: Double
    
    let sodium: Double
    
    let servingSize: String
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case calories
        case protein
        case carbohydrates
        case fat
        case fiber
        case sugar
        case sodium
        case servingSize = "serving_size"
    }
    
    // MARK: - Convenience Initializer
    
    init(calories: Double, protein: Double, carbohydrates: Double, fat: Double, fiber: Double, sugar: Double, sodium: Double, servingSize: String) {
        self.calories = calories
        self.protein = protein
        self.carbohydrates = carbohydrates
        self.fat = fat
        self.fiber = fiber
        self.sugar = sugar
        self.sodium = sodium
        self.servingSize = servingSize
    }
}

struct IngredientSubstitution: Codable {
    let name: String
    
    let quantity: Double
    
    let unit: String
    
    let dietaryRestrictions: [String]
    
    let instructions: String
    
    let notes: String?
    
    let isOneToOne: Bool
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case name
        case quantity
        case unit
        case dietaryRestrictions = "dietary_restrictions"
        case instructions
        case notes
        case isOneToOne = "is_one_to_one"
    }
    
    // MARK: - Convenience Initializer

    init(name: String, quantity: Double, unit: String, dietaryRestrictions: [String], instructions: String, notes: String?, isOneToOne: Bool) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.dietaryRestrictions = dietaryRestrictions
        self.instructions = instructions
        self.notes = notes
        self.isOneToOne = isOneToOne
    }
    
    // MARK: - Computed Properties
    
    var formattedQuantity: String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(quantity)) \(unit)"
        } else {
            return "\(quantity) \(unit)"
        }
    }
    
    var displayName: String {
        if !dietaryRestrictions.isEmpty {
            let restrictions = dietaryRestrictions.joined(separator: ", ")
            return "\(name) (\(restrictions))"
        } else {
            return name
        }
    }
}

// MARK: - Ingredient Extensions

extension Ingredient {
  
    static let standardCategories = [
        "Produce",
        "Dairy & Eggs",
        "Protein",
        "Grains & Pasta",
        "Pantry",
        "Spices & Herbs",
        "Condiments",
        "Beverages",
        "Frozen",
        "Canned Goods",
        "Nuts & Seeds",
        "Bakery",
        "Other"
    ]
    
  
    static let standardUnits = [
        "cups",
        "tbsp",
        "tsp",
        "grams",
        "kg",
        "ounces",
        "lbs",
        "pieces",
        "cloves",
        "bunches",
        "cans",
        "packages",
        "slices",
        "whole"
    ]
    
   
    static let commonAllergens = [
        "Gluten",
        "Dairy",
        "Eggs",
        "Soy",
        "Nuts",
        "Peanuts",
        "Fish",
        "Shellfish",
        "Wheat",
        "Sesame"
    ]
}

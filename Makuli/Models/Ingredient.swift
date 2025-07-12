//
//  Ingredient.swift
//  Makuli
//
//  Created by Ian   on 22/06/2025.
//

import Foundation

/**
 * Ingredient Model
 * 
 * Represents an ingredient used in recipes.
 * This model contains detailed information about ingredients including nutritional data,
 * substitutions, and preparation instructions.
 * 
 * Key Features:
 * - Ingredient name, quantity, and unit tracking
 * - Nutritional information per serving
 * - Substitution options for dietary restrictions
 * - Preparation instructions and notes
 * - Category and allergen information
 * 
 * Database Relationships:
 * - Belongs to a Recipe (via recipe_id)
 * - Can have multiple substitutions
 * - Can be linked to grocery items
 */
struct Ingredient: Identifiable, Codable {
    /// Unique identifier for the ingredient
    let id: String
    
    /// Reference to the recipe this ingredient belongs to
    let recipeId: String
    
    /// Name of the ingredient
    let name: String
    
    /// Quantity needed for the recipe
    let quantity: Double
    
    /// Unit of measurement (e.g., "cups", "grams", "pieces")
    let unit: String
    
    /// Category of the ingredient (e.g., "Produce", "Dairy", "Protein")
    let category: String
    
    /// Preparation instructions for this ingredient
    let preparation: String?
    
    /// Optional notes about the ingredient
    let notes: String?
    
    /// Whether this ingredient is optional
    let isOptional: Bool
    
    /// Whether this ingredient is a garnish
    let isGarnish: Bool
    
    /// Nutritional information per serving
    let nutrition: IngredientNutrition?
    
    /// Allergen information (e.g., ["Gluten", "Dairy", "Nuts"])
    let allergens: [String]
    
    /// Substitution options for this ingredient
    let substitutions: [IngredientSubstitution]
    
    /// Timestamp when the ingredient was created
    let createdAt: Date
    
    /// Timestamp when the ingredient was last updated
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
        nutrition = try container.decodeIfPresent(IngredientNutrition.self, forKey: .nutrition)
        allergens = try container.decode([String].self, forKey: .allergens)
        substitutions = try container.decode([IngredientSubstitution].self, forKey: .substitutions)
        
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
     * Creates a new Ingredient instance
     * 
     * - Parameters:
     *   - id: Unique identifier
     *   - recipeId: Reference to the recipe
     *   - name: Ingredient name
     *   - quantity: Quantity needed
     *   - unit: Unit of measurement
     *   - category: Ingredient category
     *   - preparation: Optional preparation instructions
     *   - notes: Optional notes
     *   - isOptional: Whether ingredient is optional
     *   - isGarnish: Whether ingredient is a garnish
     *   - nutrition: Optional nutritional information
     *   - allergens: Array of allergens
     *   - substitutions: Array of substitution options
     *   - createdAt: Creation timestamp
     *   - updatedAt: Last update timestamp
     */
    init(id: String, recipeId: String, name: String, quantity: Double, unit: String, category: String, preparation: String?, notes: String?, isOptional: Bool, isGarnish: Bool, nutrition: IngredientNutrition?, allergens: [String], substitutions: [IngredientSubstitution], createdAt: Date, updatedAt: Date) {
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
        self.nutrition = nutrition
        self.allergens = allergens
        self.substitutions = substitutions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // MARK: - Computed Properties
    
    /**
     * Formatted quantity string with unit
     * 
     * - Returns: Formatted string like "2.5 cups" or "3 pieces"
     */
    var formattedQuantity: String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(quantity)) \(unit)"
        } else {
            return "\(quantity) \(unit)"
        }
    }
    
    /**
     * Display name with optional indicator
     * 
     * - Returns: Name with "(optional)" suffix if optional
     */
    var displayName: String {
        if isOptional {
            return "\(name) (optional)"
        } else {
            return name
        }
    }
    
    /**
     * Whether this ingredient contains any allergens
     * 
     * - Returns: True if ingredient has allergens
     */
    var hasAllergens: Bool {
        return !allergens.isEmpty
    }
    
    /**
     * Whether this ingredient has substitution options
     * 
     * - Returns: True if ingredient has substitutions
     */
    var hasSubstitutions: Bool {
        return !substitutions.isEmpty
    }
    
    /**
     * Category color for UI display
     * 
     * - Returns: Color name based on category
     */
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
    
    /**
     * Allergen warning text
     * 
     * - Returns: Formatted allergen warning or empty string
     */
    var allergenWarning: String {
        guard !allergens.isEmpty else { return "" }
        return "Contains: \(allergens.joined(separator: ", "))"
    }
    
    // MARK: - Helper Methods
    
    /**
     * Checks if this ingredient contains a specific allergen
     * 
     * - Parameter allergen: The allergen to check for
     * - Returns: True if ingredient contains this allergen
     */
    func containsAllergen(_ allergen: String) -> Bool {
        return allergens.contains { $0.lowercased() == allergen.lowercased() }
    }
    
    /**
     * Gets substitution options for a specific dietary restriction
     * 
     * - Parameter restriction: The dietary restriction to filter by
     * - Returns: Array of substitutions that match the restriction
     */
    func substitutionsForRestriction(_ restriction: String) -> [IngredientSubstitution] {
        return substitutions.filter { $0.dietaryRestrictions.contains { $0.lowercased() == restriction.lowercased() } }
    }
    
    /**
     * Creates a copy of this ingredient with updated quantity
     * 
     * - Parameter newQuantity: New quantity value
     * - Returns: New Ingredient instance with updated quantity
     */
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
            nutrition: nutrition,
            allergens: allergens,
            substitutions: substitutions,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    /**
     * Creates a copy of this ingredient with updated preparation instructions
     * 
     * - Parameter newPreparation: New preparation instructions
     * - Returns: New Ingredient instance with updated preparation
     */
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
            nutrition: nutrition,
            allergens: allergens,
            substitutions: substitutions,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}

/**
 * IngredientNutrition Model
 * 
 * Represents nutritional information for a single ingredient.
 * Contains macronutrients and other nutritional data per serving.
 */
struct IngredientNutrition: Codable {
    /// Calories per serving
    let calories: Double
    
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
    let sodium: Double
    
    /// Serving size description
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
    
    /**
     * Creates a new IngredientNutrition instance
     * 
     * - Parameters:
     *   - calories: Calories per serving
     *   - protein: Protein content in grams
     *   - carbohydrates: Carbohydrate content in grams
     *   - fat: Fat content in grams
     *   - fiber: Fiber content in grams
     *   - sugar: Sugar content in grams
     *   - sodium: Sodium content in milligrams
     *   - servingSize: Serving size description
     */
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

/**
 * IngredientSubstitution Model
 * 
 * Represents a substitution option for an ingredient.
 * Contains alternative ingredients and their usage instructions.
 */
struct IngredientSubstitution: Codable {
    /// Name of the substitution ingredient
    let name: String
    
    /// Quantity needed for substitution
    let quantity: Double
    
    /// Unit of measurement for substitution
    let unit: String
    
    /// Dietary restrictions this substitution accommodates
    let dietaryRestrictions: [String]
    
    /// Instructions for using this substitution
    let instructions: String
    
    /// Notes about the substitution
    let notes: String?
    
    /// Whether this is a 1:1 substitution
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
    
    /**
     * Creates a new IngredientSubstitution instance
     * 
     * - Parameters:
     *   - name: Substitution ingredient name
     *   - quantity: Quantity needed
     *   - unit: Unit of measurement
     *   - dietaryRestrictions: Array of dietary restrictions
     *   - instructions: Usage instructions
     *   - notes: Optional notes
     *   - isOneToOne: Whether this is a 1:1 substitution
     */
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
    
    /**
     * Formatted quantity string with unit
     * 
     * - Returns: Formatted string like "2.5 cups" or "3 pieces"
     */
    var formattedQuantity: String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(quantity)) \(unit)"
        } else {
            return "\(quantity) \(unit)"
        }
    }
    
    /**
     * Display name with dietary restrictions
     * 
     * - Returns: Name with dietary restriction indicators
     */
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
    /**
     * Standard ingredient categories for consistent organization
     */
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
    
    /**
     * Standard units of measurement
     */
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
    
    /**
     * Common allergens
     */
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

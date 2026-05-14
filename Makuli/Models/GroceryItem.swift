//
//  GroceryItem.swift
//  Makuli
//
//  Created by Ian on 2025-06-24.
//

import Foundation

struct GroceryItem: Identifiable, Codable {

    let id: String
    
    let userId: String
    
    let name: String
    
    var quantity: Double
    
    let unit: String
    
    let category: String
    
    let priority: String
    
    var isCompleted: Bool
    
    let notes: String?
    
    let estimatedPrice: Double?
    
    let recipeId: String?
    
    let planId: String?
    
    let createdAt: Date
    
    let updatedAt: Date
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case quantity
        case unit
        case category
        case priority
        case isCompleted = "is_completed"
        case notes
        case estimatedPrice = "estimated_price"
        case recipeId = "recipe_id"
        case planId = "plan_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(Double.self, forKey: .quantity)
        unit = try container.decode(String.self, forKey: .unit)
        category = try container.decode(String.self, forKey: .category)
        priority = try container.decode(String.self, forKey: .priority)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        estimatedPrice = try container.decodeIfPresent(Double.self, forKey: .estimatedPrice)
        recipeId = try container.decodeIfPresent(String.self, forKey: .recipeId)
        planId = try container.decodeIfPresent(String.self, forKey: .planId)
        
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
    
    init(id: String, userId: String, name: String, quantity: Double, unit: String, category: String, priority: String, isCompleted: Bool, notes: String?, estimatedPrice: Double?, recipeId: String?, planId: String?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.priority = priority
        self.isCompleted = isCompleted
        self.notes = notes
        self.estimatedPrice = estimatedPrice
        self.recipeId = recipeId
        self.planId = planId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    init(id: String = UUID().uuidString, userId: String, name: String, quantity: Double = 1.0, unit: String = "pieces", category: String = "Other", priority: String = "Medium", isCompleted: Bool = false, notes: String? = nil, estimatedPrice: Double? = nil, recipeId: String? = nil, planId: String? = nil) {
        self.id = id
        self.userId = userId
        self.name = name
        self.quantity = quantity
        self.unit = unit
        self.category = category
        self.priority = priority
        self.isCompleted = isCompleted
        self.notes = notes
        self.estimatedPrice = estimatedPrice
        self.recipeId = recipeId
        self.planId = planId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Computed Properties
    
    var formattedQuantity: String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(quantity)) \(unit)"
        } else {
            return "\(quantity) \(unit)"
        }
    }
    
    var formattedPrice: String {
        guard let price = estimatedPrice else {
            return "Price not set"
        }
        return String(format: "$%.2f", price)
    }
    

    var priorityLevel: Int {
        switch priority.lowercased() {
        case "high":
            return 1
        case "medium":
            return 2
        case "low":
            return 3
        default:
            return 2
        }
    }
    

    var priorityColor: String {
        switch priority.lowercased() {
        case "high":
            return "WarnRed"
        case "medium":
            return "PrimaryOrange"
        case "low":
            return "SuccessGreen"
        default:
            return "TextCharcoal"
        }
    }
    
    var categoryColor: String {
        switch category.lowercased() {
        case "produce", "vegetables", "fruits":
            return "SuccessGreen"
        case "dairy", "milk", "cheese":
            return "BackgroundCream"
        case "meat", "protein":
            return "WarnRed"
        case "pantry", "grains", "canned":
            return "PrimaryOrange"
        case "frozen":
            return "WarmSand"
        default:
            return "TextCharcoal"
        }
    }
    
    var isLinkedToRecipe: Bool {
        return recipeId != nil
    }
    
    var isLinkedToPlan: Bool {
        return planId != nil
    }
    
    // MARK: - Helper Methods
    
    func withCompletionStatus(_ completed: Bool) -> GroceryItem {
        return GroceryItem(
            id: id,
            userId: userId,
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            priority: priority,
            isCompleted: completed,
            notes: notes,
            estimatedPrice: estimatedPrice,
            recipeId: recipeId,
            planId: planId,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    

    func withQuantity(_ newQuantity: Double) -> GroceryItem {
        return GroceryItem(
            id: id,
            userId: userId,
            name: name,
            quantity: newQuantity,
            unit: unit,
            category: category,
            priority: priority,
            isCompleted: isCompleted,
            notes: notes,
            estimatedPrice: estimatedPrice,
            recipeId: recipeId,
            planId: planId,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    func withPriority(_ newPriority: String) -> GroceryItem {
        return GroceryItem(
            id: id,
            userId: userId,
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            priority: newPriority,
            isCompleted: isCompleted,
            notes: notes,
            estimatedPrice: estimatedPrice,
            recipeId: recipeId,
            planId: planId,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    func withNotes(_ newNotes: String?) -> GroceryItem {
        return GroceryItem(
            id: id,
            userId: userId,
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            priority: priority,
            isCompleted: isCompleted,
            notes: newNotes,
            estimatedPrice: estimatedPrice,
            recipeId: recipeId,
            planId: planId,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
    
    func withPrice(_ newPrice: Double?) -> GroceryItem {
        return GroceryItem(
            id: id,
            userId: userId,
            name: name,
            quantity: quantity,
            unit: unit,
            category: category,
            priority: priority,
            isCompleted: isCompleted,
            notes: notes,
            estimatedPrice: newPrice,
            recipeId: recipeId,
            planId: planId,
            createdAt: createdAt,
            updatedAt: Date()
        )
    }
}

// MARK: - GroceryItem Extensions

extension GroceryItem {
    static let standardCategories = [
        "Produce",
        "Dairy & Eggs",
        "Meat & Seafood",
        "Pantry",
        "Frozen",
        "Beverages",
        "Snacks",
        "Bakery",
        "Condiments",
        "Spices & Herbs",
        "Canned Goods",
        "Grains & Pasta",
        "Nuts & Seeds",
        "Other"
    ]
    
    static let standardUnits = [
        "pieces",
        "kg",
        "g",
        "lbs",
        "oz",
        "cups",
        "tbsp",
        "tsp",
        "ml",
        "l",
        "packages",
        "bottles",
        "cans",
        "bags"
    ]
    
    static let priorityLevels = ["High", "Medium", "Low"]
}

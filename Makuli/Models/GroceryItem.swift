//
//  GroceryItem.swift
//  Makuli
//
//  Created by Ian   on 24/06/2025.
//

import Foundation

/**
 * GroceryItem Model
 * 
 * Represents a grocery item in a user's shopping list.
 * This model tracks items that users need to purchase for their meal plans.
 * 
 * Key Features:
 * - Item name, quantity, and unit tracking
 * - Category organization for better shopping experience
 * - Priority levels for shopping order
 * - Completion status tracking
 * - Price and budget management
 * 
 * Database Relationships:
 * - Belongs to a User (via user_id)
 * - Can be linked to specific Recipes (via recipe_id)
 * - Can be linked to specific Plans (via plan_id)
 */
struct GroceryItem: Identifiable, Codable {
    /// Unique identifier for the grocery item
    let id: String
    
    /// Reference to the user who owns this item
    let userId: String
    
    /// Name of the grocery item
    let name: String
    
    /// Quantity needed
    var quantity: Double
    
    /// Unit of measurement (e.g., "kg", "pieces", "cups")
    let unit: String
    
    /// Category for organizing items (e.g., "Produce", "Dairy", "Meat")
    let category: String
    
    /// Priority level for shopping (High, Medium, Low)
    let priority: String
    
    /// Whether the item has been purchased/completed
    var isCompleted: Bool
    
    /// Optional notes about the item
    let notes: String?
    
    /// Estimated price of the item
    let estimatedPrice: Double?
    
    /// Reference to a specific recipe (optional)
    let recipeId: String?
    
    /// Reference to a specific plan (optional)
    let planId: String?
    
    /// Timestamp when the item was created
    let createdAt: Date
    
    /// Timestamp when the item was last updated
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
     * Creates a new GroceryItem instance
     * 
     * - Parameters:
     *   - id: Unique identifier
     *   - userId: Reference to the user
     *   - name: Item name
     *   - quantity: Quantity needed
     *   - unit: Unit of measurement
     *   - category: Item category
     *   - priority: Priority level
     *   - isCompleted: Whether item is completed
     *   - notes: Optional notes
     *   - estimatedPrice: Optional estimated price
     *   - recipeId: Optional recipe reference
     *   - planId: Optional plan reference
     *   - createdAt: Creation timestamp
     *   - updatedAt: Last update timestamp
     */
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
    
    /**
     * Convenience initializer for creating grocery items with minimal parameters
     * 
     * - Parameters:
     *   - id: Unique identifier (defaults to UUID string)
     *   - userId: Reference to the user
     *   - name: Item name
     *   - quantity: Quantity needed (defaults to 1.0)
     *   - unit: Unit of measurement (defaults to "pieces")
     *   - category: Item category (defaults to "Other")
     *   - priority: Priority level (defaults to "Medium")
     *   - isCompleted: Whether item is completed (defaults to false)
     *   - notes: Optional notes (defaults to nil)
     *   - estimatedPrice: Optional estimated price (defaults to nil)
     *   - recipeId: Optional recipe reference (defaults to nil)
     *   - planId: Optional plan reference (defaults to nil)
     */
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
    
    /**
     * Formatted quantity string with unit
     * 
     * - Returns: Formatted string like "2.5 kg" or "3 pieces"
     */
    var formattedQuantity: String {
        if quantity.truncatingRemainder(dividingBy: 1) == 0 {
            return "\(Int(quantity)) \(unit)"
        } else {
            return "\(quantity) \(unit)"
        }
    }
    
    /**
     * Formatted price string
     * 
     * - Returns: Formatted price string or "Price not set"
     */
    var formattedPrice: String {
        guard let price = estimatedPrice else {
            return "Price not set"
        }
        return String(format: "$%.2f", price)
    }
    
    /**
     * Priority level as an integer for sorting
     * 
     * - Returns: Priority level (1 = High, 2 = Medium, 3 = Low)
     */
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
    
    /**
     * Priority color for UI display
     * 
     * - Returns: Color name based on priority
     */
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
    
    /**
     * Whether the item is linked to a recipe
     * 
     * - Returns: True if item has a recipe reference
     */
    var isLinkedToRecipe: Bool {
        return recipeId != nil
    }
    
    /**
     * Whether the item is linked to a plan
     * 
     * - Returns: True if item has a plan reference
     */
    var isLinkedToPlan: Bool {
        return planId != nil
    }
    
    // MARK: - Helper Methods
    
    /**
     * Creates a copy of this item with updated completion status
     * 
     * - Parameter completed: New completion status
     * - Returns: New GroceryItem instance with updated status
     */
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
    
    /**
     * Creates a copy of this item with updated quantity
     * 
     * - Parameter newQuantity: New quantity value
     * - Returns: New GroceryItem instance with updated quantity
     */
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
    
    /**
     * Creates a copy of this item with updated priority
     * 
     * - Parameter newPriority: New priority level
     * - Returns: New GroceryItem instance with updated priority
     */
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
    
    /**
     * Creates a copy of this item with updated notes
     * 
     * - Parameter newNotes: New notes text
     * - Returns: New GroceryItem instance with updated notes
     */
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
    
    /**
     * Creates a copy of this item with updated price
     * 
     * - Parameter newPrice: New estimated price
     * - Returns: New GroceryItem instance with updated price
     */
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
    /**
     * Standard grocery categories for consistent organization
     */
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
    
    /**
     * Standard units of measurement
     */
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
    
    /**
     * Priority levels
     */
    static let priorityLevels = ["High", "Medium", "Low"]
}

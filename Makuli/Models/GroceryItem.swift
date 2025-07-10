//
//  GroceryItem.swift
//  Makuli
//
//  Created by Ian   on 24/06/2025.
//

import Foundation

struct GroceryItem: Codable, Identifiable {
    let id: String
    let userId: String?
    let planId: String?
    let name: String
    var quantity: String
    let category: String
    let emoji: String
    var isChecked: Bool
    var checkedAt: Date?
    let estimatedCost: Double?
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case planId = "plan_id"
        case name
        case quantity
        case category
        case emoji
        case isChecked = "is_purchased"
        case checkedAt = "purchased_at"
        case estimatedCost = "estimated_cost"
    }
    
    init(id: String, userId: String? = nil, planId: String? = nil, name: String, quantity: String, category: String, emoji: String, isChecked: Bool = false, checkedAt: Date? = nil, estimatedCost: Double? = nil) {
        self.id = id
        self.userId = userId
        self.planId = planId
        self.name = name
        self.quantity = quantity
        self.category = category
        self.emoji = emoji
        self.isChecked = isChecked
        self.checkedAt = checkedAt
        self.estimatedCost = estimatedCost
    }
    
    // Explicit Codable implementation to ensure proper conformance
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        planId = try container.decodeIfPresent(String.self, forKey: .planId)
        name = try container.decode(String.self, forKey: .name)
        quantity = try container.decode(String.self, forKey: .quantity)
        category = try container.decode(String.self, forKey: .category)
        emoji = try container.decode(String.self, forKey: .emoji)
        isChecked = try container.decode(Bool.self, forKey: .isChecked)
        checkedAt = try container.decodeIfPresent(Date.self, forKey: .checkedAt)
        estimatedCost = try container.decodeIfPresent(Double.self, forKey: .estimatedCost)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encodeIfPresent(planId, forKey: .planId)
        try container.encode(name, forKey: .name)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(category, forKey: .category)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(isChecked, forKey: .isChecked)
        try container.encodeIfPresent(checkedAt, forKey: .checkedAt)
        try container.encodeIfPresent(estimatedCost, forKey: .estimatedCost)
    }
}

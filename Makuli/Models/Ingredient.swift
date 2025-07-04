//
//  Ingredient.swift
//  Makuli
//
//  Created by Ian   on 22/06/2025.
//

import Foundation

struct Ingredient: Codable, Identifiable, Hashable {
    var id: UUID
    let name: String
    let quantity: String
    let category: String
    let emoji: String
    var isCompleted: Bool = false
    
    init(id: UUID = UUID(), name: String, quantity: String, category: String, emoji: String, isCompleted: Bool = false) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.category = category
        self.emoji = emoji
        self.isCompleted = isCompleted
    }
    
    // Custom Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Custom Equatable implementation
    static func == (lhs: Ingredient, rhs: Ingredient) -> Bool {
        return lhs.id == rhs.id
    }
}

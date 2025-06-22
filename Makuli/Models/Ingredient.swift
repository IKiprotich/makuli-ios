//
//  Ingredient.swift
//  Makuli
//
//  Created by Ian   on 22/06/2025.
//

import Foundation

struct Ingredient: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let quantity: String
    var isCompleted: Bool = false
    
    init(name: String, quantity: String) {
        self.name = name
        self.quantity = quantity
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

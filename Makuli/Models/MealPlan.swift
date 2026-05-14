//
//  MealPlan.swift
//  Makuli
//
//  Created by Ian on 2025-06-19.
//

import Foundation

struct MealPlan: Identifiable, Codable {
    let id: String
    
    let planId: String
    
    let meals: [String: [String: [Meal]]]
    
    let createdAt: Date
    
    let updatedAt: Date
    
    var isSpoonacularGenerated: Bool = false
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case planId = "plan_id"
        case meals
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isSpoonacularGenerated
    }
    
    // MARK: - Custom Decoder
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        planId = try container.decode(String.self, forKey: .planId)
        
        let mealsData = try container.decode([String: [String: [Meal]]].self, forKey: .meals)
        meals = mealsData
        
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
        isSpoonacularGenerated = (try? container.decode(Bool.self, forKey: .isSpoonacularGenerated)) ?? false
    }
    
    // MARK: - Convenience Initializer
 
    init(id: String, planId: String, meals: [String: [String: [Meal]]], createdAt: Date, updatedAt: Date, isSpoonacularGenerated: Bool = false) {
        self.id = id
        self.planId = planId
        self.meals = meals
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isSpoonacularGenerated = isSpoonacularGenerated
    }
    
    // MARK: - Helper Methods
    

    func mealsForDay(_ day: String) -> [String: [Meal]] {
        return meals[day] ?? [:]
    }
    
    func mealsForDay(_ day: String, mealType: String) -> [Meal] {
        return meals[day]?[mealType] ?? []
    }
    
    var allDays: [String] {
        return Array(meals.keys).sorted()
    }

    var allMealTypes: [String] {
        let allTypes = Set(meals.values.flatMap { $0.keys })
        return Array(allTypes).sorted()
    }
    
    var totalMealCount: Int {
        return meals.values.flatMap { $0.values }.flatMap { $0 }.count
    }
}

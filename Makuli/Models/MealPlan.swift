//
//  MealPlan.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import Foundation

struct MealPlan {
    let id = UUID()
    let mealType: MealType
    let name: String
    let duration: Int //minutes
    let difficulty: Difficulty
    let imageName: String
    let backgroundColor: String
}

enum MealType: String, CaseIterable{
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
}

enum Difficulty: String, CaseIterable{
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
}

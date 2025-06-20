//
//  MealPlanModels.swift
//  Makuli
//
//  Created by Ian   on 20/06/2025.
//

import Foundation

struct WeekPlan: Identifiable, Hashable {
    let id = UUID()
    let weekNumber: Int
    let startDate: Date
    let endDate: Date
    let totalCost: Double
    let mealsCompleted: Int
    let totalMeals: Int
    let planName: String
    let featuredImageName: String
    let isActive: Bool
    
    var progressPercentage: Double {
        guard totalMeals > 0 else { return 0 }
        return Double(mealsCompleted) / Double(totalMeals)
    }
    
    var costFormatted: String {
        return "Ksh \(Int(totalCost).formatted())"
    }
    
    var weekTitle: String {
        return "Wk \(weekNumber)"
    }
}

struct DayPlan: Identifiable {
    let id = UUID()
    let date: Date
    let meals: [String] // Meal names for now
    let isCompleted: Bool
}

// Mock data for development
extension WeekPlan {
    static let mockData: [WeekPlan] = [
        WeekPlan(
            weekNumber: 26,
            startDate: Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 6, to: Date()) ?? Date(),
            totalCost: 1800,
            mealsCompleted: 3,
            totalMeals: 7,
            planName: "Coastal Favorites",
            featuredImageName: "meal_coastal",
            isActive: false
        ),
        WeekPlan(
            weekNumber: 25,
            startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            totalCost: 1500,
            mealsCompleted: 6,
            totalMeals: 7,
            planName: "Traditional Mix",
            featuredImageName: "meal_traditional",
            isActive: false
        ),
        WeekPlan(
            weekNumber: 24,
            startDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
            totalCost: 1200,
            mealsCompleted: 4,
            totalMeals: 7,
            planName: "Kenyan Stew",
            featuredImageName: "meal_stew",
            isActive: true
        )
    ]
}

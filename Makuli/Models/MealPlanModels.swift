//
//  MealPlanModels.swift
//  Buildplate
//
//  Created by ian on 2025-01-03.
//

import Foundation

// MARK: - Core Models
// Plan struct moved to Plan.swift for production Supabase integration

struct Meal: Identifiable, Codable {
    let id: UUID
    let name: String
    let category: MealCategory
    let cookingTime: Int // in minutes
    let difficulty: DifficultyLevel
    let imageURL: String?
    var isCompleted: Bool
    let scheduledDate: Date?
    let recipe: Recipe?
    
    init(id: UUID = UUID(), name: String, category: MealCategory, cookingTime: Int, difficulty: DifficultyLevel, imageURL: String? = nil, isCompleted: Bool = false, scheduledDate: Date? = nil, recipe: Recipe? = nil) {
        self.id = id
        self.name = name
        self.category = category
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.imageURL = imageURL
        self.isCompleted = isCompleted
        self.scheduledDate = scheduledDate
        self.recipe = recipe
    }
    
    enum MealCategory: String, CaseIterable, Codable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"
        
        var emoji: String {
            switch self {
            case .breakfast: return "🌅"
            case .lunch: return "☀️"
            case .dinner: return "🌙"
            case .snack: return "🍎"
            }
        }
        
        var displayName: String {
            return self.rawValue
        }
    }
    
    enum DifficultyLevel: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        var emoji: String {
            switch self {
            case .easy: return "😊"
            case .medium: return "😐"
            case .hard: return "😰"
            }
        }
        
        var color: String {
            switch self {
            case .easy: return "green"
            case .medium: return "orange"
            case .hard: return "red"
            }
        }
    }
}

// MARK: - Mock Data
// Plan mock data moved to Plan.swift for production integration

// MARK: - Helper Extensions
// Plan extensions moved to Plan.swift for production integration

extension Date {
    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: self)
    }
    
    var shortDayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: self)
    }
}

// MARK: - Legacy Type Aliases for UI Compatibility
// WeekPlan typealias moved to Plan.swift for production integration

// MARK: - Day Plan Model for UI
struct DayPlan: Identifiable, Codable {
    let id: UUID
    let dayName: String
    let dayNumber: String
    let meals: [Meal]
    let isCompleted: Bool
    let date: Date
    
    init(id: UUID = UUID(), dayName: String, dayNumber: String, meals: [Meal], isCompleted: Bool = false, date: Date) {
        self.id = id
        self.dayName = dayName
        self.dayNumber = dayNumber
        self.meals = meals
        self.isCompleted = isCompleted
        self.date = date
    }
    
    static func mockData() -> [DayPlan] {
        let calendar = Calendar.current
        let today = Date()
        var dayPlans: [DayPlan] = []
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: today) else { continue }
            
            let dayName = date.dayOfWeek
            let dayNumber = "\(calendar.component(.day, from: date))"
            
            // Create mock meals for this day
            let meals = [
                Meal(
                    name: "Avocado Toast with Eggs",
                    category: .breakfast,
                    cookingTime: 10,
                    difficulty: .easy,
                    isCompleted: dayOffset < 2,
                    scheduledDate: date,
                    recipe: nil
                ),
                Meal(
                    name: "Mediterranean Quinoa Bowl",
                    category: .lunch,
                    cookingTime: 25,
                    difficulty: .medium,
                    isCompleted: dayOffset < 2,
                    scheduledDate: date,
                    recipe: Recipe.mockRecipe()
                ),
                Meal(
                    name: "Grilled Salmon with Asparagus",
                    category: .dinner,
                    cookingTime: 20,
                    difficulty: .medium,
                    isCompleted: dayOffset < 1,
                    scheduledDate: date,
                    recipe: Recipe.mockRecipe()
                )
            ]
            
            let isCompleted = meals.allSatisfy { $0.isCompleted }
            
            let dayPlan = DayPlan(
                dayName: dayName,
                dayNumber: dayNumber,
                meals: meals,
                isCompleted: isCompleted,
                date: date
            )
            
            dayPlans.append(dayPlan)
        }
        
        return dayPlans
    }
}

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
    
    var dateRangeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)
        return "\(startString) - \(endString)"
    }
}

struct DayPlan: Identifiable {
    let id = UUID()
    let date: Date
    let meals: [Meal] // Updated from [String] to [Meal]
    let isCompleted: Bool
}

struct Meal: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: MealCategory
    let cookingTime: Int // minutes
    let difficulty: DifficultyLevel
    let imageURL: String?
    let isCompleted: Bool
    
    enum MealCategory: String, CaseIterable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        
        var icon: String {
            switch self {
            case .breakfast: return "sun.max.fill"
            case .lunch: return "sun.haze.fill"
            case .dinner: return "moon.stars.fill"
            }
        }
    }
    
    enum DifficultyLevel: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
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

// Enhanced DayPlan structure
extension DayPlan {
    static func mockData() -> [DayPlan] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: Int(dayOffset), to: today) ?? today
            return DayPlan(
               // id: UUID(),
                date: date,
                meals: generateMockMealsForDay(dayOffset: dayOffset),
                isCompleted: dayOffset < 3 // First 3 days completed
            )
        }
    }
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

// mock meal data with authentic Kenyan dishes
func generateMockMealsForDay(dayOffset: Int) -> [Meal] {
    let kenyanMeals = [
        // Breakfast options
        ("Mandazi", Meal.MealCategory.breakfast, 30),
        ("Chai na Mahamri", Meal.MealCategory.breakfast, 20),
        ("Githeri", Meal.MealCategory.breakfast, 45),
        
        // Lunch options
        ("Nyama Choma", Meal.MealCategory.lunch, 60),
        ("Ugali na Sukuma", Meal.MealCategory.lunch, 40),
        ("Pilau", Meal.MealCategory.lunch, 75),
        ("Samaki wa Nazi", Meal.MealCategory.lunch, 50),
        
        // Dinner options
        ("Mukimo", Meal.MealCategory.dinner, 55),
        ("Matoke Stew", Meal.MealCategory.dinner, 45),
        ("Chapati na Beans", Meal.MealCategory.dinner, 35),
        ("Chicken Curry", Meal.MealCategory.dinner, 60)
    ]
    
    let dayMeals = kenyanMeals.shuffled().prefix(3)
    
    return dayMeals.enumerated().map { index, meal in
        Meal(
           // id: UUID(),
            name: meal.0,
            category: Meal.MealCategory.allCases[index],
            cookingTime: meal.2,
            difficulty: .medium,
            imageURL: nil,
            isCompleted: dayOffset < 3 && index <= dayOffset
        )
    }
}

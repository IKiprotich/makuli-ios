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
    let meals: [Meal]
    let isCompleted: Bool
}

struct Meal: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let category: MealCategory
    let cookingTime: Int // minutes
    let difficulty: DifficultyLevel
    let imageURL: String?
    let isCompleted: Bool
    let recipe: Recipe?
    
    init(name: String, category: MealCategory, cookingTime: Int, difficulty: DifficultyLevel, imageURL: String? = nil, isCompleted: Bool = false, recipe: Recipe? = nil) {
        self.name = name
        self.category = category
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.imageURL = imageURL
        self.isCompleted = isCompleted
        self.recipe = recipe
    }
    
    // MARK: - Equatable
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum MealCategory: String, CaseIterable, Codable {
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
    
    enum DifficultyLevel: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
}

// MARK: - Mock Data Extensions
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

extension DayPlan {
    static func mockData() -> [DayPlan] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: Int(dayOffset), to: today) ?? today
            return DayPlan(
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

// MARK: - Mock meal data with authentic Kenyan dishes
func generateMockMealsForDay(dayOffset: Int) -> [Meal] {
    let kenyanMeals: [(String, Meal.MealCategory, Int, Recipe?)] = [
        // Breakfast options
        ("Mandazi", .breakfast, 30, nil),
        ("Chai na Mahamri", .breakfast, 20, nil),
        ("Githeri", .breakfast, 45, nil),
        
        // Lunch options - some with recipes
        ("Nyama Choma", .lunch, 60, Recipe.nyamaChomaRecipe),
        ("Ugali na Sukuma", .lunch, 40, nil),
        ("Pilau", .lunch, 75, Recipe.pilauRecipe),
        ("Matoke with Beans", .lunch, 45, Recipe.sampleRecipe),
        ("Samaki wa Nazi", .lunch, 50, nil),
        
        // Dinner options
        ("Mukimo", .dinner, 55, Recipe.mukimoRecipe),
        ("Matoke Stew", .dinner, 45, nil),
        ("Chapati na Beans", .dinner, 35, Recipe.chapatiRecipe),
        ("Chicken Curry", .dinner, 60, nil)
    ]
    
    // Get 3 meals for the day (breakfast, lunch, dinner)
    let categories: [Meal.MealCategory] = [.breakfast, .lunch, .dinner]
    
    return categories.map { category in
        let mealsForCategory = kenyanMeals.filter { $0.1 == category }
        let selectedMeal = mealsForCategory.randomElement() ?? kenyanMeals.first!
        
        return Meal(
            name: selectedMeal.0,
            category: category,
            cookingTime: selectedMeal.2,
            difficulty: .medium,
            imageURL: nil,
            isCompleted: dayOffset < 3, // First 3 days completed
            recipe: selectedMeal.3
        )
    }
}

//
//  MealPlanModels.swift
//  Buildplate
//
//  Created by ian on 2025-01-03.
//

import Foundation

// MARK: - Core Models
// Plan struct moved to Plan.swift for production Supabase integration

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
                    id: UUID(),
                    name: "Avocado Toast with Eggs",
                    category: .breakfast,
                    cookingTime: 10,
                    prepTime: 5,
                    cookTime: 5,
                    difficulty: .easy,
                    imageURL: nil,
                    description: "Healthy breakfast with avocado and eggs",
                    isCompleted: dayOffset < 2,
                    scheduledDate: date,
                    recipe: nil,
                    recipeId: nil
                ),
                Meal(
                    id: UUID(),
                    name: "Mediterranean Quinoa Bowl",
                    category: .lunch,
                    cookingTime: 25,
                    prepTime: 10,
                    cookTime: 15,
                    difficulty: .medium,
                    imageURL: nil,
                    description: "Nutritious quinoa bowl with Mediterranean flavors",
                    isCompleted: dayOffset < 2,
                    scheduledDate: date,
                    recipe: Recipe(
                        id: UUID().uuidString,
                        title: "Mediterranean Quinoa Bowl",
                        cookTime: "25 mins",
                        prepTime: 10,
                        servings: 2,
                        calories: 350,
                        imageUrl: nil,
                        ingredients: ["quinoa", "cucumber", "tomatoes", "olives"],
                        steps: ["Cook quinoa", "Chop vegetables", "Mix ingredients"],
                        substitutions: nil,
                        tags: ["healthy", "vegetarian", "quick"],
                        difficulty: "medium",
                        cuisineType: "mediterranean",
                        costEstimate: 8.0,
                        createdAt: Date(),
                        updatedAt: Date(),
                        createdBy: nil,
                        isPublic: true,
                        rating: 4.5,
                        ratingCount: 10
                    ),
                    recipeId: UUID().uuidString
                ),
                Meal(
                    id: UUID(),
                    name: "Grilled Salmon with Asparagus",
                    category: .dinner,
                    cookingTime: 20,
                    prepTime: 5,
                    cookTime: 15,
                    difficulty: .medium,
                    imageURL: nil,
                    description: "Delicious grilled salmon with fresh asparagus",
                    isCompleted: dayOffset < 1,
                    scheduledDate: date,
                    recipe: Recipe(
                        id: UUID().uuidString,
                        title: "Grilled Salmon with Asparagus",
                        cookTime: "20 mins",
                        prepTime: 5,
                        servings: 2,
                        calories: 450,
                        imageUrl: nil,
                        ingredients: ["salmon fillet", "asparagus", "lemon", "olive oil"],
                        steps: ["Season salmon", "Grill salmon", "Cook asparagus"],
                        substitutions: nil,
                        tags: ["healthy", "high-protein", "quick"],
                        difficulty: "medium",
                        cuisineType: "american",
                        costEstimate: 15.0,
                        createdAt: Date(),
                        updatedAt: Date(),
                        createdBy: nil,
                        isPublic: true,
                        rating: 4.8,
                        ratingCount: 15
                    ),
                    recipeId: UUID().uuidString
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

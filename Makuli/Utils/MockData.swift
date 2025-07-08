//
//  MockData.swift
//  Buildplate
//
//  Created by ian on 2025-01-03.
//

import Foundation

extension ProgressMetrics {
    static let sampleData: [ProgressMetrics] = [
        ProgressMetrics(title: "This Week", value: "5/7", change: "+2", isPositive: true),
        ProgressMetrics(title: "Calories", value: "1,850", change: "-150", isPositive: true),
        ProgressMetrics(title: "Protein", value: "85g", change: "+10g", isPositive: true),
        ProgressMetrics(title: "Budget Usage", value: "$67.50", change: "-$8.25", isPositive: true),
    ]
}

// MARK: - Sample Meal Plans
extension MealPlan {
    static let sampleMeals: [MealPlan] = [
        MealPlan(
            mealType: .breakfast,
            name: "Avocado Toast with Eggs",
            duration: 10,
            difficulty: .easy,
            imageName: "cup.and.saucer",
            backgroundColor: "green"
        ),
        MealPlan(
            mealType: .lunch,
            name: "Mediterranean Quinoa Bowl",
            duration: 25,
            difficulty: .medium,
            imageName: "fork.knife",
            backgroundColor: "blue"
        ),
        MealPlan(
            mealType: .dinner,
            name: "Grilled Salmon with Asparagus",
            duration: 20,
            difficulty: .medium,
            imageName: "fish.fill",
            backgroundColor: "orange"
        )
    ]
} 
//
//  MockData.swift
//  Makuli
//
//  Created by Ian   on 30/06/2025.
//

import Foundation

struct MockData {
    // MARK: - User Mock Data
    static let mockUser = User(
        name: "John Doe",
        email: "john@example.com",
        age: 25,
        gender: "Male",
        diet: "Vegetarian",
        budget: "$100-200",
        isPremium: false,
        subscriptionRenewalDate: nil,
        profileImageURL: nil,
        isOnboardingCompleted: true
    )
    
    // MARK: - Meal Plans Mock Data
    static let sampleMeals = [
        MealPlan(
            mealType: .breakfast,
            name: "Kenyan Chai and Mandazi",
            duration: 30,
            difficulty: .easy,
            imageName: "cup.and.saucer.fill",
            backgroundColor: "orange"
        ),
        MealPlan(
            mealType: .lunch,
            name: "Sukuma Wiki with Ugali",
            duration: 45,
            difficulty: .medium,
            imageName: "leaf.fill",
            backgroundColor: "green"
        ),
        MealPlan(
            mealType: .dinner,
            name: "Nyama Choma with Kachumbari",
            duration: 60,
            difficulty: .hard,
            imageName: "flame.fill",
            backgroundColor: "red"
        )
    ]
    
    // MARK: - Progress Metrics Mock Data
    static let sampleMetrics = [
        ProgressMetrics(title: "Meals Cooked", value: "12", change: "+10%", isPositive: true),
        ProgressMetrics(title: "Budget Usage", value: "Ksh 2,500", change: "-5%", isPositive: false),
        ProgressMetrics(title: "Consistency Streak", value: "7 days", change: "+20%", isPositive: true)
    ]
} 
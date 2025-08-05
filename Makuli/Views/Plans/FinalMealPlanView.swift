//
//  FinalMealPlanView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Final meal plan view showing the created plan.
//

import SwiftUI

struct FinalMealPlanView: View {
    let startDate: Date
    let endDate: Date
    let selectedMeals: [String: [String: Bool]]
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var planViewModel = PlanViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Meal Plan")
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.text)
                        
                        Text("\(formatDateRange())")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.top, 20)
                    
                    // Enhance My Plan button
                    Button(action: {
                        // Handle enhance plan action
                    }) {
                        HStack(spacing: 8) {
                            Text("Enhance My Plan")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 16, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    AppColors.primaryOrange,
                                    AppColors.primaryOrange.opacity(0.8)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Meal plan content
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(Array(weekDays.enumerated()), id: \.offset) { index, date in
                                if hasSelectedMeals(for: date) {
                                    dayMealSection(for: date)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
            .task {
                // Save the meal plan to database
                await saveMealPlan()
            }
        }
    }
    
    private var weekDays: [Date] {
        var days: [Date] = []
        var currentDate = startDate
        while currentDate <= endDate {
            days.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        return days
    }
    
    private func dayMealSection(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Day header
            Text(formatDayHeader(date))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.textCharcoal)
                .padding(.horizontal, 20)
            
            // Meals for this day
            VStack(spacing: 12) {
                ForEach(Array(selectedMealsForDay(date).enumerated()), id: \.offset) { index, mealType in
                    if isMealSelected(for: date, mealType: mealType) {
                        dayMealCard(for: date, mealType: mealType)
                    }
                }
            }
        }
    }
    
    private func dayMealCard(for date: Date, mealType: String) -> some View {
        let mealName = getMealName(for: mealType)
        let mealImage = getMealImage(for: mealType)
        
        return HStack(spacing: 16) {
            // Meal image
            AsyncImage(url: URL(string: mealImage)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.primaryOrange.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryOrange.opacity(0.5))
                    )
            }
            .frame(width: 80, height: 80)
            .clipped()
            .cornerRadius(8)
            
            // Meal details
            VStack(alignment: .leading, spacing: 4) {
                // Meal type tag
                Text(mealType)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(getMealTypeTagColor(mealType))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                
                // Meal name
                Text(mealName)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.textCharcoal)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Options button (only show for today)
            if Calendar.current.isDateInToday(date) {
                Button(action: {
                    // Handle meal options
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.primaryOrange.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        VStack(spacing: 2) {
                            ForEach(0..<3, id: \.self) { _ in
                                Circle()
                                    .fill(AppColors.primaryOrange)
                                    .frame(width: 3, height: 3)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private func hasSelectedMeals(for date: Date) -> Bool {
        let dateKey = self.dateKey(date)
        return selectedMeals[dateKey]?.values.contains(true) ?? false
    }
    
    private func selectedMealsForDay(_ date: Date) -> [String] {
        return ["Breakfast", "Lunch", "Dinner"]
    }
    
    private func isMealSelected(for date: Date, mealType: String) -> Bool {
        let dateKey = self.dateKey(date)
        return selectedMeals[dateKey]?[mealType] ?? false
    }
    
    private func getMealName(for mealType: String) -> String {
        let sampleMeals = [
            "Breakfast": [
                "Quinoa Power Breakfast Bowl",
                "Blueberry Oatmeal",
                "Roasted Breakfast Pears"
            ],
            "Dinner": [
                "Spicy Stuffed Poblano Peppers",
                "Vegetarian Shepherd's Pie",
                "Grilled Salmon with Vegetables"
            ]
        ]
        
        let meals = sampleMeals[mealType] ?? []
        return meals.first ?? "Sample Meal"
    }
    
    private func getMealImage(for mealType: String) -> String {
        // In real app, this would be actual image URLs
        return ""
    }
    
    private func getMealTypeTagColor(_ mealType: String) -> Color {
        switch mealType {
        case "Breakfast":
            return AppColors.primaryOrange
        case "Lunch":
            return AppColors.primaryOrange
        case "Dinner":
            return AppColors.primaryOrange
        default:
            return AppColors.textCharcoal
        }
    }
    
    private func formatDayHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func formatDateRange() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, d"
        let start = formatter.string(from: startDate)
        let end = formatter.string(from: endDate)
        return "\(start) - \(end)"
    }
    
    private func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func saveMealPlan() async {
        guard let user = authViewModel.user else {
            Logger.error("No current user found for saving meal plan")
            return
        }
        
        // Create a user profile for the plan creation
        let userProfile = UserProfile(
            id: user.id,
            userId: user.id,
            name: user.fullName,
            email: user.email,
            age: user.age,
            gender: user.gender,
            goal: user.fitnessGoal,
            diet: user.dietaryPreferences.joined(separator: ", "),
            budget: user.budgetRange,
            isPremium: false,
            isOnboardingCompleted: user.hasCompletedOnboarding,
            subscriptionType: nil,
            subscriptionRenewal: nil,
            plansCreatedThisMonth: 0,
            spoonacularGenerationsThisMonth: 0,
            lastPlanReset: Date(),
            profileImageUrl: user.profileImageUrl,
            bio: nil,
            location: nil,
            preferredLanguage: nil,
            timezone: nil,
            measurementSystem: nil,
            preferredCurrency: nil,
            notificationPreferences: nil,
            privacySettings: nil,
            fitnessGoals: nil,
            mealPlanningPreferences: nil,
            dietaryPreferences: nil,
            cookingPreferences: nil,
            budgetPreferences: nil,
            achievements: nil,
            progressMetrics: nil,
            spoonacularUsername: nil,
            spoonacularHash: nil,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let success = await planViewModel.createPlanManually(
            for: user.id,
            weekStart: startDate,
            weekEnd: endDate,
            selectedMeals: selectedMeals,
            userProfile: userProfile
        )
        
        if success {
            Logger.info("Successfully saved meal plan")
            // Dismiss the view after a short delay to show success
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                dismiss()
            }
        } else {
            Logger.error("Failed to save meal plan: \(planViewModel.errorMessage ?? "Unknown error")")
            // You could show an error alert here
        }
    }
}

#Preview {
    FinalMealPlanView(
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        selectedMeals: [:]
    )
    .environmentObject(AuthViewModel())
} 

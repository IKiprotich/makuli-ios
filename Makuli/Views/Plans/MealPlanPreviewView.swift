//
//  MealPlanPreviewView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Meal plan preview view for the creation flow.
//

import SwiftUI

struct MealPlanPreviewView: View {
    let startDate: Date
    let endDate: Date
    let selectedMeals: [String: [String: Bool]]
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingFinalPlan = false
    
    // Sample meal data - in real app, this would come from your database
    private let sampleMeals = [
        "Breakfast": [
            "Quinoa Power Breakfast Bowl": "quinoa_bowl",
            "Blueberry Oatmeal": "blueberry_oatmeal",
            "Roasted Breakfast Pears": "roasted_pears"
        ],
        "Dinner": [
            "Spicy Stuffed Poblano Peppers": "poblano_peppers",
            "Vegetarian Shepherd's Pie": "shepherds_pie",
            "Grilled Salmon with Vegetables": "grilled_salmon"
        ]
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Instructional text
                    VStack(spacing: 8) {
                        Text("Here are the recipes we've chosen for your meal plan. Feel free to swap out any that you don't like!")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.text)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                    }
                    
                    // Meal plan sections
                    ScrollView {
                        VStack(spacing: 24) {
                            ForEach(Array(weekDays.enumerated()), id: \.offset) { index, date in
                                if hasSelectedMeals(for: date) {
                                    daySection(for: date)
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    
                    Spacer()
                    
                    // Save meal plan button
                    Button(action: {
                        showingFinalPlan = true
                    }) {
                        Text("Save Meal Plan")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.primaryOrange)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("Meal plan preview")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.text)
                    }
                }
            }
            .sheet(isPresented: $showingFinalPlan) {
                FinalMealPlanView(startDate: startDate, endDate: endDate, selectedMeals: selectedMeals)
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
    
    private func daySection(for date: Date) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Day header
            Text(formatDayHeader(date))
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.text)
                .padding(.horizontal, 20)
            
            // Meals for this day
            VStack(spacing: 12) {
                ForEach(Array(selectedMealsForDay(date).enumerated()), id: \.offset) { index, mealType in
                    if isMealSelected(for: date, mealType: mealType) {
                        mealCard(for: date, mealType: mealType)
                    }
                }
            }
        }
    }
    
    private func mealCard(for date: Date, mealType: String) -> some View {
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
                    .foregroundColor(AppColors.text)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Swap button
            Button(action: {
                // Handle meal swap
            }) {
                                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(AppColors.primaryOrange.opacity(0.1))
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(AppColors.primaryOrange)
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
        let meals = sampleMeals[mealType] ?? [:]
        return meals.keys.first ?? "Sample Meal"
    }
    
    private func getMealImage(for mealType: String) -> String {
        let meals = sampleMeals[mealType] ?? [:]
        return meals.values.first ?? ""
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
            return AppColors.text
        }
    }
    
    private func formatDayHeader(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

#Preview {
    MealPlanPreviewView(
        startDate: Date(),
        endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date(),
        selectedMeals: [:]
    )
} 
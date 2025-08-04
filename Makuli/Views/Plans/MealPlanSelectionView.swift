//
//  MealPlanSelectionView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Meal selection view for meal plan creation flow.
//

import SwiftUI

struct MealPlanSelectionView: View {
    let startDate: Date
    let endDate: Date
    
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMeals: [String: [String: Bool]] = [:]
    @State private var showingMealPlanPreview = false
    
    // Sample meal data - in real app, this would come from your database
    private let mealTypes = ["Breakfast", "Lunch", "Dinner"]
    private var weekDays: [Date] {
        var days: [Date] = []
        var currentDate = startDate
        while currentDate <= endDate {
            days.append(currentDate)
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
        }
        return days
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Instructional text
                    VStack(spacing: 8) {
                        Text("Below are the meals we will include in your plan. You can make any modifications here.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.text)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                    }
                    
                    // Meal plan grid
                    ScrollView {
                        VStack(spacing: 16) {
                            // Column headers
                            HStack(spacing: 12) {
                                // Empty space for day labels
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(width: 80, height: 1)
                                
                                ForEach(mealTypes, id: \.self) { mealType in
                                    Text(mealType)
                                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                                        .foregroundColor(AppColors.text)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            // Meal grid rows
                            ForEach(Array(weekDays.enumerated()), id: \.offset) { index, date in
                                HStack(spacing: 12) {
                                    // Day label
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(formatDayOfWeek(date))
                                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                                            .foregroundColor(AppColors.text)
                                        
                                        Text(formatDate(date))
                                            .font(.system(size: 12, weight: .medium, design: .rounded))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    .frame(width: 80, alignment: .leading)
                                    
                                    // Meal cells
                                    ForEach(mealTypes, id: \.self) { mealType in
                                        mealCell(for: date, mealType: mealType)
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    
                    Spacer()
                    
                    // Create button
                    Button(action: {
                        showingMealPlanPreview = true
                    }) {
                        Text("Create")
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
            .navigationTitle("Create meal plan")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(AppColors.textCharcoal)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.successGreen)
                }
            }
            .sheet(isPresented: $showingMealPlanPreview) {
                MealPlanPreviewView(startDate: startDate, endDate: endDate, selectedMeals: selectedMeals)
            }
            .onAppear {
                initializeSelectedMeals()
            }
        }
    }
    
    private func mealCell(for date: Date, mealType: String) -> some View {
        let isSelected = selectedMeals[dateKey(date)]?[mealType] ?? getDefaultSelection(for: mealType)
        
        return Button(action: {
            toggleMealSelection(for: date, mealType: mealType)
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? getMealTypeColor(mealType) : AppColors.border)
                    .frame(height: 60)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                if isSelected {
                    Image(systemName: getMealTypeIcon(mealType))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(getMealTypeIconColor(mealType))
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func initializeSelectedMeals() {
        for date in weekDays {
            let dateKey = self.dateKey(date)
            selectedMeals[dateKey] = [:]
            for mealType in mealTypes {
                selectedMeals[dateKey]?[mealType] = getDefaultSelection(for: mealType)
            }
        }
    }
    
    private func toggleMealSelection(for date: Date, mealType: String) {
        let dateKey = self.dateKey(date)
        let currentValue = selectedMeals[dateKey]?[mealType] ?? false
        selectedMeals[dateKey]?[mealType] = !currentValue
    }
    
    private func getDefaultSelection(for mealType: String) -> Bool {
        // Default selection: Breakfast and Dinner selected, Lunch not selected
        return mealType == "Breakfast" || mealType == "Dinner"
    }
    
    private func getMealTypeColor(_ mealType: String) -> Color {
        switch mealType {
        case "Breakfast", "Dinner":
            return AppColors.primaryOrange.opacity(0.15)
        case "Lunch":
            return AppColors.primaryOrange.opacity(0.15)
        default:
            return AppColors.textCharcoal.opacity(0.1)
        }
    }
    
    private func getMealTypeIcon(_ mealType: String) -> String {
        switch mealType {
        case "Breakfast", "Dinner":
            return "checkmark"
        case "Lunch":
            return "table.furniture"
        default:
            return "circle"
        }
    }
    
    private func getMealTypeIconColor(_ mealType: String) -> Color {
        switch mealType {
        case "Breakfast", "Dinner":
            return AppColors.primaryOrange
        case "Lunch":
            return AppColors.primaryOrange
        default:
            return AppColors.textCharcoal
        }
    }
    
    private func dateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formatDayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

#Preview {
    MealPlanSelectionView(startDate: Date(), endDate: Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date())
} 
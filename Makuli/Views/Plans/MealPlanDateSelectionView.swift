//
//  MealPlanDateSelectionView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Date selection view for meal plan creation flow.
//

import SwiftUI

struct MealPlanDateSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @State private var showingMealSelection = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background.ignoresSafeArea()
                
                VStack(spacing: 32) {
                    // Instructional text
                    VStack(spacing: 8) {
                        Text("We'll create a meal plan for the week. Feel free to modify the start or end date as you need.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.text)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 20)
                    }
                    
                    // Date selection fields
                    VStack(spacing: 20) {
                        // Start date field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.text)
                            
                            Button(action: {
                                // Show date picker for start date
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text("Today")
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(AppColors.text)
                                        
                                        Text(formatDate(startDate))
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppColors.primaryOrange)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(AppColors.primaryOrange.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                        
                        // End date field
                        VStack(alignment: .leading, spacing: 8) {
                            Text("End")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.text)
                            
                            Button(action: {
                                // Show date picker for end date
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(formatDayOfWeek(endDate))
                                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                                            .foregroundColor(AppColors.text)
                                        
                                        Text(formatDate(endDate))
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundColor(AppColors.textSecondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(AppColors.primaryOrange)
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(AppColors.primaryOrange.opacity(0.1))
                                .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // Next button
                    Button(action: {
                        showingMealSelection = true
                    }) {
                        Text("Next")
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
            .navigationTitle("Meal plan dates")
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
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.primaryOrange)
                }
            }
            .sheet(isPresented: $showingMealSelection) {
                MealPlanSelectionView(startDate: startDate, endDate: endDate)
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }
    
    private func formatDayOfWeek(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
}

#Preview {
    MealPlanDateSelectionView()
} 
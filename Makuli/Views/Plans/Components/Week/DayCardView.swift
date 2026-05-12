//
//  DayCardView.swift
//  Makuli
//
//  Created by Ian   on 21/06/2025.
//

import SwiftUI

struct DayCardView: View {
    
    let dayPlan: DayPlan
    @State private var expandedMeal: UUID?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            //day header
            dayHeader
            
            //meals list
            VStack(spacing: 1){
                ForEach(dayPlan.meals, id: \.id) { meal in
                    MealRowView(
                        meal: meal,
                        isExpanded: expandedMeal == meal.id,
                        onExpansionToggle: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                expandedMeal = expandedMeal == meal.id ? nil : meal.id
                            }
                        },
                        recipe: meal.recipe // pass the recipe to MealRowView
                    )
                }
                
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 10, y: 4)
        )
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Meal plan for \(dayPlan.dayName)")
    }
}

extension DayCardView {
    
    private var dayHeader: some View {
        HStack {
            Text(dayPlan.dayName)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(AppColors.text)
            
            Spacer()
            
            if dayPlan.isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(AppColors.successGreen)
                    .font(.title3)
            }
            else {
                Text(dayPlan.dayNumber)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.secondary)
                    .frame(width: 24, height: 24)
                    .background(
                        Circle()
                            .fill(Color(.systemGray5))
                    )
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
           Color(.systemGray6).opacity(0.3)
        )
        .clipShape(
            .rect(
                topLeadingRadius: 20,
                topTrailingRadius: 20
                
            )
        )
    }
}

#Preview {
    DayCardView(dayPlan: DayPlan.mockData().first!)
}

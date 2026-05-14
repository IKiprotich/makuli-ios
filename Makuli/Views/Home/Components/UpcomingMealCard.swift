//
//  UpcomingMealCard.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import SwiftUI

struct UpcomingMealCard: View {
    let meal: PlanRecipe

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(meal.customMealName ?? "Meal")
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .lineLimit(2)
                .foregroundColor(AppColors.text)

            Text(meal.mealType.capitalized)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Capsule().fill(AppColors.primaryOrange.opacity(0.1)))
                .foregroundColor(AppColors.primaryOrange)
        }
        .frame(width: 120, alignment: .leading)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.03), radius: 6, x: 0, y: 3)
        )
    }
}

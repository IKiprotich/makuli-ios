//
//  TodaysMealCard.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import SwiftUI

struct TodaysMealCard: View {
    let meal: PlanRecipe
    let onToggleCompletion: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            Button(action: onToggleCompletion) {
                ZStack {
                    Circle()
                        .fill(meal.isCompleted ? AppColors.successGreen : AppColors.border)
                        .frame(width: 32, height: 32)

                    if meal.isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(meal.customMealName ?? "Meal")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.text)
                        .strikethrough(meal.isCompleted)

                    Spacer()

                    Text(meal.mealType.capitalized)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(AppColors.primaryOrange.opacity(0.15)))
                        .foregroundColor(AppColors.primaryOrange)
                }

                if let cookTime = meal.customCookTime {
                    HStack(spacing: 6) {
                        Image(systemName: "clock")
                            .font(.system(size: 12))
                            .foregroundColor(AppColors.textSecondary)
                        Text("\(cookTime) min")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
        .opacity(meal.isCompleted ? 0.7 : 1.0)
        .scaleEffect(meal.isCompleted ? 0.98 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: meal.isCompleted)
    }
}

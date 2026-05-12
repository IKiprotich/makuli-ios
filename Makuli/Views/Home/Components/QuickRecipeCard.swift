//
//  QuickRecipeCard.swift
//  Makuli
//

import SwiftUI

struct QuickRecipeCard: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            AsyncImage(url: recipe.validImageURL) { phase in
                if let image = phase.image {
                    image.resizable().aspectRatio(contentMode: .fill)
                } else {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(AppColors.primaryOrange.opacity(0.1))
                        .overlay(
                            Image(systemName: "fork.knife")
                                .font(.system(size: 20, weight: .light))
                                .foregroundColor(AppColors.primaryOrange.opacity(0.4))
                        )
                }
            }
            .frame(width: 140, height: 90)
            .clipped()
            .cornerRadius(12)

            VStack(alignment: .leading, spacing: 4) {
                Text(recipe.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .lineLimit(2)
                    .foregroundColor(AppColors.text)

                if let cookTime = recipe.cookTime {
                    HStack(spacing: 4) {
                        Image(systemName: "clock")
                            .font(.system(size: 10))
                            .foregroundColor(AppColors.textSecondary)
                        Text("\(cookTime) min")
                            .font(.system(size: 11, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
            }
        }
        .frame(width: 140)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
        )
    }
}

//
//  RecipeCardView.swift
//  Makuli
//
//  Created by Ian on 2025-06-13.
//

import SwiftUI

struct RecipeCardView: View {
    let recipe: Recipe

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            recipeImageSection

            VStack(alignment: .leading, spacing: 8) {
                Text(recipe.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 14)
                    .padding(.top, 12)

                metadataSection
                    .padding(.horizontal, 14)

                if !recipe.tags.isEmpty {
                    tagsSection
                        .padding(.horizontal, 14)
                        .padding(.bottom, 12)
                } else {
                    Spacer().frame(height: 12)
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.07), radius: 10, x: 0, y: 4)
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Recipe: \(recipe.title)")
        .accessibilityHint("Tap to view recipe details")
    }
}

// MARK: - Subviews

extension RecipeCardView {

    private var recipeImageSection: some View {
        AsyncImage(url: recipe.validImageURL) { phase in
            if let image = phase.image {
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Rectangle()
                    .fill(AppColors.primaryOrange.opacity(0.08))
                    .overlay(
                        Image(systemName: "fork.knife")
                            .font(.system(size: 28, weight: .light))
                            .foregroundColor(AppColors.primaryOrange.opacity(0.4))
                    )
            }
        }
        .frame(height: 120)
        .clipped()
    }

    private var metadataSection: some View {
        HStack(spacing: 6) {
            HStack(spacing: 3) {
                Image(systemName: "clock")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppColors.primaryOrange)
                Text(recipe.cookTime ?? "—")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.primaryOrange)
            }
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.primaryOrange.opacity(0.1))
            )

            if recipe.rating > 0 {
                HStack(spacing: 3) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(AppColors.successGreen)
                    Text(String(format: "%.1f", recipe.rating))
                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                        .foregroundColor(AppColors.successGreen)
                }
                .padding(.horizontal, 7)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.successGreen.opacity(0.1))
                )
            }

            Spacer(minLength: 0)

            HStack(spacing: 2) {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .fill(index < difficultyLevel ? AppColors.warnRed : AppColors.border)
                        .frame(width: 5, height: 5)
                }
            }
        }
    }

    private var tagsSection: some View {
        HStack(spacing: 4) {
            ForEach(recipe.tags.prefix(2), id: \.self) { tag in
                Text(tag.capitalized)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(tagColor(for: tag))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(tagColor(for: tag).opacity(0.1))
                    )
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
        }
    }

    // MARK: - Helpers

    private var difficultyLevel: Int {
        switch recipe.difficulty?.lowercased() {
        case "easy":   return 1
        case "medium": return 2
        case "hard":   return 3
        default:       return 2
        }
    }

    private func tagColor(for tag: String) -> Color {
        switch tag.lowercased() {
        case "quick", "healthy", "vegetarian", "vegan": return AppColors.successGreen
        case "high-protein":                             return AppColors.primaryOrange
        case "budget":                                   return .blue
        case "traditional":                              return .purple
        default:                                         return AppColors.textSecondary
        }
    }
}

#if DEBUG
#Preview("Single Card") {
    RecipeCardView(recipe: Preview.recipe)
        .frame(width: 200)
        .padding()
        .background(AppColors.background)
}

#Preview("Card Grid") {
    ScrollView {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            ForEach(Preview.featuredRecipes) { recipe in
                RecipeCardView(recipe: recipe)
            }
        }
        .padding()
    }
    .background(AppColors.background)
}
#endif

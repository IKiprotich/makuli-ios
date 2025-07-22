//
//  RecipeCardView.swift
//  Makuli
//
//  Created by Ian   on 23/06/2025.
//

import SwiftUI

struct RecipeCardView: View {
    
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            
            //recipe emoji/icon
            recipeImageView
            
            //recipe title
            Text(recipe.title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.leading)
            
            //cook time and tag badges
            HStack(spacing: 8) {
                cookTimeBadge
                
                if !recipe.tags.isEmpty, let firstTag = recipe.tags.first {
                    tagBadge(firstTag)
                }
                
                Spacer()
                
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0 , y: 2)
        )
        .accessibilityElement(children: .ignore)
    }
}

extension RecipeCardView {
    //MARK: Recipe Image View
    private var recipeImageView: some View {
        ZStack {
            Circle()
                .fill(Color(.systemGray6))
                .frame(width: 80, height: 80)
            
            Text("🍽️") // Default emoji since Recipe model doesn't have imageName
                .font(.system(size: 36))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    //MARK: Cook Time Badge
    private var cookTimeBadge: some View {
        HStack (spacing: 4) {
            Image(systemName: "clock.fill")
                .font(.system(size: 10))
            
            Text("\(recipe.cookTime ?? "30") min")
                .font(.system(size: 12, weight: .medium))
        }
        .foregroundColor(.secondary)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemGray6))
        )
    }
    
    //MARK: Tag Badge
    private func tagBadge(_ tag: String) -> some View {
        Text(tag)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(tagColor(for: tag))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(tagBackgroundColor(for: tag))
            )
    }
    
    //MARK: Helper Methods
    
    //tag color
    private func tagColor(for tag: String) -> Color {
        switch tag.lowercased() {
        case "quick":
            return AppColors.successGreen
        case "high-protein":
            return AppColors.primaryOrange
        case "budget":
            return .blue
        case "traditional":
            return .purple
        case "healthy":
            return AppColors.successGreen
        default:
            return .secondary
        }
    }
    
    //tag background color
    private func tagBackgroundColor(for tag: String) -> Color {
        switch tag.lowercased() {
        case "quick":
            return AppColors.successGreen.opacity(0.1)
        case "high-protein":
            return AppColors.primaryOrange.opacity(0.1)
        case "budget":
            return Color.blue.opacity(0.1)
        case "traditional":
            return Color.purple.opacity(0.1)
        case "healthy":
            return AppColors.successGreen.opacity(0.1)
        default:
            return Color(.systemGray6)
        }
    }
}

//#Preview {
//    RecipeCardView(recipe: Recipe.mockRecipe())
//}

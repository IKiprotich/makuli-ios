//
//  ModernRecipeCardView.swift
//  Makuli
//
//  Created by ian on 2025-08-05.
//
//  Modern, vibrant recipe card component following Apple HIG.
//

import SwiftUI

struct ModernRecipeCardView: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Compact recipe image section
            compactRecipeImageSection
            
            // Compact recipe content section
            VStack(alignment: .leading, spacing: 10) {
                // Recipe title with proper constraints
                Text(recipe.title)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal, 16)
                    .padding(.top, 14)
                
                // Compact metadata section
                compactMetadataSection
                    .padding(.horizontal, 16)
                
                // Compact tags section
                if !recipe.tags.isEmpty {
                    compactTagsSection
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                } else {
                    Spacer()
                        .frame(height: 14)
                }
            }
        }
        .frame(height: 260) // Reduced height for better fit
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [
                            AppColors.primaryOrange.opacity(0.15),
                            AppColors.primaryOrange.opacity(0.05)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Recipe: \(recipe.title)")
        .accessibilityHint("Tap to view recipe details")
    }
}

extension ModernRecipeCardView {
    // Compact recipe image section
    private var compactRecipeImageSection: some View {
        ZStack {
            // Compact background gradient
            LinearGradient(
                colors: [
                    AppColors.primaryOrange.opacity(0.12),
                    AppColors.primaryOrange.opacity(0.06),
                    AppColors.primaryOrange.opacity(0.02)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 90)
            
            // Recipe emoji with compact styling
            VStack(spacing: 4) {
                Text(getRecipeEmoji())
                    .font(.system(size: 40))
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                
                // Compact recipe type indicator
                Text(getRecipeType())
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color(.systemBackground).opacity(0.9))
                    )
            }
        }
        .clipShape(
            RoundedCorner(radius: 20, corners: [.topLeft, .topRight])
        )
    }
    
    // Compact metadata section
    private var compactMetadataSection: some View {
        VStack(spacing: 6) {
            // Top row: Cook time and rating
            HStack(spacing: 6) {
                // Compact cook time badge
                compactCookTimeBadge
                
                // Compact rating badge
                if recipe.rating > 0 {
                    compactRatingBadge
                }
                
                Spacer(minLength: 0)
                
                // Compact difficulty indicator
                compactDifficultyIndicator
            }
            
            // Bottom row: Additional info (only if space allows)
            if recipe.servings != nil || recipe.calories != nil {
                HStack(spacing: 6) {
                    // Servings info
                    if let servings = recipe.servings {
                        compactInfoBadge(
                            icon: "person.2.fill",
                            text: "\(servings)",
                            color: .blue
                        )
                    }
                    
                    // Calories info
                    if let calories = recipe.calories {
                        compactInfoBadge(
                            icon: "flame.fill",
                            text: "\(calories)",
                            color: .orange
                        )
                    }
                    
                    Spacer(minLength: 0)
                }
            }
        }
    }
    
    // Compact cook time badge
    private var compactCookTimeBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "clock.fill")
                .font(.system(size: 9))
                .foregroundColor(AppColors.primaryOrange)
            
            Text("\(recipe.cookTime ?? "30")")
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.primaryOrange)
                .lineLimit(1)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.primaryOrange.opacity(0.1))
        )
    }
    
    // Compact rating badge
    private var compactRatingBadge: some View {
        HStack(spacing: 3) {
            Image(systemName: "star.fill")
                .font(.system(size: 9))
                .foregroundColor(AppColors.successGreen)
            
            Text(String(format: "%.1f", recipe.rating))
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.successGreen)
                .lineLimit(1)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.successGreen.opacity(0.1))
        )
    }
    
    // Compact difficulty indicator
    private var compactDifficultyIndicator: some View {
        HStack(spacing: 1) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index < getDifficultyLevel() ? AppColors.warnRed : AppColors.warnRed.opacity(0.2))
                    .frame(width: 5, height: 5)
            }
        }
    }
    
    // Compact tags section
    private var compactTagsSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 4) {
                ForEach(recipe.tags.prefix(2), id: \.self) { tag in
                    Text(tag.capitalized)
                        .font(.system(size: 9, weight: .medium, design: .rounded))
                        .foregroundColor(tagColor(for: tag))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(tagBackgroundColor(for: tag))
                        )
                        .lineLimit(1)
                }
            }
        }
    }
    
    // Compact info badge component
    private func compactInfoBadge(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 8))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 9, weight: .medium, design: .rounded))
                .foregroundColor(color)
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(color.opacity(0.1))
        )
    }
    
    // Helper functions
    private func getRecipeEmoji() -> String {
        // Return emoji based on recipe tags or title
        let title = recipe.title.lowercased()
        let tags = recipe.tags.map { $0.lowercased() }
        
        if tags.contains("breakfast") || title.contains("breakfast") {
            return "🌅"
        } else if tags.contains("lunch") || title.contains("lunch") {
            return "🍽️"
        } else if tags.contains("dinner") || title.contains("dinner") {
            return "🌙"
        } else if tags.contains("dessert") || title.contains("dessert") {
            return "🍰"
        } else if tags.contains("snack") || title.contains("snack") {
            return "🥨"
        } else if tags.contains("soup") || title.contains("soup") {
            return "🥣"
        } else if tags.contains("salad") || title.contains("salad") {
            return "🥗"
        } else if tags.contains("pasta") || title.contains("pasta") {
            return "🍝"
        } else if tags.contains("pizza") || title.contains("pizza") {
            return "🍕"
        } else if tags.contains("burger") || title.contains("burger") {
            return "🍔"
        } else if tags.contains("fish") || title.contains("salmon") || title.contains("tuna") {
            return "🐟"
        } else if tags.contains("chicken") || title.contains("chicken") {
            return "🍗"
        } else if tags.contains("beef") || title.contains("steak") {
            return "🥩"
        } else {
            return "🍳"
        }
    }
    
    private func getRecipeType() -> String {
        let title = recipe.title.lowercased()
        let tags = recipe.tags.map { $0.lowercased() }
        
        if tags.contains("breakfast") || title.contains("breakfast") {
            return "Breakfast"
        } else if tags.contains("lunch") || title.contains("lunch") {
            return "Lunch"
        } else if tags.contains("dinner") || title.contains("dinner") {
            return "Dinner"
        } else if tags.contains("dessert") || title.contains("dessert") {
            return "Dessert"
        } else if tags.contains("snack") || title.contains("snack") {
            return "Snack"
        } else if tags.contains("appetizer") || title.contains("appetizer") {
            return "Appetizer"
        } else {
            return "Main Course"
        }
    }
    
    private func getDifficultyText() -> String {
        switch recipe.difficulty?.lowercased() {
        case "easy": return "Easy"
        case "medium": return "Medium"
        case "hard": return "Hard"
        default: return "Medium"
        }
    }
    
    private func getDifficultyLevel() -> Int {
        switch recipe.difficulty?.lowercased() {
        case "easy": return 1
        case "medium": return 2
        case "hard": return 3
        default: return 2
        }
    }
    
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
        case "vegetarian":
            return AppColors.successGreen
        case "vegan":
            return AppColors.successGreen
        case "gluten-free":
            return .orange
        case "dairy-free":
            return .blue
        default:
            return AppColors.textSecondary
        }
    }
    
    private func tagBackgroundColor(for tag: String) -> Color {
        return tagColor(for: tag).opacity(0.1)
    }
}

// Custom shape for rounded corners
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview
struct ModernRecipeCardView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                ModernRecipeCardView(recipe: sampleRecipe1)
                ModernRecipeCardView(recipe: sampleRecipe2)
            }
            .padding()
        }
        .background(AppColors.background)
    }
    
    // Sample recipes for preview
    static let sampleRecipe1 = Recipe(
        id: "preview-1",
        title: "Spaghetti Carbonara",
        cookTime: "25 min",
        prepTime: 10,
        servings: 4,
        calories: 450,
        imageUrl: nil,
        ingredients: ["Spaghetti", "Eggs", "Pancetta", "Parmesan", "Black Pepper"],
        steps: ["Boil pasta", "Cook pancetta", "Mix with eggs"],
        substitutions: ["Bacon for pancetta"],
        tags: ["italian", "quick", "dinner", "pasta"],
        difficulty: "medium",
        cuisineType: "italian",
        costEstimate: 12.50,
        createdAt: Date(),
        updatedAt: Date(),
        createdBy: nil,
        spoonacularId: "12345",
        isPublic: true,
        rating: 4.5,
        ratingCount: 128
    )
    
    static let sampleRecipe2 = Recipe(
        id: "preview-2",
        title: "Avocado Toast",
        cookTime: "5 min",
        prepTime: 5,
        servings: 1,
        calories: 280,
        imageUrl: nil,
        ingredients: ["Bread", "Avocado", "Salt", "Pepper", "Red Pepper Flakes"],
        steps: ["Toast bread", "Mash avocado", "Spread and season"],
        substitutions: nil,
        tags: ["breakfast", "quick", "healthy", "vegetarian"],
        difficulty: "easy",
        cuisineType: "american",
        costEstimate: 3.50,
        createdAt: Date(),
        updatedAt: Date(),
        createdBy: nil,
        spoonacularId: "67890",
        isPublic: true,
        rating: 4.2,
        ratingCount: 89
    )
} 
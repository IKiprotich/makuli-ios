//
//  RecipesView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct RecipesView: View {
    
    @State private var selectedFilter = "All"
    private let filterOptions = ["All", "Quick", "High-Protein", "Budget"]
    private let recipes = Recipe.enhancedMockRecipes()
    
    // Computed property to filter recipes based on selected filter
    private var filteredRecipes: [Recipe] {
          switch selectedFilter {
          case "Quick":
              return recipes.filter { $0.cookTimeInMinutes <= 25 }
          case "High-Protein":
              return recipes.filter { $0.tags.contains("High-Protein") }
          case "Budget":
              return recipes.filter { $0.tags.contains("Budget") }
          default:
              return recipes
          }
      }
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    
                    //filter chips
                    filterChipsView
                    
                    //recipe grid view
                    recipesGridView
                    
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
            .background(AppColors.warmsand.opacity(0.3)
                .ignoresSafeArea())
        }
    }
}


extension RecipesView {
    
    //MARK: Filter Chips View
    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false){
            HStack(spacing: 12){
                ForEach(filterOptions, id: \.self){ filter in
                    FilterChip(
                        title: filter,
                        isSelected: selectedFilter == filter,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)){
                                selectedFilter = filter
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
            
        }
    }
    
    
    //MARK: Filter Chip Component
    struct FilterChip: View {
        
        let title: String
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : Color(.label))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(isSelected ? AppColors.primaryOrange : Color(.secondarySystemFill))
                    )
            }
            .accessibilityLabel("Filter by \(title)")
            .accessibilityHint(isSelected ? "Currently selected" : "Tap to filter recipes")
        }
    }
    
    
    //MARK: Recipes Grid View
    private var recipesGridView: some View {
        
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(filteredRecipes) { recipe in
                NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                    RecipeCardView(recipe: recipe)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
    
    
    
    
}

#Preview {
    RecipesView()
}

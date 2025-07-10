//
//  RecipesView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct RecipesView: View {
    @StateObject private var viewModel = RecipesViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Filter chips
                    filterChipsView
                    
                    // Recipe grid view
                    if viewModel.recipes.isEmpty {
                        Text("No recipes found. Please check back later!")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        recipesGridView
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)
            }
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
            .background(AppColors.warmsand.opacity(0.3).ignoresSafeArea())
            .task {
                await viewModel.fetchRecipes()
            }
        }
    }
}

extension RecipesView {
    // MARK: - UI Components
    private var filterChipsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.filterOptions, id: \.self) { filter in
                    FilterChip(
                        title: filter.displayName,
                        isSelected: viewModel.selectedFilter == filter,
                        action: {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.selectFilter(filter)
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    private var recipesGridView: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ]
        
        return LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.filteredRecipes) { recipe in
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

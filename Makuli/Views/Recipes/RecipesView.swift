//
//  RecipesView.swift
//  Makuli
//

import SwiftUI

struct RecipesView: View {
    @StateObject private var viewModel = RecipesViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(spacing: 0) {
                    filterChipsView
                        .padding(.top, 8)

                    if viewModel.recipes.isEmpty && !viewModel.isLoading {
                        emptyStateView
                    } else {
                        recipesGridView
                    }

                    Spacer(minLength: 100)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Recipes")
            .navigationBarTitleDisplayMode(.large)
            .task { await viewModel.fetchRecipes() }
        }
    }
}

// MARK: - Sections

extension RecipesView {

    private var filterChipsView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(AppFonts.headline())
                .foregroundColor(AppColors.text)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.filterOptions, id: \.self) { filter in
                        FilterChip(
                            title: filter.displayName,
                            isSelected: viewModel.selectedFilter == filter,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.selectFilter(filter)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer().frame(height: 60)

            Image(systemName: "magnifyingglass")
                .font(.system(size: 52, weight: .light))
                .foregroundColor(AppColors.primaryOrange.opacity(0.5))

            VStack(spacing: 8) {
                Text("No Recipes Found")
                    .font(AppFonts.title2())
                    .foregroundColor(AppColors.text)

                Text("Try adjusting your filters or check back later for new recipes.")
                    .font(AppFonts.body())
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer().frame(height: 60)
        }
    }

    private var recipesGridView: some View {
        VStack(alignment: .leading, spacing: 16) {
            let count = viewModel.filteredRecipes.count
            Text("\(count) Recipe\(count == 1 ? "" : "s")")
                .font(AppFonts.headline())
                .foregroundColor(AppColors.text)
                .padding(.horizontal, 20)

            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        RecipeCardView(recipe: recipe)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    RecipesView()
}

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
            ZStack {
                // Modern gradient background
                LinearGradient(
                    colors: [
                        AppColors.background,
                        AppColors.primaryOrange.opacity(0.05)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Hero section with emoji
                        heroSection
                        
                        // Filter chips with modern design
                        modernFilterChipsView
                        
                        // Recipe content
                        if viewModel.recipes.isEmpty {
                            modernEmptyStateView
                        } else {
                            modernRecipesGridView
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Text("🍳")
                            .font(.system(size: 24))
                        
                        Text("Recipes")
                            .font(.system(size: 24, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.text)
                    }
                }
            }
            .task {
                await viewModel.fetchRecipes()
            }
        }
    }
}

extension RecipesView {
    // MARK: - Modern UI Components
    
    // Hero section with emoji and stats
    private var heroSection: some View {
        VStack(spacing: 16) {
            // Large emoji hero
            Text("👨‍🍳")
                .font(.system(size: 64))
                .padding(.top, 20)
            
            // Stats section
            HStack(spacing: 24) {
                statCard(
                    emoji: "📚",
                    value: "\(viewModel.recipes.count)",
                    label: "Total Recipes"
                )
                
                statCard(
                    emoji: "⭐",
                    value: "\(viewModel.filteredRecipes.count)",
                    label: "Available"
                )
            }
            .padding(.horizontal, 24)
        }
        .padding(.bottom, 24)
    }
    
    // Modern stat card
    private func statCard(emoji: String, value: String, label: String) -> some View {
        VStack(spacing: 8) {
            Text(emoji)
                .font(.system(size: 24))
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.text)
            
            Text(label)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    // Modern filter chips view
    private var modernFilterChipsView: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Filter by Category")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.text)
                
                Spacer()
                
                Text("🎯")
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 24)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.filterOptions, id: \.self) { filter in
                        ModernFilterChip(
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
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 24)
    }
    
    // Modern empty state view
    private var modernEmptyStateView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Large emoji
            Text("🔍")
                .font(.system(size: 80))
            
            VStack(spacing: 12) {
                Text("No Recipes Found")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                
                Text("Try adjusting your filters or check back later for new recipes!")
                    .font(.system(size: 16, weight: .regular, design: .default))
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .padding(.vertical, 40)
    }
    
    // Modern recipes grid view
    private var modernRecipesGridView: some View {
        VStack(spacing: 16) {
            // Results header
            HStack {
                Text("\(viewModel.filteredRecipes.count) Recipes")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(AppColors.text)
                
                Spacer()
                
                Text("🍽️")
                    .font(.system(size: 16))
            }
            .padding(.horizontal, 20)
            
            // Optimized grid layout
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
            
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filteredRecipes) { recipe in
                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                        ModernRecipeCardView(recipe: recipe)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    RecipesView()
}

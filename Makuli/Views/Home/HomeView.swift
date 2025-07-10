//
//  HomeView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready home view with real data from database.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = HomeViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var planViewModel = PlanViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.bgCream
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        HeaderView(
                            onProfileTap: { viewModel.handleProfileTap(selectedTab: $selectedTab) },
                            onSettingsTap: { viewModel.handleSettingsTap(selectedTab: $selectedTab) }
                        )
                        
                        greetingView
                        
                        if viewModel.hasActivePlan {
                            currentMealPlanSection
                        } else {
                            emptyPlanSection
                        }
                        
                        QuickAccessSection(
                            onGroceryListTap: viewModel.handleGroceryListTap,
                            onExploreRecipeTap: { viewModel.handleExploreRecipesTap(selectedTab: $selectedTab) }
                        )
                        
                        ProgressTrackerSection(metrics: generateProgressMetrics())
                        
                        if !viewModel.quickRecipes.isEmpty {
                            quickRecipesSection
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
                .background(AppColors.warmsand.opacity(0.3).ignoresSafeArea())
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $viewModel.navigateToWeekDetail) {
                if let currentPlan = viewModel.currentPlan {
                    // TODO: Update WeekDetailView to accept PlanWithRecipes directly
                    // For now, show a placeholder or update the WeekDetailView
                    Text("Week Detail - Plan: \(currentPlan.plan.title)")
                } else {
                    EmptyPlanView()
                }
            }
            .sheet(isPresented: $viewModel.showingPlanCreation) {
                PlanCreationView()
            }
            .sheet(isPresented: $viewModel.showingAIGeneration) {
                AIGenerationView()
            }
            .sheet(isPresented: $viewModel.showingGroceryList) {
                GroceryListView()
            }
            .task {
                if let user = authViewModel.user {
                    await viewModel.loadDashboardData(for: user.id)
                }
            }
            .refreshable {
                if let user = authViewModel.user {
                    await viewModel.refreshDashboard(for: user.id)
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}

extension HomeView {
    // MARK: - UI Components
    
    private var greetingView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(viewModel.timeBasedGreeting)!")
                    .font(.title2)
                    .foregroundColor(.primary)
                
                if let profile = profileViewModel.profile {
                    Text("Welcome back, \(profile.name ?? "there") 👋")
                        .font(.headline)
                        .foregroundColor(.secondary)
                } else {
                    Text("Ready to plan some amazing meals? 🍽️")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                
                if !viewModel.todaysMeals.isEmpty {
                    Text("\(viewModel.getMotivationalMessage())")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryOrange)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Progress badge
            if viewModel.hasActivePlan {
                VStack(spacing: 2) {
                    Text(viewModel.getCompletionBadge())
                        .font(.title)
                    
                    Text("\(Int(viewModel.todaysCompletionStatus.percentage))%")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                }
                .padding(8)
                .background(AppColors.bgCream)
                .cornerRadius(8)
            }
        }
    }
    
    private var currentMealPlanSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Today's Meals")
                    .font(AppFonts.title2())
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: viewModel.handleCurrentPlanTap) {
                    Text("View Plan")
                        .font(.caption)
                        .foregroundColor(AppColors.primaryOrange)
                }
            }
            
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Loading meals...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if viewModel.todaysMeals.isEmpty {
                VStack(spacing: 8) {
                    Text("No meals planned for today")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("Enjoy your free day or check tomorrow's plan!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.bgCream)
                .cornerRadius(12)
            } else {
                ForEach(viewModel.todaysMeals, id: \.id) { meal in
                    TodaysMealCard(
                        meal: meal,
                        onToggleCompletion: {
                            Task {
                                await viewModel.toggleMealCompletion(meal)
                            }
                        }
                    )
                }
                
                // Show upcoming meals preview
                if !viewModel.upcomingMeals.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Coming Up")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(viewModel.upcomingMeals.prefix(3)), id: \.id) { meal in
                                    UpcomingMealCard(meal: meal)
                                }
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
    
    private var emptyPlanSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 12) {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 40))
                    .foregroundColor(AppColors.primaryOrange)
                
                Text("Ready to start meal planning?")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("Create your first meal plan and discover amazing recipes!")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(AppColors.bgCream)
            .cornerRadius(12)
            
            HStack(spacing: 12) {
                Button(action: viewModel.handlePlanCreationTap) {
                    Label("Create Plan", systemImage: "plus.circle.fill")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.primaryOrange)
                        .cornerRadius(12)
                }
                
                Button(action: viewModel.handleAIGenerationTap) {
                    Label("AI Generate", systemImage: "wand.and.stars")
                        .foregroundColor(AppColors.primaryOrange)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(AppColors.primaryOrange.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var quickRecipesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Quick Recipes")
                    .font(AppFonts.title2())
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("See All") {
                    viewModel.handleExploreRecipesTap(selectedTab: $selectedTab)
                }
                .font(.caption)
                .foregroundColor(AppColors.primaryOrange)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(viewModel.quickRecipes, id: \.id) { recipe in
                        QuickRecipeCard(recipe: recipe)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func generateProgressMetrics() -> [ProgressMetrics] {
        if !viewModel.hasActivePlan {
            return [
                ProgressMetrics(title: "This Week", value: "0/0", change: "", isPositive: true),
                ProgressMetrics(title: "Get Started", value: "Create Plan", change: "", isPositive: true),
                ProgressMetrics(title: "Recipes", value: "\(viewModel.quickRecipes.count)", change: "", isPositive: true),
                ProgressMetrics(title: "Groceries", value: "\(viewModel.groceryStats.totalItems)", change: "", isPositive: true),
            ]
        }
        
        let (completed, total, percentage) = viewModel.weekProgress
        let todaysProgress = viewModel.todaysCompletionStatus
        
        return [
            ProgressMetrics(
                title: "This Week",
                value: "\(completed)/\(total)",
                change: "+\(completed)",
                isPositive: true
            ),
            ProgressMetrics(
                title: "Today",
                value: "\(todaysProgress.completed)/\(todaysProgress.total)",
                change: "\(Int(todaysProgress.percentage))%",
                isPositive: todaysProgress.percentage >= 50
            ),
            ProgressMetrics(
                title: "Progress",
                value: "\(Int(percentage))%",
                change: percentage >= 70 ? "Great!" : "Keep going",
                isPositive: percentage >= 50
            ),
            ProgressMetrics(
                title: "Groceries",
                value: "\(viewModel.groceryStats.checkedItems)/\(viewModel.groceryStats.totalItems)",
                change: viewModel.groceryStats.totalItems > 0 ? "Ready" : "Generate",
                isPositive: viewModel.groceryStats.totalItems > 0
            ),
        ]
    }
}

// MARK: - Supporting Views

struct TodaysMealCard: View {
    let meal: PlanRecipe
    let onToggleCompletion: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Meal completion toggle
            Button(action: onToggleCompletion) {
                Image(systemName: meal.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(meal.isCompleted ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(meal.customMealName ?? "Meal")
                        .font(.headline)
                        .foregroundColor(.primary)
                        .strikethrough(meal.isCompleted)
                    
                    Spacer()
                    
                    Text(meal.mealType.capitalized)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(AppColors.primaryOrange.opacity(0.2))
                        .cornerRadius(4)
                }
                
                if let cookTime = meal.customCookTime {
                    Text("⏱️ \(cookTime)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(AppColors.bgCream)
        .cornerRadius(12)
        .opacity(meal.isCompleted ? 0.7 : 1.0)
    }
}

struct UpcomingMealCard: View {
    let meal: PlanRecipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(meal.customMealName ?? "Meal")
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
            
            Text(meal.mealType.capitalized)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(width: 100)
        .padding(8)
        .background(AppColors.bgCream.opacity(0.5))
        .cornerRadius(8)
    }
}

struct QuickRecipeCard: View {
    let recipe: Recipe
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            AsyncImage(url: URL(string: recipe.imageUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.primaryOrange.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
            .frame(width: 120, height: 80)
            .clipped()
            .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(recipe.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                
                if let cookTime = recipe.cookTime {
                    Text("⏱️ \(cookTime)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 120)
    }
}

struct EmptyPlanView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Active Plan")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("It looks like you don't have an active meal plan. Go back to create one!")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environmentObject(AuthViewModel())
}

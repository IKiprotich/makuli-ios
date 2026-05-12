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
    @StateObject private var profileViewModel = UserProfileViewModel()
    @StateObject private var planViewModel = PlanViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Enhanced background with subtle gradient
                        AppColors.background.ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 28) {
                        HeaderView(
                            onProfileTap: { viewModel.handleProfileTap(selectedTab: $selectedTab) },
                            onSettingsTap: { viewModel.handleSettingsTap(selectedTab: $selectedTab) },
                            profileImageUrl: profileViewModel.profile?.profileImageUrl
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
                    .padding(.horizontal, 20)
                }
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
            .sheet(isPresented: $viewModel.showingSpoonacularGeneration) {
                MealPlanGenerationView()
            }
            .sheet(isPresented: $viewModel.showingGroceryList) {
                GroceryListView()
            }
            .task {
                if let user = authViewModel.user {
                    await viewModel.loadDashboardData(for: user.id)
                    await profileViewModel.fetchProfile()
                    profileViewModel.startListeningForUpdates()
                }
            }
            .refreshable {
                if let user = authViewModel.user {
                    await viewModel.refreshDashboard(for: user.id)
                    await profileViewModel.forceRefreshProfile()
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
        .onDisappear {
            profileViewModel.stopListeningForUpdates()
        }
    }
}

extension HomeView {
    // MARK: - UI Components
    
    private var greetingView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(viewModel.timeBasedGreeting)!")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.text)
                    
                    if let profile = profileViewModel.profile {
                        Text("Welcome back, \(profile.name ?? "there")")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    } else {
                        Text("Ready to plan some amazing meals?")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    if !viewModel.todaysMeals.isEmpty {
                        Text("\(viewModel.getMotivationalMessage())")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.primaryOrange)
                            .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                // Enhanced progress badge
                if viewModel.hasActivePlan {
                    VStack(spacing: 4) {
                        ZStack {
                            Circle()
                                .stroke(AppColors.primaryOrange.opacity(0.2), lineWidth: 4)
                                .frame(width: 60, height: 60)
                            
                            Circle()
                                .trim(from: 0, to: viewModel.todaysCompletionStatus.percentage / 100)
                                .stroke(AppColors.primaryOrange, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 60, height: 60)
                                .rotationEffect(.degrees(-90))
                                .animation(.easeInOut(duration: 1.0), value: viewModel.todaysCompletionStatus.percentage)
                            
                            VStack(spacing: 0) {
                                Text(viewModel.getCompletionBadge())
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundColor(AppColors.primaryOrange)
                                
                                Text("\(Int(viewModel.todaysCompletionStatus.percentage))%")
                                    .font(.system(size: 10, weight: .medium))
                                    .foregroundColor(AppColors.textSecondary)
                            }
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.card)
                            .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                    )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(AppColors.card)
                .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
        )
    }
    
    private var currentMealPlanSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today's Meals")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.text)
                    
                    Text("Track your daily nutrition")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Button(action: viewModel.handleCurrentPlanTap) {
                    HStack(spacing: 6) {
                        Text("View Plan")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(AppColors.primaryOrange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(AppColors.primaryOrange.opacity(0.1))
                    )
                }
            }
            
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                        .tint(AppColors.primaryOrange)
                    Text("Loading meals...")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.card)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
            } else if viewModel.todaysMeals.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 48))
                        .foregroundColor(AppColors.primaryOrange.opacity(0.6))
                    
                    VStack(spacing: 8) {
                        Text("No meals planned for today")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(AppColors.text)
                        
                        Text("Enjoy your free day or check tomorrow's plan!")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(AppColors.card)
                        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
                )
            } else {
                VStack(spacing: 12) {
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
                }
                
                // Show upcoming meals preview
                if !viewModel.upcomingMeals.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Coming Up")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.text)
                            
                            Spacer()
                            
                            Text("Next 3 meals")
                                .font(.system(size: 12, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.textSecondary)
                        }
                        
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
        VStack(spacing: 20) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryOrange.opacity(0.1))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "calendar.badge.plus")
                        .font(.system(size: 36))
                        .foregroundColor(AppColors.primaryOrange)
                }
                
                VStack(spacing: 8) {
                    Text("Ready to start meal planning?")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.text)
                    
                    Text("Create your first meal plan and discover amazing recipes!")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppColors.card)
                    .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
            )
            
            HStack(spacing: 12) {
                Button(action: viewModel.handlePlanCreationTap) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 16, weight: .semibold))
                        Text("Create Plan")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(.white)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.primaryOrange)
                            .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 8, x: 0, y: 4)
                    )
                }
                
                Button(action: viewModel.handleSpoonacularGenerationTap) {
                    HStack(spacing: 8) {
                        Image(systemName: "wand.and.stars")
                            .font(.system(size: 16, weight: .semibold))
                        Text("AI Generate")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                    .foregroundColor(AppColors.primaryOrange)
                    .padding(.vertical, 16)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(AppColors.primaryOrange.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(AppColors.primaryOrange.opacity(0.3), lineWidth: 1)
                            )
                    )
                }
            }
        }
    }
    
    private var quickRecipesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quick Recipes")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.text)
                    
                    Text("Discover new favorites")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Button("See All") {
                    viewModel.handleExploreRecipesTap(selectedTab: $selectedTab)
                }
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.primaryOrange)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(AppColors.primaryOrange.opacity(0.1))
                )
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
    
    private func generateProgressMetrics() -> [ProgressMetric] {
        if !viewModel.hasActivePlan {
            return [
                ProgressMetric(title: "This Week", value: "0/0", change: "", isPositive: true),
                ProgressMetric(title: "Get Started", value: "Create Plan", change: "", isPositive: true),
                ProgressMetric(title: "Recipes", value: "\(viewModel.quickRecipes.count)", change: "", isPositive: true),
                ProgressMetric(title: "Groceries", value: "\(viewModel.groceryStats.totalItems)", change: "", isPositive: true),
            ]
        }
        
        let (completed, total, percentage) = viewModel.weekProgress
        let todaysProgress = viewModel.todaysCompletionStatus
        
        return [
            ProgressMetric(
                title: "This Week",
                value: "\(completed)/\(total)",
                change: "+\(completed)",
                isPositive: true
            ),
            ProgressMetric(
                title: "Today",
                value: "\(todaysProgress.completed)/\(todaysProgress.total)",
                change: "\(Int(todaysProgress.percentage))%",
                isPositive: todaysProgress.percentage >= 50
            ),
            ProgressMetric(
                title: "Progress",
                value: "\(Int(percentage))%",
                change: percentage >= 70 ? "Great!" : "Keep going",
                isPositive: percentage >= 50
            ),
            ProgressMetric(
                title: "Groceries",
                value: "\(viewModel.groceryStats.checkedItems)/\(viewModel.groceryStats.totalItems)",
                change: viewModel.groceryStats.totalItems > 0 ? "Ready" : "Generate",
                isPositive: viewModel.groceryStats.totalItems > 0
            ),
        ]
    }
}

// MARK: - Supporting Types

/// Lightweight display model for the progress tracker dashboard cards.
struct ProgressMetric {
    let title: String
    let value: String
    let change: String
    let isPositive: Bool
}

// MARK: - Empty Plan Destination

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

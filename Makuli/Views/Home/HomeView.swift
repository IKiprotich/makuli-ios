//
//  HomeView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @StateObject private var viewModel = HomeViewModel()
    
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
                        
                        TodaysMealPlanSection(meals: viewModel.sampleMeals)
                        
                        QuickAccessSection(
                            onGroceryListTap: viewModel.handleGroceryListTap,
                            onExploreRecipeTap: { viewModel.handleExploreRecipesTap(selectedTab: $selectedTab) }
                        )
                        
                        ProgressTrackerSection(metrics: viewModel.sampleMetrics)
                        
                        featuredMealView
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                }
                .background(AppColors.warmsand.opacity(0.3).ignoresSafeArea())
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $viewModel.navigateToWeekDetail) {
                WeekDetailView(weekPlan: WeekPlan.sampleWeekPlan)
            }
        }
    }
}

extension HomeView {
    // MARK: - UI Components
    private var greetingView: some View {
        HStack {
            Text("Good Morning, Ian 👋")
                .font(.title)
                .foregroundColor(.primary)
            Spacer()
        }
    }
    
    private var featuredMealView: some View {
        VStack {
            Image(systemName: "photo")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [.primary.opacity(0.3), .brown.opacity(0.3)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}

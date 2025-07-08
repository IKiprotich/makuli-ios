//
//  PlansView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct PlansView: View {
    @StateObject var viewModel = PlanViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showingMealPlanGeneration = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with add button
                    headerSection
                    
                    if viewModel.plans.isEmpty {
                        Text("No plans yet. Start by creating one!")
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        // Week carousel section
                        weekCarouselSection
                        
                        // Current active plan section
                        if let activePlan = viewModel.activePlan {
                            currentPlansSection(activePlan)
                        }
                    }
                    
                    // Previous plans section
                    previousPlansSection
                }
                .padding(.top, 8)
            }
            .navigationBarHidden(true)
            .background(AppColors.warmsand.opacity(0.3).ignoresSafeArea())
            .task {
                if let user = authViewModel.user, !user.email.isEmpty {
                    await viewModel.fetchPlans(for: user.id)
                }
            }
            .sheet(isPresented: $showingMealPlanGeneration) {
                MealPlanGenerationView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

extension PlansView {
    // MARK: - UI Components
    private var headerSection: some View {
        HStack {
            Text("My Meal Plans")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textCharcoal)
            
            Spacer()
            
            Button {
                showingMealPlanGeneration = true
            } label: {
                HStack {
                    Image(systemName: "sparkles")
                    Text("AI Plan")
                }
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppColors.primaryOrange)
                .cornerRadius(20)
            }
            .accessibilityLabel("Generate AI meal plan")
        }
        .padding(.horizontal, 20)
    }
    
    private var weekCarouselSection: some View {
        WeekCarouselView(weeks: viewModel.weekPlans, selectedWeek: $viewModel.selectedWeek)
    }
    
    private func currentPlansSection(_ plan: WeekPlan) -> some View {
        CurrentPlanCard(plan: plan)
            .padding(.horizontal, 20)
    }
    
    private var previousPlansSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Previous Plans")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textCharcoal)
                .padding(.horizontal, 20)
            
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(viewModel.pastPlans) { plan in
                    NavigationLink(destination: WeekDetailView(plan: plan)) {
                        PreviousPlanRow(plan: plan)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

#Preview {
    PlansView()
}

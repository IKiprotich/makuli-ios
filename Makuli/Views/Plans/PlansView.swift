//
//  PlansView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct PlansView: View {
    @StateObject private var viewModel = PlansViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with add button
                    headerSection
                    
                    // Week carousel section
                    weekCarouselSection
                    
                    // Current active plan section
                    if let activePlan = viewModel.activePlan {
                        currentPlansSection(activePlan)
                    }
                    
                    // Previous plans section
                    previousPlansSection
                }
                .padding(.top, 8)
            }
            .navigationBarHidden(true)
            .background(AppColors.warmsand.opacity(0.3).ignoresSafeArea())
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
                viewModel.addNewPlan()
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(AppColors.primaryOrange)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    )
            }
            .accessibilityLabel("Add a new meal plan")
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
                    NavigationLink(destination: WeekDetailView(weekPlan: plan)) {
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

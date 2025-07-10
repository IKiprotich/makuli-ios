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
    @State private var showingTemplateSelection = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with add button
                    headerSection
                    
                    if viewModel.plans.isEmpty {
                        emptyPlansSection
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
            .sheet(isPresented: $showingTemplateSelection) {
                TemplateSelectionView()
                    .environmentObject(authViewModel)
            }
        }
    }
}

extension PlansView {
    // MARK: - UI Components
    private var headerSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("My Meal Plans")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textCharcoal)
                
                Spacer()
            }
            
            // Plan creation options
            HStack(spacing: 12) {
                Spacer()
                
                // Template selection button
                Button {
                    showingTemplateSelection = true
                } label: {
                    HStack {
                        Image(systemName: "doc.text")
                        Text("Templates")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(AppColors.primaryOrange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppColors.primaryOrange.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(AppColors.primaryOrange, lineWidth: 1)
                    )
                    .cornerRadius(20)
                }
                .accessibilityLabel("Choose meal plan template")
                
                // AI generation button
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
        }
        .padding(.horizontal, 20)
    }
    
    private var weekCarouselSection: some View {
        WeekCarouselView(weeks: viewModel.plans, selectedWeek: $viewModel.selectedPlan)
    }
    
    private func currentPlansSection(_ plan: PlanWithRecipes) -> some View {
        CurrentPlanCard(plan: plan.plan)
            .padding(.horizontal, 20)
    }
    
    private var emptyPlansSection: some View {
        VStack(spacing: 24) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.6))
            
            VStack(spacing: 8) {
                Text("No Meal Plans Yet")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Create your first meal plan to get started with organized meal preparation")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Quick Seed Button for empty database
            if viewModel.plans.isEmpty {
                Button {
                    Task {
                        await seedDatabaseIfNeeded()
                    }
                } label: {
                    HStack {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Quick Setup Database")
                    }
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(AppColors.primaryOrange)
                    .cornerRadius(25)
                }
                .padding(.top, 8)
            }
            
            VStack(spacing: 16) {
                Button {
                    showingTemplateSelection = true
                } label: {
                    HStack {
                        Image(systemName: "doc.text.fill")
                        Text("Browse Templates")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primaryOrange)
                    .cornerRadius(12)
                }
                
                Button {
                    showingMealPlanGeneration = true
                } label: {
                    HStack {
                        Image(systemName: "wand.and.stars")
                        Text("Generate with AI")
                    }
                    .font(.headline)
                    .foregroundColor(AppColors.primaryOrange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(AppColors.primaryOrange.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 32)
        }
        .padding(.vertical, 32)
    }
    
    // Helper method to seed database
    private func seedDatabaseIfNeeded() async {
        do {
            Logger.info("Starting quick database setup")
            let seeder = DatabaseSeeder.shared
            let success = await seeder.seedDatabase()
            if success {
                Logger.info("Database seeded successfully")
                // Refresh templates and plans
                await viewModel.fetchTemplates()
                if let user = authViewModel.user {
                    await viewModel.fetchPlans(for: user.id)
                }
            }
        } catch {
            Logger.error("Failed to seed database: \(error)")
        }
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

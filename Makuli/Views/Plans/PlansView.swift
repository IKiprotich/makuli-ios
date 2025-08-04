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
    @State private var showingDateSelection = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                AppColors.background.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        if viewModel.plans.isEmpty {
                            // Empty state - first time user
                            emptyStateView
                        } else {
                            // User has existing plans
                            existingPlansView
                        }
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
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
            .sheet(isPresented: $showingDateSelection) {
                MealPlanDateSelectionView()
                    .environmentObject(authViewModel)
            }
            .onChange(of: showingDateSelection) { isPresented in
                if !isPresented {
                    // Refresh plans when the sheet is dismissed
                    Task {
                        if let user = authViewModel.user, !user.email.isEmpty {
                            await viewModel.fetchPlans(for: user.id)
                        }
                    }
                }
            }
        }
    }
}

extension PlansView {
    // MARK: - Empty State View (First Time User)
    private var emptyStateView: some View {
                    VStack(spacing: 32) {
                // Header
                VStack(spacing: 8) {
                    Text("Meal Plan")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.text)
                    
                    Text("Get balanced meal schedule for your goals and tastes.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            
            // Central Illustration
            VStack(spacing: 16) {
                // Clipboard illustration
                ZStack {
                                    // Clipboard body
                RoundedRectangle(cornerRadius: 12)
                    .fill(AppColors.border)
                    .frame(width: 120, height: 160)
                    
                    // Clipboard clip
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.primaryOrange)
                        .frame(width: 40, height: 8)
                        .offset(y: -84)
                    
                    // Paper content
                    VStack(spacing: 8) {
                        Text("MEAL PLAN")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(AppColors.primaryOrange)
                        
                        VStack(spacing: 4) {
                                                            HStack(spacing: 6) {
                                    Image(systemName: "cup.and.saucer.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.primaryOrange)
                                    
                                    HStack(spacing: 2) {
                                        ForEach(0..<3, id: \.self) { _ in
                                            Rectangle()
                                                .fill(AppColors.primaryOrange)
                                                .frame(width: 8, height: 2)
                                        }
                                    }
                                }
                            
                                                            HStack(spacing: 6) {
                                    Image(systemName: "bowl.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.primaryOrange)
                                    
                                    HStack(spacing: 2) {
                                        ForEach(0..<4, id: \.self) { _ in
                                            Rectangle()
                                                .fill(AppColors.primaryOrange)
                                                .frame(width: 8, height: 2)
                                        }
                                    }
                                }
                            
                                                            HStack(spacing: 6) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 12))
                                        .foregroundColor(AppColors.primaryOrange)
                                    
                                    HStack(spacing: 2) {
                                        ForEach(0..<3, id: \.self) { _ in
                                            Rectangle()
                                                .fill(AppColors.primaryOrange)
                                                .frame(width: 8, height: 2)
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            
            // Feature list
            VStack(spacing: 16) {
                featureRow(
                    icon: "list.bullet",
                    text: "Meals for breakfast, lunch, and dinner"
                )
                
                featureRow(
                    icon: "star.fill",
                    text: "Tailored to your goals and preferences"
                )
                
                featureRow(
                    icon: "chart.pie.fill",
                    text: "Balanced proteins, fats, carbs and fiber"
                )
            }
            
            // Create meal plan button
            Button(action: {
                showingDateSelection = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Create meal plan")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.primaryOrange)
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
        }
        .padding(.vertical, 40)
    }
    
    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(AppColors.primaryOrange)
                .frame(width: 24, height: 24)
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.text)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Existing Plans View
    private var existingPlansView: some View {
        VStack(spacing: 0) {
            // Header
            headerSection
            
            // Enhance My Plan button
            enhancePlanButton
            
            // Meal plan content
            if let activePlan = viewModel.activePlan {
                mealPlanContent(activePlan)
            } else {
                // Show empty state if no active plan
                emptyActivePlanState
            }
        }
    }
    
    // MARK: - UI Components
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Meal Plan")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                
                if let activePlan = viewModel.activePlan {
                    Text(formatDateRange(for: activePlan.plan))
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            
            Spacer()
            
            // Menu button (three dots)
            Button(action: {
                // Show menu options
            }) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppColors.text)
                    .rotationEffect(.degrees(90))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 16)
    }
    
    private var enhancePlanButton: some View {
        Button(action: {
            // Handle enhance plan action
        }) {
            HStack(spacing: 8) {
                Text("Enhance My Plan")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                
                Image(systemName: "sparkles")
                    .font(.system(size: 16, weight: .medium))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        AppColors.primaryOrange,
                        AppColors.primaryOrange.opacity(0.8)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 24)
    }
    
    private func mealPlanContent(_ plan: PlanWithRecipes) -> some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(getDayMeals(for: plan), id: \.dayOfWeek) { dayMeals in
                    if !dayMeals.breakfast.isEmpty || !dayMeals.lunch.isEmpty || !dayMeals.dinner.isEmpty {
                        dayMealSection(dayMeals)
                    }
                }
            }
            .padding(.vertical, 16)
        }
    }
    
    private func dayMealSection(_ dayMeals: PlanDayMeals) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            // Day header
            Text(formatDayHeader(dayMeals.day, dayOfWeek: dayMeals.dayOfWeek))
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(AppColors.text)
                .padding(.horizontal, 20)
            
            // Meal entries
            VStack(spacing: 12) {
                ForEach(dayMeals.breakfast, id: \.id) { recipe in
                    mealEntry(recipe, mealType: "Breakfast")
                }
                
                ForEach(dayMeals.lunch, id: \.id) { recipe in
                    mealEntry(recipe, mealType: "Lunch")
                }
                
                ForEach(dayMeals.dinner, id: \.id) { recipe in
                    mealEntry(recipe, mealType: "Dinner")
                }
            }
        }
    }
    
    private func mealEntry(_ recipe: PlanRecipe, mealType: String) -> some View {
        HStack(spacing: 12) {
            // Recipe image
            AsyncImage(url: URL(string: "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.primaryOrange.opacity(0.2))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 20))
                            .foregroundColor(AppColors.primaryOrange.opacity(0.5))
                    )
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            
            VStack(alignment: .leading, spacing: 4) {
                // Meal type tag
                Text(mealType)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(getMealTypeTagColor(mealType))
                    .clipShape(Capsule())
                
                // Recipe title
                Text(recipe.customMealName ?? "Meal")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.text)
                    .lineLimit(2)
            }
            
            Spacer()
            
            // Options button
            Button(action: {
                // Show meal options
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(AppColors.primaryOrange.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    VStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { _ in
                            Circle()
                                .fill(AppColors.primaryOrange)
                                .frame(width: 3, height: 3)
                        }
                    }
                }
            }
        }
        .padding(.horizontal, 20)
    }
    
    private var emptyActivePlanState: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primaryOrange.opacity(0.5))
            
            Text("No Active Meal Plan")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.text)
            
            Text("Create your first meal plan to get started")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                showingDateSelection = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Create Meal Plan")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.primaryOrange)
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
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
    
    // MARK: - Helper Methods
    
    private func formatDateRange(for plan: Plan) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM, d"
        let start = formatter.string(from: plan.weekStart)
        let end = formatter.string(from: plan.weekEnd)
        return "\(start) - \(end)"
    }
    
    private func formatDayHeader(_ day: String, dayOfWeek: Int) -> String {
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date()) - 1 // Convert to 0-based
        
        if dayOfWeek == today {
            return "Today, \(day)"
        } else if dayOfWeek == today + 1 {
            return "Tomorrow, \(day)"
        } else {
            return day
        }
    }
    
    private func getDayMeals(for plan: PlanWithRecipes) -> [PlanDayMeals] {
        return viewModel.getDayMeals(for: plan)
    }
    
    private func getMealTypeTagColor(_ mealType: String) -> Color {
        switch mealType.lowercased() {
        case "breakfast":
            return AppColors.primaryOrange
        case "lunch":
            return AppColors.primaryOrange
        case "dinner":
            return AppColors.primaryOrange
        default:
            return AppColors.primaryOrange
        }
    }
}



#Preview {
    PlansView()
}

//
//  HomeViewModel.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready home view model for dashboard data and navigation.
//

import Foundation
import SwiftUI

@MainActor
class HomeViewModel: ObservableObject {
    @Published var navigateToWeekDetail = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var currentPlan: PlanWithRecipes?
    @Published var todaysMeals: [PlanRecipe] = []
    @Published var upcomingMeals: [PlanRecipe] = []
    @Published var weekProgress: (completed: Int, total: Int, percentage: Double) = (0, 0, 0.0)
    @Published var recentPlans: [PlanWithRecipes] = []
    @Published var quickRecipes: [Recipe] = []
    @Published var groceryStats: (totalItems: Int, checkedItems: Int) = (0, 0)
    
    @Published var showingPlanCreation = false
    @Published var showingGroceryList = false
    
    private let supabaseManager = SupabaseManager.shared
    
    // MARK: - Computed Properties
    
    var hasActivePlan: Bool {
        return currentPlan != nil
    }
    
    var todaysMealsByType: [String: [PlanRecipe]] {
        Dictionary(grouping: todaysMeals) { $0.mealType }
    }
    
    var nextMeal: PlanRecipe? {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        if currentHour < 10 {
            return todaysMealsByType["breakfast"]?.first
        } else if currentHour < 14 {
            return todaysMealsByType["lunch"]?.first ?? todaysMealsByType["dinner"]?.first
        } else if currentHour < 19 {
            return todaysMealsByType["dinner"]?.first
        } else {
            return upcomingMeals.first { $0.mealType == "breakfast" }
        }
    }
    
    var todaysCompletionStatus: (completed: Int, total: Int, percentage: Double) {
        let total = todaysMeals.count
        let completed = todaysMeals.filter { $0.isCompleted }.count
        let percentage = total > 0 ? Double(completed) / Double(total) * 100.0 : 0.0
        
        return (completed, total, percentage)
    }
    
    var timeBasedGreeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<22:
            return "Good evening"
        default:
            return "Good night"
        }
    }
    
    // MARK: - Data Loading

    func loadDashboardData(for userId: String) async {
        isLoading = true
        errorMessage = nil

        let seededKey = "makuli_db_seeded_v3"
        if !UserDefaults.standard.bool(forKey: seededKey) {
            await autoSeedIfNeeded(userId: userId)
            UserDefaults.standard.set(true, forKey: seededKey)
        }

        async let planTask = loadCurrentPlan(for: userId)
        async let mealsTask = loadTodaysMeals()
        async let recipesTask = loadQuickRecipes()
        async let groceryTask = loadGroceryStats(for: userId)
        async let recentPlansTask = loadRecentPlans(for: userId)

        await planTask
        await mealsTask
        await recipesTask
        await groceryTask
        await recentPlansTask

        isLoading = false
    }

    private func autoSeedIfNeeded(userId: String) async {
        do {
            Logger.info("Checking if database needs seeding…")
            let recipes = try await supabaseManager.fetchRecipes(limit: 1)
            if recipes.isEmpty {
                Logger.info("Database empty — running auto-seed")
                try await ProductionSeeder.seedProductionDatabase()
                try await ProductionSeeder.seedSamplePlansForCurrentUser()
                Logger.info("Auto-seed completed")
            } else {
                let plans = try await supabaseManager.fetchUserPlans(userId: userId)
                if plans.isEmpty {
                    Logger.info("No user plans found — seeding demo plans")
                    try await ProductionSeeder.seedSamplePlansForCurrentUser()
                    Logger.info("Demo plans seeded")
                }
            }
        } catch {
            Logger.error("Auto-seed failed (non-fatal): \(error)")
        }
    }
    
    private func loadCurrentPlan(for userId: String) async {
        do {
            Logger.info("Loading current plan for user: \(userId)")
            let plans = try await supabaseManager.fetchUserPlans(userId: userId)
            var planWithRecipes: [PlanWithRecipes] = []
            for plan in plans {
                let recipes = try await supabaseManager.fetchPlanRecipes(planId: plan.id)
                planWithRecipes.append(PlanWithRecipes(id: plan.id, plan: plan, recipes: recipes))
            }
            self.currentPlan = planWithRecipes.first { $0.isCurrentWeek }
            if let plan = currentPlan {
                let total = plan.recipes.count
                let completed = plan.recipes.filter { $0.isCompleted }.count
                let percentage = total > 0 ? Double(completed) / Double(total) * 100.0 : 0.0
                self.weekProgress = (completed, total, percentage)
                Logger.info("Loaded current plan with \(total) meals")
            }
        } catch is CancellationError {
            Logger.debug("Current plan fetch cancelled")
        } catch {
            Logger.error("Failed to load current plan: \(error)")
            self.errorMessage = "Failed to load your meal plan"
        }
    }
    
    private func loadTodaysMeals() async {
        guard let currentPlan = currentPlan else {
            todaysMeals = []
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date()) - 1
        
        todaysMeals = currentPlan.recipes.filter { $0.dayOfWeek == today }
            .sorted { meal1, meal2 in
                let mealOrder = ["breakfast": 0, "lunch": 1, "dinner": 2, "snack": 3]
                let order1 = mealOrder[meal1.mealType] ?? 4
                let order2 = mealOrder[meal2.mealType] ?? 4
                return order1 < order2
            }
        
        var upcoming: [PlanRecipe] = []
        for dayOffset in 1...2 {
            let targetDay = (today + dayOffset) % 7
            let dayMeals = currentPlan.recipes.filter { $0.dayOfWeek == targetDay }
            upcoming.append(contentsOf: dayMeals)
        }
        upcomingMeals = Array(upcoming.prefix(6))
        
        Logger.info("Loaded \(todaysMeals.count) meals for today and \(upcomingMeals.count) upcoming meals")
    }
    
    private func loadQuickRecipes() async {
        do {
            Logger.info("Loading quick recipes")
            
            let recipes = try await supabaseManager.fetchRecipes()
            self.quickRecipes = recipes
                .filter { $0.isQuick && $0.isPublic }
                .sorted { $0.rating > $1.rating }
                .prefix(6)
                .compactMap { $0 }
            
            Logger.info("Loaded \(quickRecipes.count) quick recipes")
            
        } catch is CancellationError {
            Logger.debug("Quick recipes fetch cancelled")
        } catch {
            Logger.error("Failed to load quick recipes: \(error)")
        }
    }
    
    private func loadGroceryStats(for userId: String) async {
        do {
            Logger.info("Loading grocery stats for user: \(userId)")
            
            let groceryItems = try await supabaseManager.fetchGroceryList(userId: userId)
            let totalItems = groceryItems.count
            let checkedItems = groceryItems.filter { $0.isCompleted }.count
            
            self.groceryStats = (totalItems, checkedItems)
            
            Logger.info("Loaded grocery stats: \(checkedItems)/\(totalItems) items checked")
            
        } catch is CancellationError {
            Logger.debug("Grocery stats fetch cancelled")
        } catch {
            Logger.error("Failed to load grocery stats: \(error)")
        }
    }
    
    private func loadRecentPlans(for userId: String) async {
        do {
            Logger.info("Loading recent plans for user: \(userId)")
            let plans = try await supabaseManager.fetchUserPlans(userId: userId)
            var planWithRecipes: [PlanWithRecipes] = []
            for plan in plans.prefix(3) {
                let recipes = try await supabaseManager.fetchPlanRecipes(planId: plan.id)
                planWithRecipes.append(PlanWithRecipes(id: plan.id, plan: plan, recipes: recipes))
            }
            self.recentPlans = planWithRecipes
            Logger.info("Loaded \(recentPlans.count) recent plans")
        } catch is CancellationError {
            Logger.debug("Recent plans fetch cancelled")
        } catch {
            Logger.error("Failed to load recent plans: \(error)")
        }
    }
    
    // MARK: - Quick Actions
    
    func toggleMealCompletion(_ meal: PlanRecipe) async {
        guard let currentPlan = currentPlan else { return }
        do {
            Logger.info("Toggling meal completion: \(meal.id)")
            if meal.isCompleted {
                try await supabaseManager.performDatabaseOperation({
                    try await supabaseManager.client
                        .from("plan_recipes")
                        .update([
                            "is_completed": false,
                            "completed_at": nil
                        ])
                        .eq("id", value: meal.id)
                        .execute()
                }, context: "markPlanRecipeIncomplete")
            } else {
                try await supabaseManager.markPlanRecipeCompleted(planRecipeId: meal.id)
            }
            if let index = todaysMeals.firstIndex(where: { $0.id == meal.id }) {
                var updatedMeal = todaysMeals[index]
                updatedMeal = PlanRecipe(
                    id: updatedMeal.id,
                    planId: updatedMeal.planId,
                    recipeId: updatedMeal.recipeId,
                    dayOfWeek: updatedMeal.dayOfWeek,
                    mealType: updatedMeal.mealType,
                    position: updatedMeal.position,
                    day: updatedMeal.day,
                    isCompleted: !updatedMeal.isCompleted,
                    completedAt: updatedMeal.isCompleted ? nil : Date(),
                    customMealName: updatedMeal.customMealName,
                    customIngredients: updatedMeal.customIngredients,
                    customInstructions: updatedMeal.customInstructions,
                    customCookTime: updatedMeal.customCookTime,
                    notes: updatedMeal.notes
                )
                todaysMeals[index] = updatedMeal
            }
            if let planIndex = currentPlan.recipes.firstIndex(where: { $0.id == meal.id }) {
                var updatedPlan = currentPlan
                var updatedRecipes = updatedPlan.recipes
                var updatedRecipe = updatedRecipes[planIndex]
                updatedRecipe = PlanRecipe(
                    id: updatedRecipe.id,
                    planId: updatedRecipe.planId,
                    recipeId: updatedRecipe.recipeId,
                    dayOfWeek: updatedRecipe.dayOfWeek,
                    mealType: updatedRecipe.mealType,
                    position: updatedRecipe.position,
                    day: updatedRecipe.day,
                    isCompleted: !updatedRecipe.isCompleted,
                    completedAt: updatedRecipe.isCompleted ? nil : Date(),
                    customMealName: updatedRecipe.customMealName,
                    customIngredients: updatedRecipe.customIngredients,
                    customInstructions: updatedRecipe.customInstructions,
                    customCookTime: updatedRecipe.customCookTime,
                    notes: updatedRecipe.notes
                )
                updatedRecipes[planIndex] = updatedRecipe
                updatedPlan = PlanWithRecipes(id: updatedPlan.id, plan: updatedPlan.plan, recipes: updatedRecipes)
                self.currentPlan = updatedPlan
                let total = updatedPlan.recipes.count
                let completed = updatedPlan.recipes.filter { $0.isCompleted }.count
                let percentage = total > 0 ? Double(completed) / Double(total) * 100.0 : 0.0
                self.weekProgress = (completed, total, percentage)
            }
        } catch {
            Logger.error("Failed to toggle meal completion: \(error)")
            self.errorMessage = "Failed to update meal status"
        }
    }
    
    func generateGroceryList() async -> Bool {
        guard let currentPlan = currentPlan else { return false }
        do {
            Logger.info("Generating grocery list for current plan")
            let groceryItems = try await supabaseManager.createGroceryListFromPlan(planId: currentPlan.id, userId: currentPlan.plan.userId)
            let totalItems = groceryItems.count
            self.groceryStats = (totalItems, 0)
            Logger.info("Successfully generated grocery list with \(totalItems) items")
            return true
        } catch {
            Logger.error("Failed to generate grocery list: \(error)")
            self.errorMessage = "Failed to generate grocery list"
            return false
        }
    }
    
    // MARK: - Navigation Actions
    
    func handleGroceryListTap() {
        showingGroceryList = true
    }
    
    func handleExploreRecipesTap(selectedTab: Binding<Int>) {
        selectedTab.wrappedValue = 2
    }
    
    func handleProfileTap(selectedTab: Binding<Int>) {
        selectedTab.wrappedValue = 3
    }
    
    func handleSettingsTap(selectedTab: Binding<Int>) {
        selectedTab.wrappedValue = 3
    }
    
    func handlePlanCreationTap() {
        showingPlanCreation = true
    }
    
    func handleCurrentPlanTap() {
        navigateToWeekDetail = true
    }
    
    // MARK: - Helper Methods
    
    func clearError() {
        errorMessage = nil
    }
    
    func refreshDashboard(for userId: String) async {
        await loadDashboardData(for: userId)
    }
    
    func getProgressColor(for percentage: Double) -> Color {
        switch percentage {
        case 0..<30:
            return .red
        case 30..<70:
            return .orange
        case 70..<90:
            return .blue
        default:
            return .green
        }
    }
    
    func getMotivationalMessage() -> String {
        let (completed, total, percentage) = todaysCompletionStatus
        
        if total == 0 {
            return "Ready to start your meal plan journey? 🌟"
        }
        
        switch percentage {
        case 0:
            return "Your meal plan is ready! Let's start cooking 👨‍🍳"
        case 1..<50:
            return "Great start! Keep going with your meal plan 💪"
        case 50..<100:
            return "You're doing amazing! Almost there 🔥"
        case 100:
            return "Perfect! You've completed all today's meals 🎉"
        default:
            return "Keep up the great work! 😊"
        }
    }
    
    func getCompletionBadge() -> String {
        let percentage = todaysCompletionStatus.percentage
        
        switch percentage {
        case 100:
            return "🏆"
        case 75..<100:
            return "🥈"
        case 50..<75:
            return "🥉"
        case 25..<50:
            return "💪"
        default:
            return "🌟"
        }
    }
} 
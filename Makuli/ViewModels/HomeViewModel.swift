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
    
    // Dashboard data
    @Published var currentPlan: PlanWithRecipes?
    @Published var todaysMeals: [PlanRecipe] = []
    @Published var upcomingMeals: [PlanRecipe] = []
    @Published var weekProgress: (completed: Int, total: Int, percentage: Double) = (0, 0, 0.0)
    @Published var recentPlans: [PlanWithRecipes] = []
    @Published var quickRecipes: [Recipe] = []
    @Published var groceryStats: (totalItems: Int, checkedItems: Int) = (0, 0)
    
    // Quick actions state
    @Published var showingPlanCreation = false
    @Published var showingAIGeneration = false
    @Published var showingGroceryList = false
    
    private let supabaseManager = SupabaseManager.shared
    
    // MARK: - Computed Properties
    
    /// Whether user has an active plan
    var hasActivePlan: Bool {
        return currentPlan != nil
    }
    
    /// Today's meals grouped by type
    var todaysMealsByType: [String: [PlanRecipe]] {
        Dictionary(grouping: todaysMeals) { $0.mealType }
    }
    
    /// Next meal to prepare
    var nextMeal: PlanRecipe? {
        let now = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: now)
        
        // Determine which meal is next based on time of day
        if currentHour < 10 {
            // Morning - next is breakfast
            return todaysMealsByType["breakfast"]?.first
        } else if currentHour < 14 {
            // Afternoon - next is lunch
            return todaysMealsByType["lunch"]?.first ?? todaysMealsByType["dinner"]?.first
        } else if currentHour < 19 {
            // Evening - next is dinner
            return todaysMealsByType["dinner"]?.first
        } else {
            // Night - next is tomorrow's breakfast
            return upcomingMeals.first { $0.mealType == "breakfast" }
        }
    }
    
    /// Completion status for today
    var todaysCompletionStatus: (completed: Int, total: Int, percentage: Double) {
        let total = todaysMeals.count
        let completed = todaysMeals.filter { $0.isCompleted }.count
        let percentage = total > 0 ? Double(completed) / Double(total) * 100.0 : 0.0
        
        return (completed, total, percentage)
    }
    
    /// Greeting based on time of day
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
    
    /// Loads all dashboard data
    func loadDashboardData(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        async let planTask = loadCurrentPlan(for: userId)
        async let mealsTask = loadTodaysMeals()
        async let recipesTask = loadQuickRecipes()
        async let groceryTask = loadGroceryStats(for: userId)
        async let recentPlansTask = loadRecentPlans(for: userId)
        
        // Wait for all tasks to complete
        await planTask
        await mealsTask
        await recipesTask
        await groceryTask
        await recentPlansTask
        
        isLoading = false
    }
    
    /// Loads the current active plan
    private func loadCurrentPlan(for userId: String) async {
        do {
            Logger.info("Loading current plan for user: \(userId)")
            let plans = try await supabaseManager.fetchUserPlans(userId: userId)
            // Fetch recipes for each plan to build PlanWithRecipes
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
        } catch {
            Logger.error("Failed to load current plan: \(error)")
            self.errorMessage = "Failed to load your meal plan"
        }
    }
    
    /// Loads today's meals from the current plan
    private func loadTodaysMeals() async {
        guard let currentPlan = currentPlan else {
            todaysMeals = []
            return
        }
        
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date()) - 1 // Convert to 0-based
        
        todaysMeals = currentPlan.recipes.filter { $0.dayOfWeek == today }
            .sorted { meal1, meal2 in
                // Sort by meal type order: breakfast, lunch, dinner, snack
                let mealOrder = ["breakfast": 0, "lunch": 1, "dinner": 2, "snack": 3]
                let order1 = mealOrder[meal1.mealType] ?? 4
                let order2 = mealOrder[meal2.mealType] ?? 4
                return order1 < order2
            }
        
        // Load upcoming meals (next 2 days)
        var upcoming: [PlanRecipe] = []
        for dayOffset in 1...2 {
            let targetDay = (today + dayOffset) % 7
            let dayMeals = currentPlan.recipes.filter { $0.dayOfWeek == targetDay }
            upcoming.append(contentsOf: dayMeals)
        }
        upcomingMeals = Array(upcoming.prefix(6))
        
        Logger.info("Loaded \(todaysMeals.count) meals for today and \(upcomingMeals.count) upcoming meals")
    }
    
    /// Loads quick recipes for recommendations
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
            
        } catch {
            Logger.error("Failed to load quick recipes: \(error)")
            // Don't show error for this, it's not critical
        }
    }
    
    /// Loads grocery list statistics
    private func loadGroceryStats(for userId: String) async {
        do {
            Logger.info("Loading grocery stats for user: \(userId)")
            
            let groceryItems = try await supabaseManager.fetchGroceryList(userId: userId)
            let totalItems = groceryItems.count
            let checkedItems = groceryItems.filter { $0.isChecked }.count
            
            self.groceryStats = (totalItems, checkedItems)
            
            Logger.info("Loaded grocery stats: \(checkedItems)/\(totalItems) items checked")
            
        } catch {
            Logger.error("Failed to load grocery stats: \(error)")
            // Don't show error for this, it's not critical
        }
    }
    
    /// Loads recent plans for quick access
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
        } catch {
            Logger.error("Failed to load recent plans: \(error)")
            // Don't show error for this, it's not critical
        }
    }
    
    // MARK: - Quick Actions
    
    /// Toggles meal completion
    func toggleMealCompletion(_ meal: PlanRecipe) async {
        guard let currentPlan = currentPlan else { return }
        do {
            Logger.info("Toggling meal completion: \(meal.id)")
            if meal.isCompleted {
                // Mark as incomplete
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
                // Mark as completed
                try await supabaseManager.markPlanRecipeCompleted(planRecipeId: meal.id)
            }
            // Update local state for todaysMeals
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
            // Update local state for currentPlan.recipes
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
                // Recalculate progress
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
    
    /// Generates grocery list for current plan
    func generateGroceryList() async -> Bool {
        guard let currentPlan = currentPlan else { return false }
        do {
            Logger.info("Generating grocery list for current plan")
            let groceryItems = try await supabaseManager.createGroceryListFromPlan(planId: currentPlan.id, userId: currentPlan.plan.userId)
            // Update grocery stats
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
    
    func handleAIGenerationTap() {
        showingAIGeneration = true
    }
    
    func handleCurrentPlanTap() {
        navigateToWeekDetail = true
    }
    
    // MARK: - Helper Methods
    
    /// Clears error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Refreshes dashboard data
    func refreshDashboard(for userId: String) async {
        await loadDashboardData(for: userId)
    }
    
    /// Gets progress color based on completion percentage
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
    
    /// Gets motivational message based on progress
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
    
    /// Gets completion badge based on progress
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
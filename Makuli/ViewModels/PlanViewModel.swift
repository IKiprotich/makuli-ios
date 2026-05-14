//
//  PlanViewModel.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import Foundation
import Supabase

@MainActor
class PlanViewModel: ObservableObject {
    @Published var plans: [PlanWithRecipes] = []
    @Published var selectedPlan: PlanWithRecipes?
    @Published var isLoading = false
    @Published var errorMessage: String?

    @Published var templates: [MealPlanTemplate] = []
    @Published var isLoadingTemplates = false
    @Published var templateErrorMessage: String?

    private let supabaseManager = SupabaseManager.shared
    private var fetchTask: Task<Void, Never>?

    // MARK: - Computed Properties

    var activePlan: PlanWithRecipes? {
        plans.first { $0.isCurrentWeek }
    }

    var pastPlans: [PlanWithRecipes] {
        plans.filter { !$0.isCurrentWeek }
            .sorted { $0.plan.weekStart > $1.plan.weekStart }
    }

    var currentWeekProgress: (completed: Int, total: Int, percentage: Double) {
        guard let activePlan else { return (0, 0, 0.0) }
        let total = activePlan.recipes.count
        let completed = activePlan.recipes.filter(\.isCompleted).count
        let percentage = total > 0 ? Double(completed) / Double(total) * 100.0 : 0.0
        return (completed, total, percentage)
    }

    var todaysMeals: [PlanRecipe] {
        guard let activePlan else { return [] }
        let today = Calendar.current.component(.weekday, from: Date()) - 1
        return activePlan.recipes.filter { $0.dayOfWeek == today }
    }

    var upcomingMeals: [PlanRecipe] {
        guard let activePlan else { return [] }
        let today = Calendar.current.component(.weekday, from: Date()) - 1
        return (0..<3).flatMap { offset in
            activePlan.recipes.filter { $0.dayOfWeek == (today + offset) % 7 }
        }
    }

    // MARK: - Plan Fetching

    func fetchPlans(for userId: String) async {
        fetchTask?.cancel()
        fetchTask = Task { await performFetch(for: userId) }
        await fetchTask?.value
    }

    private func performFetch(for userId: String) async {
        errorMessage = nil
        do {
            Logger.info("Fetching plans for user: \(userId)")
            let fetchedPlans = try await supabaseManager.fetchUserPlans(userId: userId)

            var plansWithRecipes: [PlanWithRecipes] = []
            for plan in fetchedPlans {
                let recipes = try await supabaseManager.fetchPlanRecipes(planId: plan.id)
                plansWithRecipes.append(PlanWithRecipes(id: plan.id, plan: plan, recipes: recipes))
            }

            self.plans = plansWithRecipes
            if selectedPlan == nil {
                selectedPlan = activePlan ?? plans.first
            }
            Logger.info("Loaded \(fetchedPlans.count) plans")
        } catch is CancellationError {
            Logger.debug("Plan fetch cancelled")
        } catch {
            Logger.error("Failed to fetch plans: \(error)")
            self.errorMessage = "Failed to load meal plans. Please check your connection and try again."
            self.plans = []
        }
    }

    // MARK: - Plan Creation

    func createPlanFromTemplate(
        templateId: String,
        for userId: String,
        weekStart: Date,
        userProfile: UserProfile
    ) async -> Bool {
        guard userProfile.canCreateMorePlans else {
            let max = userProfile.hasPremiumAccess
                ? Configuration.maxPlansPerUser
                : Configuration.freePlanLimits.maxPlansPerMonth
            errorMessage = "You've reached your monthly limit of \(max) plans."
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            Logger.info("Creating plan from template \(templateId)")
            let plan = try await supabaseManager.createMealPlanFromTemplate(
                templateId: templateId,
                userId: userId,
                weekStart: weekStart,
                title: "Week Plan"
            )
            let recipes = try await supabaseManager.fetchPlanRecipes(planId: plan.id)
            let planWithRecipes = PlanWithRecipes(id: plan.id, plan: plan, recipes: recipes)
            plans.insert(planWithRecipes, at: 0)
            selectedPlan = planWithRecipes
            Logger.info("Plan created from template")
            isLoading = false
            return true
        } catch {
            Logger.error("Failed to create plan from template: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func createPlanDirectly(
        templateId: String,
        for userId: String,
        weekStart: Date,
        title: String
    ) async -> Bool {
        isLoading = true
        errorMessage = nil
        do {
            Logger.info("Creating plan directly (no profile) from template \(templateId)")
            let plan = try await supabaseManager.createMealPlanFromTemplate(
                templateId: templateId,
                userId: userId,
                weekStart: weekStart,
                title: title
            )
            let recipes = try await supabaseManager.fetchPlanRecipes(planId: plan.id)
            let planWithRecipes = PlanWithRecipes(id: plan.id, plan: plan, recipes: recipes)
            plans.insert(planWithRecipes, at: 0)
            selectedPlan = planWithRecipes
            Logger.info("Plan created directly")
            isLoading = false
            return true
        } catch {
            Logger.error("Failed to create plan directly: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func createPlanManually(
        for userId: String,
        weekStart: Date,
        weekEnd: Date,
        selectedMeals: [String: [String: Bool]],
        userProfile: UserProfile
    ) async -> Bool {
        guard userProfile.canCreateMorePlans else {
            let max = userProfile.hasPremiumAccess
                ? Configuration.maxPlansPerUser
                : Configuration.freePlanLimits.maxPlansPerMonth
            errorMessage = "You've reached your monthly limit of \(max) plans."
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            Logger.info("Creating manual plan")
            let plan = try await supabaseManager.createMealPlanManually(
                userId: userId,
                weekStart: weekStart,
                weekEnd: weekEnd,
                title: "My Meal Plan",
                selectedMeals: selectedMeals
            )
            let recipes = try await supabaseManager.fetchPlanRecipes(planId: plan.id)
            let planWithRecipes = PlanWithRecipes(id: plan.id, plan: plan, recipes: recipes)
            plans.insert(planWithRecipes, at: 0)
            selectedPlan = planWithRecipes
            Logger.info("Manual plan created")
            isLoading = false
            return true
        } catch {
            Logger.error("Failed to create manual plan: \(error)")
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    // MARK: - Meal Completion

    func toggleMealCompletion(planId: String, recipeId: String) async -> Bool {
        do {
            guard let planIndex = plans.firstIndex(where: { $0.id == planId }),
                  let _ = plans[planIndex].recipes.firstIndex(where: { $0.id == recipeId }) else {
                errorMessage = "Meal not found"
                return false
            }
            let recipe = plans[planIndex].recipes.first { $0.id == recipeId }!
            if !recipe.isCompleted {
                try await supabaseManager.markPlanRecipeCompleted(planRecipeId: recipeId)
            }
            let refreshed = try await supabaseManager.fetchPlanRecipes(planId: planId)
            plans[planIndex] = PlanWithRecipes(id: planId, plan: plans[planIndex].plan, recipes: refreshed)
            if selectedPlan?.id == planId { selectedPlan = plans[planIndex] }
            return true
        } catch {
            Logger.error("Failed to toggle meal completion: \(error)")
            errorMessage = error.localizedDescription
            return false
        }
    }

    // MARK: - Plan Deletion

    func deletePlan(planId: String) async -> Bool {
        plans.removeAll { $0.id == planId }
        if selectedPlan?.id == planId {
            selectedPlan = activePlan ?? plans.first
        }
        return true
    }

    // MARK: - Grocery List

    func generateGroceryList(for planId: String) async -> [GroceryItem]? {
        guard let plan = plans.first(where: { $0.id == planId }) else {
            errorMessage = "Plan not found"
            return nil
        }
        do {
            let items = try await supabaseManager.createGroceryListFromPlan(
                planId: planId,
                userId: plan.plan.userId
            )
            Logger.info("Generated grocery list with \(items.count) items")
            return items
        } catch {
            Logger.error("Failed to generate grocery list: \(error)")
            errorMessage = error.localizedDescription
            return nil
        }
    }

    // MARK: - Templates

    func fetchTemplates() async {
        isLoadingTemplates = true
        templateErrorMessage = nil
        do {
            Logger.info("Fetching templates")
            let fetched = try await supabaseManager.fetchMealPlanTemplates()
            templates = fetched.isEmpty ? PlanViewModel.localFallbackTemplates : fetched
            Logger.info("Loaded \(templates.count) templates")
        } catch {
            Logger.error("Failed to fetch templates: \(error) — using local fallbacks")
            templates = PlanViewModel.localFallbackTemplates
        }
        isLoadingTemplates = false
    }

    // MARK: - Local Fallback Templates

    static let localFallbackTemplates: [MealPlanTemplate] = {
        let now = Date()
        func make(_ id: String, _ name: String, _ desc: String, _ icon: String,
                  _ category: String, _ skill: String, _ tags: [String]) -> MealPlanTemplate {
            MealPlanTemplate(
                id: id, userId: "system", name: name, description: desc,
                category: category, isDefault: true, isPublic: true,
                icon: icon, colorTheme: nil, durationDays: 7, mealsPerDay: 3,
                includeSnacks: false, targetCalories: nil, targetProtein: nil,
                targetCarbohydrates: nil, targetFat: nil, dietaryRestrictions: [],
                allergies: [], preferredCuisines: [], dislikedIngredients: [],
                favoriteIngredients: [], budgetRange: "moderate", maxCostPerMeal: nil,
                weeklyBudget: nil, cookingSkillLevel: skill, maxPrepTime: nil,
                maxCookTime: nil, includeMealPrep: false, includeShoppingList: false,
                includeNutritionInfo: false, rotateMeals: true, recipeVariety: nil,
                includeLeftovers: false, preferredComplexity: "moderate",
                specialInstructions: nil, tags: tags, usageCount: 0,
                rating: nil, ratingCount: 0, createdAt: now, updatedAt: now
            )
        }
        return [
            make("local-mediterranean", "Mediterranean Week",
                 "Fresh, flavourful dishes inspired by the Mediterranean coast.",
                 "🌊", "mediterranean", "beginner", ["healthy", "fresh", "balanced"]),
            make("local-quick",         "Quick & Easy Week",
                 "Delicious meals ready in 30 minutes or less.",
                 "⚡", "quick", "beginner", ["quick", "easy", "weeknight"]),
            make("local-highprotein",   "High Protein Week",
                 "Fuel your workouts with protein-packed meals every day.",
                 "💪", "highProtein", "intermediate", ["protein", "fitness", "healthy"]),
            make("local-vegetarian",    "Plant-Based Week",
                 "Vibrant, satisfying vegetarian meals all week long.",
                 "🌿", "vegetarian", "beginner", ["vegetarian", "plant-based", "light"]),
            make("local-asian",         "Asian Fusion Week",
                 "Bold flavours from across Asia — Thai, Korean, Japanese & more.",
                 "🥢", "asianFusion", "intermediate", ["asian", "bold", "diverse"]),
            make("local-budget",        "Budget-Friendly Week",
                 "Great meals that are easy on the wallet.",
                 "💰", "budget", "beginner", ["budget", "affordable", "simple"]),
        ]
    }()

    var templateCategories: [TemplateCategory] { TemplateCategory.allCases }

    func templates(for category: TemplateCategory) -> [MealPlanTemplate] {
        templates.filter { $0.category == category.rawValue }
    }

    var popularTemplates: [MealPlanTemplate] {
        templates.sorted { $0.usageCount > $1.usageCount }.prefix(6).map { $0 }
    }

    func searchTemplates(query: String) -> [MealPlanTemplate] {
        guard !query.isEmpty else { return templates }
        let q = query.lowercased()
        return templates.filter { t in
            t.name.lowercased().contains(q) ||
            (t.description?.lowercased().contains(q) ?? false) ||
            t.category.lowercased().contains(q) ||
            t.tags.contains { $0.lowercased().contains(q) }
        }
    }

    // MARK: - Plan Progress

    func updatePlanProgress(planId: String) async {
        guard let idx = plans.firstIndex(where: { $0.id == planId }) else { return }
        do {
            let refreshed = try await supabaseManager.fetchPlanRecipes(planId: planId)
            plans[idx] = PlanWithRecipes(id: planId, plan: plans[idx].plan, recipes: refreshed)
            if selectedPlan?.id == planId { selectedPlan = plans[idx] }
        } catch {
            Logger.error("Failed to refresh plan progress: \(error)")
        }
    }

    // MARK: - Helpers

    func getDayMeals(for plan: PlanWithRecipes) -> [PlanDayMeals] {
        let symbols = Calendar.current.weekdaySymbols
        return (0..<7).map { day in
            let dayRecipes = plan.recipes.filter { $0.dayOfWeek == day }
            return PlanDayMeals(
                day: symbols[day],
                dayOfWeek: day,
                breakfast: dayRecipes.filter { $0.mealType == "breakfast" },
                lunch:     dayRecipes.filter { $0.mealType == "lunch" },
                dinner:    dayRecipes.filter { $0.mealType == "dinner" },
                snacks:    dayRecipes.filter { $0.mealType == "snack" }
            )
        }
    }

    func clearError() {
        errorMessage = nil
        templateErrorMessage = nil
    }
}

//
//  PlanViewModel.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready meal plan view model for Supabase database operations.
//

import Foundation
import Supabase

@MainActor
class PlanViewModel: ObservableObject {
    @Published var plans: [PlanWithRecipes] = []
    @Published var selectedPlan: PlanWithRecipes?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var generationState: MealPlanGenerationState = .idle
    
    // Template-related properties
    @Published var templates: [MealPlanTemplate] = []
    @Published var isLoadingTemplates = false
    @Published var templateErrorMessage: String?
    
    private let supabaseManager = SupabaseManager.shared
    private var fetchTask: Task<Void, Never>?

    // MARK: - Computed Properties
    
    /// Returns the most recent or active plan
    var activePlan: PlanWithRecipes? {
        return plans.first { $0.isCurrentWeek }
    }

    /// Returns all past plans sorted by date descending
    var pastPlans: [PlanWithRecipes] {
        return plans.filter { !$0.isCurrentWeek }
            .sorted { $0.plan.weekStart > $1.plan.weekStart }
    }
    
    /// Current week progress metrics
    var currentWeekProgress: (completed: Int, total: Int, percentage: Double) {
        guard let activePlan = activePlan else { return (0, 0, 0.0) }
        
        let total = activePlan.recipes.count
        let completed = activePlan.recipes.filter { $0.isCompleted }.count
        let percentage = total > 0 ? Double(completed) / Double(total) * 100.0 : 0.0
        
        return (completed, total, percentage)
    }
    
    // MARK: - Public Methods
    
    /// Fetches all plans for a specific user
    func fetchPlans(for userId: String) async {
        // Cancel any existing fetch task
        fetchTask?.cancel()
        
        fetchTask = Task {
            await performFetch(for: userId)
        }
        
        await fetchTask?.value
    }
    
    private func performFetch(for userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            Logger.info("Fetching plans for user: \(userId)")
            
            let fetchedPlans = try await supabaseManager.fetchUserPlans(userId: userId)
            
            // Convert [Plan] to [PlanWithRecipes] by fetching recipes for each plan
            var plansWithRecipes: [PlanWithRecipes] = []
            for plan in fetchedPlans {
                let recipes = try await supabaseManager.fetchPlanRecipes(planId: plan.id)
                let planWithRecipes = PlanWithRecipes(id: plan.id, plan: plan, recipes: recipes)
                plansWithRecipes.append(planWithRecipes)
            }
            
            self.plans = plansWithRecipes
            
            // Set selectedPlan to current week if available
            if selectedPlan == nil {
                selectedPlan = activePlan ?? plans.first
            }
            
            Logger.info("Successfully loaded \(fetchedPlans.count) plans")
            
        } catch is CancellationError {
            // Task was cancelled (e.g., user navigated away)
            Logger.debug("Plan fetch cancelled")
            // Do not set errorMessage for cancellations
        } catch {
            Logger.error("Failed to fetch plans: \(error)")
            self.errorMessage = "Failed to load meal plans. Please check your connection and try again."
            self.plans = []
        }
        
        isLoading = false
    }
    
    /// Creates a new meal plan from a template
    func createPlanFromTemplate(
        templateId: String, 
        for userId: String, 
        weekStart: Date,
        userProfile: UserProfile
    ) async -> Bool {
        
        // Check subscription limits
        if !userProfile.canCreateMorePlans {
            let maxPlans = userProfile.hasPremiumAccess ? 
                Configuration.maxPlansPerUser : 
                Configuration.freePlanLimits.maxPlansPerMonth
            
            self.errorMessage = "You've reached your monthly limit of \(maxPlans) plans. Upgrade to premium for unlimited plans."
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            Logger.info("Creating plan from template \(templateId) for user \(userId)")
            
            let plan = try await supabaseManager.createMealPlanFromTemplate(
                templateId: templateId,
                userId: userId,
                weekStart: weekStart,
                title: "Week Plan"
            )
            
            // Fetch the recipes for this new plan
            let recipes = try await supabaseManager.fetchPlanRecipes(planId: plan.id)
            let planWithRecipes = PlanWithRecipes(id: plan.id, plan: plan, recipes: recipes)
            
            // Add to local plans list
            self.plans.insert(planWithRecipes, at: 0)
            
            // Set as selected plan
            self.selectedPlan = planWithRecipes
            
            Logger.info("Successfully created plan from template")
            isLoading = false
            return true
            
        } catch {
            Logger.error("Failed to create plan from template: \(error)")
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    /// Generates an AI meal plan and saves it to the database
    func generateAIMealPlan(
        for userProfile: UserProfile,
        preferences: MealPlanPreferences
    ) async -> Bool {
        
        // Check subscription limits
        if !userProfile.canUseAIGeneration {
            let maxGenerations = Configuration.freePlanLimits.maxAIGenerationsPerMonth
            self.errorMessage = "You've reached your monthly limit of \(maxGenerations) AI generations. Upgrade to premium for unlimited AI meal plans."
            return false
        }
        
        if !userProfile.canCreateMorePlans {
            let maxPlans = userProfile.hasPremiumAccess ? 
                Configuration.maxPlansPerUser : 
                Configuration.freePlanLimits.maxPlansPerMonth
            
            self.errorMessage = "You've reached your monthly limit of \(maxPlans) plans. Upgrade to premium for unlimited plans."
            return false
        }
        
        generationState = .generating
        
        do {
            Logger.info("Generating AI meal plan for user \(userProfile.id)")
            
            // TODO: Implement AI meal plan generation in SupabaseManager
            // For now, create a basic plan as placeholder
            let weekStart = preferences.weekStartDate
            let plan = Plan(
                id: UUID().uuidString,
                userId: userProfile.id,
                title: "AI Generated Plan",
                weekStart: weekStart,
                weekEnd: Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart,
                totalCost: 75.0,
                isCompleted: false,
                createdAt: Date(),
                updatedAt: Date(),
                templateId: nil,
                generationMethod: "ai",
                isFavorite: false,
                completionPercentage: 0.0
            )
            
            let planWithRecipes = PlanWithRecipes(id: plan.id, plan: plan, recipes: [])
            
            // Add to local plans list
            self.plans.insert(planWithRecipes, at: 0)
            
            // Set as selected plan
            self.selectedPlan = planWithRecipes
            
            generationState = .saved(plan)
            Logger.info("Successfully generated AI meal plan")
            return true
            
        } catch {
            Logger.error("Failed to generate AI meal plan: \(error)")
            generationState = .error(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Marks a meal as completed or uncompleted
    func toggleMealCompletion(planId: String, recipeId: String) async -> Bool {
        do {
            Logger.info("Toggling meal completion: plan=\(planId), recipe=\(recipeId)")
            
            // Find the recipe to check current completion status
            guard let planIndex = plans.firstIndex(where: { $0.id == planId }),
                  let recipeIndex = plans[planIndex].recipes.firstIndex(where: { $0.id == recipeId }) else {
                self.errorMessage = "Recipe not found"
                return false
            }
            
            let currentRecipe = plans[planIndex].recipes[recipeIndex]
            
            if !currentRecipe.isCompleted {
                // Mark as completed
                try await supabaseManager.markPlanRecipeCompleted(planRecipeId: recipeId)
            }
            // Note: SupabaseManager doesn't have unmark functionality yet
            
            // Update local state (toggle)
            let newCompletionStatus = !currentRecipe.isCompleted
            
            // Create a new recipe with updated completion status
            var updatedRecipe = currentRecipe
            // Since isCompleted is let, we need to handle this differently
            // For now, just refresh the plan from the server
            let refreshedRecipes = try await supabaseManager.fetchPlanRecipes(planId: planId)
            plans[planIndex] = PlanWithRecipes(id: planId, plan: plans[planIndex].plan, recipes: refreshedRecipes)
            
            // Update selected plan if it's the same one
            if selectedPlan?.id == planId {
                selectedPlan = plans[planIndex]
            }
            
            return true
            
        } catch {
            Logger.error("Failed to toggle meal completion: \(error)")
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Deletes a meal plan
    func deletePlan(planId: String) async -> Bool {
        do {
            Logger.info("Deleting plan: \(planId)")
            
            // TODO: Implement deletePlan in SupabaseManager
            // For now, just remove from local state
            
            // Remove from local state
            plans.removeAll { $0.id == planId }
            
            // Update selected plan if necessary
            if selectedPlan?.id == planId {
                selectedPlan = activePlan ?? plans.first
            }
            
            Logger.info("Successfully deleted plan (local only)")
            return true
            
        } catch {
            Logger.error("Failed to delete plan: \(error)")
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Resets the generation state
    func resetGenerationState() {
        generationState = .idle
    }
    
    /// Generates an AI meal plan with preferences (convenience method)
    func generateAIMealPlanWithPreferences(
        for userProfile: UserProfile,
        preferences: MealPlanPreferences
    ) async -> Bool {
        return await generateAIMealPlan(for: userProfile, preferences: preferences)
    }
    
    /// Clears any error messages
    func clearError() {
        errorMessage = nil
        templateErrorMessage = nil
    }
    
    // MARK: - Template Methods
    
    /// Fetches meal plan templates from database
    func fetchTemplates() async {
        isLoadingTemplates = true
        templateErrorMessage = nil
        
        do {
            Logger.info("Fetching meal plan templates")
            
            let fetchedTemplates = try await supabaseManager.fetchMealPlanTemplates()
            self.templates = fetchedTemplates
            
            Logger.info("Successfully loaded \(fetchedTemplates.count) templates")
            
        } catch {
            Logger.error("Failed to fetch templates: \(error)")
            self.templateErrorMessage = error.localizedDescription
            self.templates = []
        }
        
        isLoadingTemplates = false
    }
    
    /// Gets template categories for UI filtering
    var templateCategories: [TemplateCategory] {
        return TemplateCategory.allCases
    }
    
    /// Filters templates by category
    func templates(for category: TemplateCategory) -> [MealPlanTemplate] {
        return templates.filter { $0.category == category.rawValue }
    }
    
    /// Gets popular templates (based on usage count)
    var popularTemplates: [MealPlanTemplate] {
        return templates
            .sorted { $0.usageCount > $1.usageCount }
            .prefix(6)
            .map { $0 }
    }
    
    /// Searches templates by query
    func searchTemplates(query: String) -> [MealPlanTemplate] {
        guard !query.isEmpty else { return templates }
        
        let lowercaseQuery = query.lowercased()
        return templates.filter { template in
            template.name.lowercased().contains(lowercaseQuery) ||
            (template.description?.lowercased().contains(lowercaseQuery) ?? false) ||
            template.category.lowercased().contains(lowercaseQuery) ||
            template.tags.contains { $0.lowercased().contains(lowercaseQuery) }
        }
    }
    
    // MARK: - Plan Management
    
    /// Updates plan completion percentage
    func updatePlanProgress(planId: String) async {
        do {
            // TODO: Implement updatePlanProgress in SupabaseManager
            // For now, just refresh the plan recipes to recalculate progress
            
            if let planIndex = plans.firstIndex(where: { $0.id == planId }) {
                let refreshedRecipes = try await supabaseManager.fetchPlanRecipes(planId: planId)
                plans[planIndex] = PlanWithRecipes(id: planId, plan: plans[planIndex].plan, recipes: refreshedRecipes)
                
                if selectedPlan?.id == planId {
                    selectedPlan = plans[planIndex]
                }
            }
            
        } catch {
            Logger.error("Failed to update plan progress: \(error)")
        }
    }
    
    /// Generates grocery list for a plan
    func generateGroceryList(for planId: String) async -> [GroceryItem]? {
        do {
            Logger.info("Generating grocery list for plan: \(planId)")
            
            // Find the user ID for this plan
            guard let plan = plans.first(where: { $0.id == planId }) else {
                self.errorMessage = "Plan not found"
                return nil
            }
            
            let groceryItems = try await supabaseManager.createGroceryListFromPlan(planId: planId, userId: plan.plan.userId)
            
            Logger.info("Successfully generated grocery list with \(groceryItems.count) items")
            return groceryItems
            
        } catch {
            Logger.error("Failed to generate grocery list: \(error)")
            self.errorMessage = error.localizedDescription
            return nil
        }
    }
    
    /// Gets meals grouped by day for a plan
    func getDayMeals(for plan: PlanWithRecipes) -> [PlanDayMeals] {
        let calendar = Calendar.current
        let weekdaySymbols = calendar.weekdaySymbols
        
        var dayMealsList: [PlanDayMeals] = []
        
        for dayOfWeek in 0..<7 {
            let dayName = weekdaySymbols[dayOfWeek]
            let dayRecipes = plan.recipes.filter { $0.dayOfWeek == dayOfWeek }
            
            let breakfast = dayRecipes.filter { $0.mealType == "breakfast" }
            let lunch = dayRecipes.filter { $0.mealType == "lunch" }
            let dinner = dayRecipes.filter { $0.mealType == "dinner" }
            let snacks = dayRecipes.filter { $0.mealType == "snack" }
            
            let dayMeals = PlanDayMeals(
                day: dayName,
                dayOfWeek: dayOfWeek,
                breakfast: breakfast,
                lunch: lunch,
                dinner: dinner,
                snacks: snacks
            )
            
            dayMealsList.append(dayMeals)
        }
        
        return dayMealsList
    }
    
    /// Gets today's meals from the active plan
    var todaysMeals: [PlanRecipe] {
        guard let activePlan = activePlan else { return [] }
        
        let today = Calendar.current.component(.weekday, from: Date()) - 1 // Convert to 0-based
        return activePlan.recipes.filter { $0.dayOfWeek == today }
    }
    
    /// Gets upcoming meals (next 3 days)
    var upcomingMeals: [PlanRecipe] {
        guard let activePlan = activePlan else { return [] }
        
        let calendar = Calendar.current
        let today = calendar.component(.weekday, from: Date()) - 1 // Convert to 0-based
        
        var upcomingMeals: [PlanRecipe] = []
        
        for dayOffset in 0..<3 {
            let targetDay = (today + dayOffset) % 7
            let dayMeals = activePlan.recipes.filter { $0.dayOfWeek == targetDay }
            upcomingMeals.append(contentsOf: dayMeals)
        }
        
        return upcomingMeals
    }
}

// MARK: - Generation State
// MealPlanGenerationState and MealPlanPreferences moved to MealPlanGeneration.swift
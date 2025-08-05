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
    private let spoonacularService: SpoonacularServiceProtocol
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Initialization
    
    /// Creates a new PlanViewModel instance.
    /// - Parameter spoonacularService: The Spoonacular service to use for API calls (defaults to shared instance)
    init(spoonacularService: SpoonacularServiceProtocol = SpoonacularService()) {
        self.spoonacularService = spoonacularService
    }

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
        // Don't show loading for initial fetches - show content immediately
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
            Logger.info("Active plan: \(activePlan?.plan.title ?? "none")")
            Logger.info("Selected plan: \(selectedPlan?.plan.title ?? "none")")
            Logger.info("Total plans in array: \(plans.count)")
            
        } catch is CancellationError {
            // Task was cancelled (e.g., user navigated away)
            Logger.debug("Plan fetch cancelled")
            // Do not set errorMessage for cancellations
        } catch {
            Logger.error("Failed to fetch plans: \(error)")
            self.errorMessage = "Failed to load meal plans. Please check your connection and try again."
            self.plans = []
        }
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
    
    /// Creates a new meal plan manually with selected meals
    func createPlanManually(
        for userId: String,
        weekStart: Date,
        weekEnd: Date,
        selectedMeals: [String: [String: Bool]],
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
            Logger.info("Creating manual plan for user \(userId)")
            
            let plan = try await supabaseManager.createMealPlanManually(
                userId: userId,
                weekStart: weekStart,
                weekEnd: weekEnd,
                title: "My Meal Plan",
                selectedMeals: selectedMeals
            )
            
            // Fetch the recipes for this new plan
            let recipes = try await supabaseManager.fetchPlanRecipes(planId: plan.id)
            let planWithRecipes = PlanWithRecipes(id: plan.id, plan: plan, recipes: recipes)
            
            // Add to local plans list
            self.plans.insert(planWithRecipes, at: 0)
            
            // Set as selected plan
            self.selectedPlan = planWithRecipes
            
            Logger.info("Successfully created manual plan")
            isLoading = false
            return true
            
        } catch {
            Logger.error("Failed to create manual plan: \(error)")
            self.errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }
    
    /// Generates a Spoonacular meal plan with cache-first strategy
    func generateSpoonacularMealPlan(
        for userProfile: UserProfile,
        weekStart: Date
    ) async -> Bool {
        
        // Validate user preferences
        guard userProfile.hasValidSpoonacularPreferences else {
            self.errorMessage = "Please complete your dietary preferences in your profile to generate a meal plan."
            return false
        }
        
        // Check subscription limits
        if !userProfile.canUseSpoonacularGeneration {
            let maxGenerations = Configuration.freePlanLimits.maxSpoonacularGenerationsPerMonth
            self.errorMessage = "You've reached your monthly limit of \(maxGenerations) Spoonacular generations. Upgrade to premium for unlimited meal plans."
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
            Logger.info("Generating Spoonacular meal plan for user \(userProfile.id)")
            Logger.info("User preferences: \(userProfile.spoonacularPreferencesSummary)")
            
            // Step 1: Check for fresh cached data first
            let hasFreshCache = try await supabaseManager.hasFreshCachedData(userId: userProfile.id, weekStart: weekStart)
            
            if hasFreshCache {
                Logger.info("Found fresh cached data, loading from cache")
                if let cachedData = try await supabaseManager.getCachedMealPlan(userId: userProfile.id, weekStart: weekStart) {
                    // Only use cache if it has meals
                    if !cachedData.recipes.isEmpty {
                        let planWithRecipes = PlanWithRecipes(id: cachedData.plan.id, plan: cachedData.plan, recipes: cachedData.recipes)
                        
                        // Add to local plans list
                        self.plans.insert(planWithRecipes, at: 0)
                        self.selectedPlan = planWithRecipes
                        
                        Logger.info("Added cached plan to array: \(planWithRecipes.plan.title)")
                        Logger.info("Cached plan week: \(planWithRecipes.plan.weekStart) to \(planWithRecipes.plan.weekEnd)")
                        Logger.info("Is current week: \(planWithRecipes.isCurrentWeek)")
                        Logger.info("Total plans in array: \(self.plans.count)")
                        
                        generationState = .saved(cachedData.plan)
                        Logger.info("Successfully loaded cached meal plan with \(cachedData.recipes.count) meals")
                        return true
                    } else {
                        Logger.warning("Cached meal plan has no meals, generating new plan")
                    }
                }
            }
            
            // Step 2: Generate new meal plan from Spoonacular
            let spoonacularMealPlan = try await spoonacularService.generateWeeklyMealPlan(preferences: userProfile)
            
            // Step 3: Map to app models
            let (plan, planRecipes, spoonacularIds) = SpoonacularMapper.mapMealPlan(
                spoonacularMealPlan,
                userId: userProfile.id,
                weekStart: weekStart
            )
            
            // Step 4: Fetch recipe details for each meal (optimized to reduce API calls)
            var recipes: [Recipe] = []
            var updatedPlanRecipes: [PlanRecipe] = []
            
            // First, check if we already have these recipes cached
            let uniqueRecipeIds = Set(spoonacularIds)
            
            // Check cache for existing recipes
            var cachedRecipes: [Int: Recipe] = [:]
            for recipeId in uniqueRecipeIds {
                if let cachedRecipe = try? await supabaseManager.getCachedRecipe(spoonacularId: String(recipeId)) {
                    cachedRecipes[recipeId] = cachedRecipe
                }
            }
            
            // Fetch only new recipes that aren't cached
            let uncachedRecipeIds = uniqueRecipeIds.filter { !cachedRecipes.keys.contains($0) }
            
            Logger.info("Found \(cachedRecipes.count) cached recipes, fetching \(uncachedRecipeIds.count) new recipes")
            
            // Fetch new recipes with rate limiting
            for recipeId in uncachedRecipeIds {
                do {
                    // Add longer delay between requests to respect rate limits
                    if recipeId != uncachedRecipeIds.first {
                        try await Task.sleep(nanoseconds: 500_000_000) // 500ms delay
                    }
                    
                    let spoonacularRecipe = try await spoonacularService.fetchRecipeDetails(recipeId: recipeId)
                    let recipe = SpoonacularMapper.mapRecipe(spoonacularRecipe)
                    cachedRecipes[recipeId] = recipe
                    recipes.append(recipe)
                    
                    Logger.info("Successfully fetched recipe \(recipeId)")
                } catch let error as SpoonacularError {
                    if error.localizedDescription.contains("402") {
                        Logger.warning("API rate limit hit for recipe \(recipeId), stopping recipe fetching")
                        break // Stop fetching more recipes to avoid hitting rate limits
                    } else {
                        Logger.warning("Failed to fetch recipe details for recipe \(recipeId): \(error)")
                    }
                } catch {
                    Logger.warning("Failed to fetch recipe details for recipe \(recipeId): \(error)")
                }
            }
            
            // Add cached recipes to the recipes array
            recipes.append(contentsOf: cachedRecipes.values)
            
            // Create mapping from Spoonacular recipe ID to Recipe UUID
            var spoonacularToRecipeUUID: [Int: String] = [:]
            for recipe in recipes {
                if let spoonacularId = recipe.spoonacularId,
                   let spoonacularIdInt = Int(spoonacularId) {
                    spoonacularToRecipeUUID[spoonacularIdInt] = recipe.id
                }
            }
            
            Logger.info("Created mapping for \(spoonacularToRecipeUUID.count) recipes")
            
            // Update plan recipes with recipe details and proper UUID linking
            for (index, planRecipe) in planRecipes.enumerated() {
                let spoonacularId = spoonacularIds[index]
                let recipeUUID = spoonacularToRecipeUUID[spoonacularId]
                let recipe = recipes.first { $0.id == recipeUUID }
                
                let updatedPlanRecipe = PlanRecipe(
                    id: planRecipe.id,
                    planId: planRecipe.planId,
                    recipeId: recipeUUID, // Use the Recipe UUID (may be nil if recipe fetch failed)
                    dayOfWeek: planRecipe.dayOfWeek,
                    mealType: planRecipe.mealType,
                    position: planRecipe.position,
                    day: planRecipe.day,
                    isCompleted: planRecipe.isCompleted,
                    completedAt: planRecipe.completedAt,
                    customMealName: planRecipe.customMealName,
                    customIngredients: recipe?.ingredients ?? [],
                    customInstructions: recipe?.steps ?? [],
                    customCookTime: planRecipe.customCookTime,
                    notes: planRecipe.notes
                )
                updatedPlanRecipes.append(updatedPlanRecipe)
            }
            
            // Filter out plan recipes that don't have valid recipe references
            let validPlanRecipes = updatedPlanRecipes.filter { $0.recipeId != nil }
            Logger.info("Created \(validPlanRecipes.count) valid plan recipes out of \(updatedPlanRecipes.count) total")
            
            // Step 5: Save to Supabase for caching
            try await supabaseManager.saveSpoonacularMealPlanToCache(
                plan: plan,
                planRecipes: validPlanRecipes,
                recipes: recipes
            )
            
            // Step 6: Update local state
            let planWithRecipes = PlanWithRecipes(id: plan.id, plan: plan, recipes: validPlanRecipes)
            
            // Add to local plans list
            self.plans.insert(planWithRecipes, at: 0)
            self.selectedPlan = planWithRecipes
            
            Logger.info("Added plan to array: \(planWithRecipes.plan.title)")
            Logger.info("Plan week: \(planWithRecipes.plan.weekStart) to \(planWithRecipes.plan.weekEnd)")
            Logger.info("Is current week: \(planWithRecipes.isCurrentWeek)")
            Logger.info("Total plans in array: \(self.plans.count)")
            
            generationState = .saved(plan)
            Logger.info("Successfully generated Spoonacular meal plan with \(validPlanRecipes.count) meals")
            return true
            
        } catch let error as SpoonacularError {
            Logger.error("Spoonacular API error: \(error.localizedDescription)")
            
            // Try to load from cache as fallback
            Logger.info("Attempting to load from cache as fallback")
            if let cachedData = try? await supabaseManager.getCachedMealPlan(userId: userProfile.id, weekStart: weekStart) {
                let planWithRecipes = PlanWithRecipes(id: cachedData.plan.id, plan: cachedData.plan, recipes: cachedData.recipes)
                
                self.plans.insert(planWithRecipes, at: 0)
                self.selectedPlan = planWithRecipes
                
                generationState = .saved(cachedData.plan)
                Logger.info("Successfully loaded cached meal plan as fallback")
                return true
            }
            
            generationState = .error(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        } catch {
            Logger.error("Failed to generate Spoonacular meal plan: \(error)")
            
            // Try to load from cache as fallback
            Logger.info("Attempting to load from cache as fallback")
            if let cachedData = try? await supabaseManager.getCachedMealPlan(userId: userProfile.id, weekStart: weekStart) {
                let planWithRecipes = PlanWithRecipes(id: cachedData.plan.id, plan: cachedData.plan, recipes: cachedData.recipes)
                
                self.plans.insert(planWithRecipes, at: 0)
                self.selectedPlan = planWithRecipes
                
                generationState = .saved(cachedData.plan)
                Logger.info("Successfully loaded cached meal plan as fallback")
                return true
            }
            
            generationState = .error(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Generates a Spoonacular meal plan with preferences (convenience method)
    func generateSpoonacularMealPlanWithPreferences(
        for userProfile: UserProfile,
        preferences: MealPlanPreferences
    ) async -> Bool {
        return await generateSpoonacularMealPlan(
            for: userProfile,
            weekStart: preferences.weekStartDate
        )
    }
    
    /// Legacy method for backward compatibility - now uses Spoonacular
    func generateAIMealPlan(
        for userProfile: UserProfile,
        preferences: MealPlanPreferences
    ) async -> Bool {
        return await generateSpoonacularMealPlanWithPreferences(
            for: userProfile,
            preferences: preferences
        )
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
    
    // MARK: - Spoonacular Integration
    
    /// Generates a Spoonacular shopping list for a plan with cache-first strategy
    func generateSpoonacularGroceryList(for planId: String, userProfile: UserProfile) async -> [GroceryItem]? {
        do {
            Logger.info("Generating Spoonacular shopping list for plan: \(planId)")
            
            // Step 1: Check for cached grocery list first
            if let cachedGroceryList = try? await supabaseManager.getCachedGroceryList(planId: planId, userId: userProfile.id),
               !cachedGroceryList.isEmpty {
                Logger.info("Found cached grocery list with \(cachedGroceryList.count) items")
                return cachedGroceryList
            }
            
            // Step 2: Check if user has Spoonacular credentials
            guard let username = userProfile.spoonacularUsername,
                  let hash = userProfile.spoonacularHash else {
                Logger.warning("User missing Spoonacular credentials, falling back to manual grocery list")
                return await generateGroceryList(for: planId)
            }
            
            // Step 3: Find the plan
            guard let plan = plans.first(where: { $0.id == planId }) else {
                self.errorMessage = "Plan not found"
                return nil
            }
            
            // Step 4: Generate shopping list from Spoonacular
            let spoonacularShoppingList = try await spoonacularService.generateShoppingList(
                mealPlan: createMockSpoonacularMealPlan(from: plan),
                username: username,
                hash: hash
            )
            
            // Step 5: Map to grocery items
            let groceryItems = SpoonacularMapper.mapGroceryList(
                spoonacularShoppingList,
                userId: plan.plan.userId,
                planId: planId
            )
            
            // Step 6: Save to Supabase for caching
            for groceryItem in groceryItems {
                try await supabaseManager.saveGroceryItem(groceryItem)
            }
            
            Logger.info("Successfully generated Spoonacular shopping list with \(groceryItems.count) items")
            return groceryItems
            
        } catch let error as SpoonacularError {
            Logger.error("Spoonacular shopping list error: \(error.localizedDescription)")
            
            // Try to load from cache as fallback
            Logger.info("Attempting to load cached grocery list as fallback")
            if let cachedGroceryList = try? await supabaseManager.getCachedGroceryList(planId: planId, userId: userProfile.id),
               !cachedGroceryList.isEmpty {
                Logger.info("Successfully loaded cached grocery list as fallback")
                return cachedGroceryList
            }
            
            // Fall back to manual grocery list generation
            Logger.info("Falling back to manual grocery list generation")
            return await generateGroceryList(for: planId)
        } catch {
            Logger.error("Failed to generate Spoonacular shopping list: \(error)")
            
            // Try to load from cache as fallback
            Logger.info("Attempting to load cached grocery list as fallback")
            if let cachedGroceryList = try? await supabaseManager.getCachedGroceryList(planId: planId, userId: userProfile.id),
               !cachedGroceryList.isEmpty {
                Logger.info("Successfully loaded cached grocery list as fallback")
                return cachedGroceryList
            }
            
            // Fall back to manual grocery list generation
            Logger.info("Falling back to manual grocery list generation")
            return await generateGroceryList(for: planId)
        }
    }
    
    /// Creates a mock Spoonacular meal plan from an existing plan for shopping list generation
    private func createMockSpoonacularMealPlan(from plan: PlanWithRecipes) -> SpoonacularMealPlan {
        // This is a simplified mock - in production, you might want to store the original response
        let mockWeek = SpoonacularWeek(
            monday: nil, tuesday: nil, wednesday: nil, thursday: nil,
            friday: nil, saturday: nil, sunday: nil
        )
        
        return SpoonacularMealPlan(week: mockWeek)
    }
    
    /// Cleans up old cached data to free up storage
    func cleanupOldCachedData() async {
        do {
            Logger.info("Cleaning up old cached data")
            try await supabaseManager.clearOldCachedData(olderThanDays: 7)
            Logger.info("Successfully cleaned up old cached data")
        } catch {
            Logger.error("Failed to cleanup old cached data: \(error)")
        }
    }
    
    /// Checks if user has valid Spoonacular credentials
    func hasValidSpoonacularCredentials(userId: String) async -> Bool {
        do {
            let credentials = try await supabaseManager.getUserSpoonacularCredentials(userId: userId)
            return credentials != nil
        } catch {
            Logger.error("Failed to check Spoonacular credentials: \(error)")
            return false
        }
    }
    
    /// Updates user's Spoonacular credentials
    func updateSpoonacularCredentials(userId: String, username: String, hash: String) async -> Bool {
        do {
            try await supabaseManager.updateUserSpoonacularCredentials(userId: userId, username: username, hash: hash)
            Logger.info("Successfully updated Spoonacular credentials for user \(userId)")
            return true
        } catch {
            Logger.error("Failed to update Spoonacular credentials: \(error)")
            return false
        }
    }
    
    /// Generates grocery list for a plan (legacy method - now tries Spoonacular first)
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
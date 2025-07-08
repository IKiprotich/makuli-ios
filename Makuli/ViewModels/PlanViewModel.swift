//
//  PlanViewModel.swift
//  Makuli
//
//  Created by on 2025-07-03.
//
//  Handles fetching and managing meal plan data from Supabase.
//
import Foundation
import Supabase

@MainActor
class PlanViewModel: ObservableObject {
    @Published var plans: [SupabasePlan] = []
    @Published var selectedWeek: WeekPlan?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var generationState: MealPlanGenerationState = .idle
    
    private let supabase = SupabaseManager.shared.client
    private let aiService = AIService.shared
    private var fetchTask: Task<Void, Never>?

    // MARK: - Computed Properties
    
    /// Maps Supabase plans to WeekPlan UI models
    var weekPlans: [WeekPlan] {
        let mapped = plans.compactMap { plan in
            mapPlanToWeekPlan(plan)
        }
        // Fallback to mock data if no plans exist
        return mapped.isEmpty ? WeekPlan.mockData : mapped
    }

    /// Returns the most recent or active plan
    var activePlan: WeekPlan? {
        return weekPlans.first
    }

    /// Returns all past plans sorted by week number descending
    var pastPlans: [WeekPlan] {
        guard let active = activePlan else { return weekPlans }
        return weekPlans.filter { $0.id != active.id }
            .sorted(by: { $0.weekNumber > $1.weekNumber })
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
            // Fetch plans
            let plansResponse = try await supabase
                .from("plans")
                .select("*")
                .eq("user_id", value: userId)
                .order("week_start", ascending: false)
                .execute()
            
            let fetchedPlans = try JSONDecoder().decode([SupabasePlan].self, from: plansResponse.data)
            
            self.plans = fetchedPlans
            
            // Set selectedWeek if not already set
            if selectedWeek == nil, let first = weekPlans.first {
                selectedWeek = first
            }
            
        } catch {
            errorMessage = "Failed to fetch plans: \(error.localizedDescription)"
            Logger.error("Failed to fetch plans: \(error)")
            
            // Fallback to mock data on error
            self.plans = []
            if selectedWeek == nil, let first = weekPlans.first {
                selectedWeek = first
            }
        }
        
        isLoading = false
    }
    
    /// Generates an AI meal plan and saves it to the database
    func generateAndSaveAIMealPlan(for userProfile: UserProfile, weekStart: Date) async {
        generationState = .generating
        
        do {
            // 1. Generate meal plan using AI
            let request = MealPlanGenerationRequest.fromUserProfile(userProfile, weekStart: weekStart)
            let aiResponse = try await aiService.generateMealPlan(request: request)
            
            generationState = .generated(aiResponse)
            
            // 2. Convert AI response to app models
            let allMeals = aiResponse.meals.flatMap { dayPlan in
                dayPlan.toMeals()
            }
            
            // 3. Save to database
            generationState = .saving
            
            let success = await createNewPlan(
                for: userProfile.id,
                title: aiResponse.weekTitle,
                weekStart: weekStart,
                meals: allMeals
            )
            
            if success {
                // Find the newly created plan
                if let newPlan = plans.first(where: { plan in
                    guard let planWeekStart = plan.week_start else { return false }
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withFullDate]
                    let planDate = dateFormatter.date(from: planWeekStart)
                    return Calendar.current.isDate(planDate ?? Date(), equalTo: weekStart, toGranularity: .day)
                }) {
                    // Convert SupabasePlan to Plan for UI
                    if let uiPlan = mapPlanToWeekPlan(newPlan) {
                        generationState = .saved(uiPlan)
                    } else {
                        generationState = .error("Failed to convert plan data")
                    }
                } else {
                    generationState = .error("Plan was created but could not be retrieved")
                }
            } else {
                generationState = .error(errorMessage ?? "Failed to save meal plan")
            }
            
        } catch {
            Logger.error("Failed to generate AI meal plan: \(error)")
            generationState = .error("Failed to generate meal plan: \(error.localizedDescription)")
        }
    }
    
    /// Generates AI meal plan with custom preferences
    func generateAIMealPlanWithPreferences(
        for userProfile: UserProfile,
        preferences: MealPlanPreferences
    ) async {
        generationState = .generating
        
        do {
            // Create custom request with user preferences
            let customRequest = MealPlanGenerationRequest(
                age: userProfile.age ?? 25,
                gender: userProfile.gender ?? "Not specified",
                dietaryPreferences: ([userProfile.diet ?? "No restrictions"] + preferences.dietaryRestrictions).joined(separator: ", "),
                budget: preferences.budget,
                goal: preferences.goals.joined(separator: ", "),
                weekStart: {
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withFullDate]
                    return dateFormatter.string(from: preferences.weekStartDate)
                }()
            )
            
            let aiResponse = try await aiService.generateMealPlan(request: customRequest)
            generationState = .generated(aiResponse)
            
            // Convert and save
            let allMeals = aiResponse.meals.flatMap { $0.toMeals() }
            
            generationState = .saving
            
            let success = await createNewPlan(
                for: userProfile.id,
                title: aiResponse.weekTitle,
                weekStart: preferences.weekStartDate,
                meals: allMeals
            )
            
            if success {
                if let newPlan = plans.first(where: { plan in
                    guard let planWeekStart = plan.week_start else { return false }
                    let dateFormatter = ISO8601DateFormatter()
                    dateFormatter.formatOptions = [.withFullDate]
                    let planDate = dateFormatter.date(from: planWeekStart)
                    return Calendar.current.isDate(planDate ?? Date(), equalTo: preferences.weekStartDate, toGranularity: .day)
                }) {
                    // Convert SupabasePlan to Plan for UI
                    if let uiPlan = mapPlanToWeekPlan(newPlan) {
                        generationState = .saved(uiPlan)
                    } else {
                        generationState = .error("Failed to convert plan data")
                    }
                } else {
                    generationState = .error("Plan was created but could not be retrieved")
                }
            } else {
                generationState = .error(errorMessage ?? "Failed to save meal plan")
            }
            
        } catch {
            Logger.error("Failed to generate custom AI meal plan: \(error)")
            generationState = .error("Failed to generate meal plan: \(error.localizedDescription)")
        }
    }
    
    /// Resets the generation state
    func resetGenerationState() {
        generationState = .idle
    }
    
    /// Creates a new meal plan
    func createNewPlan(for userId: String, title: String, weekStart: Date, meals: [Meal]) async -> Bool {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. Create the plan record
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withFullDate]
            
            let createPlanRequest = CreateSupabasePlanRequest(
                user_id: userId,
                title: title,
                week_start: dateFormatter.string(from: weekStart)
            )
            
            let planResponse = try await supabase
                .from("plans")
                .insert(createPlanRequest)
                .select()
                .single()
                .execute()
            
            let createdPlan = try JSONDecoder().decode(SupabasePlan.self, from: planResponse.data)
            
            // 2. Process recipes and create plan_recipes records
            var planRecipeRequests: [CreatePlanRecipeRequest] = []
            
            for (dayIndex, meal) in meals.enumerated() {
                guard let recipe = meal.recipe else { 
                    Logger.debug("Skipping meal without recipe: \(meal.name)")
                    continue 
                }
                
                // Check if recipe exists in database, create if it doesn't
                let recipeId = try await ensureRecipeExists(recipe)
                
                let dayName = Calendar.current.weekdaySymbols[dayIndex % 7]
                let mealType = meal.category.rawValue.lowercased()
                
                let planRecipeRequest = CreatePlanRecipeRequest(
                    plan_id: createdPlan.id,
                    recipe_id: recipeId,
                    day_of_week: dayIndex % 7,
                    meal_type: mealType,
                    position: 0,
                    day: dayName
                )
                
                planRecipeRequests.append(planRecipeRequest)
            }
            
            if !planRecipeRequests.isEmpty {
                Logger.debug("Adding \(planRecipeRequests.count) recipe entries to plan")
                try await supabase
                    .from("plan_recipes")
                    .insert(planRecipeRequests)
                    .execute()
            } else {
                Logger.info("No recipes data available - using empty list")
            }
            
            // 3. Refresh plans list
            await fetchPlans(for: userId)
            
            Logger.info("Successfully created plan: \(title)")
            return true
            
        } catch {
            errorMessage = "Failed to create plan: \(error.localizedDescription)"
            Logger.error("Failed to create plan: \(error)")
            isLoading = false
            return false
        }
    }
    
    /// Fetches detailed meal plan with recipes for a specific plan
    func fetchPlanDetails(planId: String) async -> WeekPlan? {
        do {
            // Fetch plan details with recipes
            let _ = try await supabase
                .from("plan_recipes")
                .select("""
                    *,
                    recipes (
                        id,
                        title,
                        ingredients,
                        steps,
                        prep_time,
                        cook_time,
                        calories,
                        image_url
                    )
                """)
                .eq("plan_id", value: planId)
                .execute()
            
            // TODO: Parse the response and create a detailed WeekPlan
            // This would require creating a more complex response model
            
            return nil
            
        } catch {
            Logger.error("Failed to fetch plan details: \(error)")
            return nil
        }
    }
    
    /// Adds a new plan (wrapper for createNewPlan with default values)
    func addNewPlan() {
        Task {
            // This would need to be triggered from a plan creation flow
            // For now, just log that it was called
            Logger.debug("Add new plan requested - should open plan creation flow")
        }
    }
    
    // MARK: - Private Helpers
    
    /// Ensures a recipe exists in the database, creating it if necessary
    private func ensureRecipeExists(_ recipe: Recipe) async throws -> String {
        let recipeId = recipe.id.uuidString
        
        do {
            // Check if recipe already exists
            let existingRecipes = try await supabase
                .from("recipes")
                .select("id")
                .eq("id", value: recipeId)
                .execute()
            
            if existingRecipes.data.isEmpty {
                // Recipe doesn't exist, create it
                Logger.debug("Creating new recipe in database: \(recipe.title)")
                
                let recipeData = RecipeData(
                    id: recipeId,
                    title: recipe.title,
                    cookTime: recipe.cookTime,
                    servings: recipe.servings,
                    imageName: recipe.imageName,
                    ingredients: recipe.ingredients,
                    steps: recipe.steps,
                    substitutions: recipe.substitutions,
                    tags: recipe.tags,
                    createdAt: Date()
                )
                
                try await supabase
                    .from("recipes")
                    .insert(recipeData)
                    .execute()
                
                Logger.debug("Successfully created recipe: \(recipe.title)")
            }
            
            return recipeId
            
        } catch {
            Logger.warning("Failed to ensure recipe exists, using existing recipe: \(error)")
            // Fallback: try to find a similar existing recipe or use a default one
            let fallbackRecipes = Recipe.enhancedMockRecipes()
            if let fallbackRecipe = fallbackRecipes.first {
                return fallbackRecipe.id.uuidString
            } else {
                throw error
            }
        }
    }
    
    private func mapPlanToWeekPlan(_ plan: SupabasePlan) -> WeekPlan? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]
        
        guard let weekStartString = plan.week_start,
              let weekStartDate = dateFormatter.date(from: weekStartString) else {
            return nil
        }
        
        let endDate = Calendar.current.date(byAdding: .day, value: 6, to: weekStartDate) ?? weekStartDate
        
        return Plan(
            planName: plan.title ?? "Untitled Plan",
            weekStartDate: weekStartDate,
            weekEndDate: endDate,
            meals: [], // TODO: Load from plan_recipes
            totalCost: 85.50 // TODO: Calculate from recipes
        )
    }
}

// MARK: - Database Models

/// Data structure for inserting recipes into the database
private struct RecipeData: Encodable {
    let id: String
    let title: String
    let cookTime: String
    let servings: Int
    let imageName: String
    let ingredients: [Ingredient]
    let steps: [String]
    let substitutions: [String]
    let tags: [String]
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case cookTime = "cook_time"
        case servings
        case imageName = "image_name"
        case ingredients
        case steps
        case substitutions
        case tags
        case createdAt = "created_at"
    }
} 
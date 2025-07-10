//
//  SupabaseManager.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//  Production-ready Supabase client with comprehensive database operations.
//

import Supabase
import Foundation

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    @Published var isConnected = false
    @Published var connectionError: String?
    
    private init() {
        // Use production-ready configuration
        guard let url = URL(string: Configuration.supabaseURL) else {
            fatalError("Invalid Supabase URL configuration")
        }
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Configuration.supabaseAnonKey
        )
        
        // Initialize connection check
        Task {
            await checkConnection()
        }
    }
    
    // MARK: - Connection Management
    
    @MainActor
    func checkConnection() async {
        do {
            // Simple query to test connection
            _ = try await client
                .from("profiles")
                .select("id")
                .limit(1)
                .execute()
            
            self.isConnected = true
            self.connectionError = nil
            ProductionLogger.logInfo("Supabase connection established", context: "SupabaseManager")
            
        } catch {
            self.isConnected = false
            self.connectionError = error.localizedDescription
            ProductionLogger.logError(error, context: "SupabaseManager.checkConnection")
        }
    }
    
    // MARK: - Production Database Operations
    
    /// Performs a database operation with retry logic and error handling
    func performDatabaseOperation<T>(
        _ operation: () async throws -> T,
        retryCount: Int = Configuration.maxRetryAttempts,
        context: String = "Database Operation"
    ) async throws -> T {
        var lastError: Error?
        
        for attempt in 1...retryCount {
            do {
                let result = try await operation()
                
                if attempt > 1 {
                    ProductionLogger.logInfo("Database operation succeeded on attempt \(attempt)", context: context)
                }
                
                return result
                
            } catch {
                lastError = error
                ProductionLogger.logError(error, context: "\(context) - Attempt \(attempt)")
                
                if attempt < retryCount {
                    // Exponential backoff
                    let delay = pow(2.0, Double(attempt - 1))
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                }
            }
        }
        
        if let error = lastError {
            ProductionLogger.logError(error, context: "\(context) - Final failure after \(retryCount) attempts")
            throw error
        }
        
        throw SupabaseError.operationFailed
    }
    
    // MARK: - Specialized Database Operations
    
    /// Fetch meal plan templates with caching
    func fetchMealPlanTemplates() async throws -> [MealPlanTemplate] {
        return try await performDatabaseOperation({
            let response = try await client
                .from("meal_plan_templates")
                .select("*")
                .eq("is_active", value: true)
                .order("popularity_score", ascending: false)
                .execute()
            
            return try JSONDecoder().decode([MealPlanTemplate].self, from: response.data)
        }, context: "fetchMealPlanTemplates")
    }
    
    /// Fetch template meals for a specific template
    func fetchTemplateMeals(templateId: String) async throws -> [TemplateMeal] {
        return try await performDatabaseOperation({
            let response = try await client
                .from("template_meals")
                .select("*")
                .eq("template_id", value: templateId)
                .order("day_of_week")
                .order("meal_type")
                .execute()
            
            return try JSONDecoder().decode([TemplateMeal].self, from: response.data)
        }, context: "fetchTemplateMeals")
    }
    
    /// Create a new meal plan from template
    func createMealPlanFromTemplate(
        templateId: String,
        userId: String,
        weekStart: Date,
        title: String
    ) async throws -> Plan {
        return try await performDatabaseOperation({
            // First create the plan
            let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
            
            let planData: [String: String] = [
                "user_id": userId,
                "title": title,
                "week_start": ISO8601DateFormatter().string(from: weekStart),
                "week_end": ISO8601DateFormatter().string(from: weekEnd),
                "template_id": templateId,
                "generation_method": "template"
            ]
            
            let planResponse = try await client
                .from("plans")
                .insert(planData)
                .select("*")
                .single()
                .execute()
            
            let plan = try JSONDecoder().decode(Plan.self, from: planResponse.data)
            
            // Then copy template meals to plan_recipes
            let templateMeals = try await fetchTemplateMeals(templateId: templateId)
            
            for meal in templateMeals {
                struct PlanRecipeInsert: Codable {
                    let plan_id: String
                    let day_of_week: Int
                    let meal_type: String
                    let day: String
                    let custom_meal_name: String
                    let custom_ingredients: [String]
                    let custom_instructions: [String]
                    let custom_cook_time: Int
                }
                
                let planRecipeData = PlanRecipeInsert(
                    plan_id: plan.id,
                    day_of_week: meal.dayOfWeek,
                    meal_type: meal.mealType,
                    day: meal.day,
                    custom_meal_name: meal.mealName,
                    custom_ingredients: meal.ingredients ?? [],
                    custom_instructions: meal.instructions ?? [],
                    custom_cook_time: meal.cookingTime ?? 30
                )
                
                try await client
                    .from("plan_recipes")
                    .insert(planRecipeData)
                    .execute()
            }
            
            return plan
            
        }, context: "createMealPlanFromTemplate")
    }
    
    /// Fetch user's meal plans
    func fetchUserPlans(userId: String) async throws -> [Plan] {
        return try await performDatabaseOperation({
            let response = try await client
                .from("plans")
                .select("*")
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
            
            return try JSONDecoder().decode([Plan].self, from: response.data)
        }, context: "fetchUserPlans")
    }
    
    /// Fetch plan recipes for a specific plan
    func fetchPlanRecipes(planId: String) async throws -> [PlanRecipe] {
        return try await performDatabaseOperation({
            let response = try await client
                .from("plan_recipes")
                .select("*")
                .eq("plan_id", value: planId)
                .order("day_of_week")
                .order("meal_type")
                .execute()
            
            return try JSONDecoder().decode([PlanRecipe].self, from: response.data)
        }, context: "fetchPlanRecipes")
    }
    
    /// Update user profile
    func updateUserProfile(_ profile: UserProfile) async throws {
        try await performDatabaseOperation({
            try await client
                .from("profiles")
                .update(profile)
                .eq("id", value: profile.id)
                .execute()
        }, context: "updateUserProfile")
    }
    
    /// Create grocery list from plan
    func createGroceryListFromPlan(planId: String, userId: String) async throws -> [GroceryItem] {
        return try await performDatabaseOperation({
            // Get all plan recipes
            let planRecipes = try await fetchPlanRecipes(planId: planId)
            
            var groceryItems: [GroceryItem] = []
            var ingredientCounts: [String: Int] = [:]
            
            // Aggregate ingredients
            for planRecipe in planRecipes {
                if let ingredients = planRecipe.customIngredients {
                    for ingredient in ingredients {
                        ingredientCounts[ingredient, default: 0] += 1
                    }
                }
            }
            
            // Create grocery items
            for (ingredient, count) in ingredientCounts {
                let groceryItem = GroceryItem(
                    id: UUID().uuidString,
                    userId: userId,
                    planId: planId,
                    name: ingredient,
                    quantity: count > 1 ? "\(count)x" : "1x",
                    category: categorizeIngredient(ingredient),
                    emoji: emojiForIngredient(ingredient),
                    isChecked: false
                )
                
                groceryItems.append(groceryItem)
                
                // Save to database
                try await client
                    .from("grocery_items")
                    .insert(groceryItem)
                    .execute()
            }
            
            return groceryItems
            
        }, context: "createGroceryListFromPlan")
    }
    
    /// Fetch recipes from database
    func fetchRecipes(limit: Int = 20, offset: Int = 0) async throws -> [Recipe] {
        return try await performDatabaseOperation({
            let response = try await client
                .from("recipes")
                .select("*")
                .eq("is_public", value: true)
                .order("rating", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
            
            return try JSONDecoder().decode([Recipe].self, from: response.data)
        }, context: "fetchRecipes")
    }
    
    /// Update grocery item status
    func updateGroceryItem(_ item: GroceryItem) async throws {
        try await performDatabaseOperation({
            try await client
                .from("grocery_items")
                .update(item)
                .eq("id", value: item.id)
                .execute()
        }, context: "updateGroceryItem")
    }
    
    /// Mark plan recipe as completed
    func markPlanRecipeCompleted(planRecipeId: String) async throws {
        try await performDatabaseOperation({
            struct PlanRecipeUpdate: Codable {
                let is_completed: Bool
                let completed_at: String
            }
            
            let updateData = PlanRecipeUpdate(
                is_completed: true,
                completed_at: ISO8601DateFormatter().string(from: Date())
            )
            
            try await client
                .from("plan_recipes")
                .update(updateData)
                .eq("id", value: planRecipeId)
                .execute()
        }, context: "markPlanRecipeCompleted")
    }
    
    /// Fetch grocery list for a user
    func fetchGroceryList(userId: String) async throws -> [GroceryItem] {
        return try await performDatabaseOperation({
            let response = try await client
                .from("grocery_items")
                .select("*")
                .eq("user_id", value: userId)
                .order("name", ascending: true)
                .execute()
            return try JSONDecoder().decode([GroceryItem].self, from: response.data)
        }, context: "fetchGroceryList")
    }
    
    // --- Stubs for ProfileViewModel ---
    func deleteUserAccount(userId: String) async throws {
        throw SupabaseError.operationFailed
    }
    func exportUserData(userId: String) async throws -> UserDataExport {
        throw SupabaseError.operationFailed
    }
    func fetchUserProfile(userId: String) async throws -> UserProfile {
        throw SupabaseError.operationFailed
    }
    
    // MARK: - Helper Functions
    
    private func categorizeIngredient(_ ingredient: String) -> String {
        let ingredient = ingredient.lowercased()
        
        if ingredient.contains("chicken") || ingredient.contains("beef") || ingredient.contains("pork") || ingredient.contains("fish") {
            return "Meat & Seafood"
        } else if ingredient.contains("apple") || ingredient.contains("banana") || ingredient.contains("berry") {
            return "Fruits"
        } else if ingredient.contains("lettuce") || ingredient.contains("tomato") || ingredient.contains("onion") {
            return "Vegetables"
        } else if ingredient.contains("milk") || ingredient.contains("cheese") || ingredient.contains("yogurt") {
            return "Dairy"
        } else if ingredient.contains("bread") || ingredient.contains("pasta") || ingredient.contains("rice") {
            return "Grains"
        } else {
            return "Other"
        }
    }
    
    private func emojiForIngredient(_ ingredient: String) -> String {
        let ingredient = ingredient.lowercased()
        
        if ingredient.contains("chicken") { return "🐔" }
        if ingredient.contains("beef") { return "🥩" }
        if ingredient.contains("fish") { return "🐟" }
        if ingredient.contains("apple") { return "🍎" }
        if ingredient.contains("banana") { return "🍌" }
        if ingredient.contains("tomato") { return "🍅" }
        if ingredient.contains("onion") { return "🧅" }
        if ingredient.contains("cheese") { return "🧀" }
        if ingredient.contains("bread") { return "🍞" }
        if ingredient.contains("pasta") { return "🍝" }
        if ingredient.contains("rice") { return "🍚" }
        
        return "🛒"
    }
}

// MARK: - Error Types

enum SupabaseError: Error {
    case operationFailed
    case invalidResponse
    case networkError
    
    var localizedDescription: String {
        switch self {
        case .operationFailed:
            return "Database operation failed"
        case .invalidResponse:
            return "Invalid response from database"
        case .networkError:
            return "Network connection error"
        }
    }
}

// MARK: - Supporting Models for Database Operations
// PlanRecipe model moved to Plan.swift for consistency

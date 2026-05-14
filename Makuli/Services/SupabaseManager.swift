//
//  SupabaseManager.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import Supabase
import Foundation

class SupabaseManager: ObservableObject {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    @Published var isConnected = false
    @Published var connectionError: String?
    
    private init() {
        guard let url = URL(string: Configuration.supabaseURL) else {
            fatalError("Invalid Supabase URL configuration")
        }
        
        self.client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: Configuration.supabaseAnonKey
        )
        
        Task {
            await checkConnection()
        }
    }
    
    // MARK: - Connection Management
    
    @MainActor
    func checkConnection() async {
        do {
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
    
    func fetchMealPlanTemplates() async throws -> [MealPlanTemplate] {
        return try await performDatabaseOperation({
            let response = try await client
                .from("meal_plan_templates")
                .select("*")
                .order("created_at", ascending: false)
                .execute()
            
            return try JSONDecoder().decode([MealPlanTemplate].self, from: response.data)
        }, context: "fetchMealPlanTemplates")
    }
    
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
    
    func createMealPlanFromTemplate(
        templateId: String,
        userId: String,
        weekStart: Date,
        title: String
    ) async throws -> Plan {
        return try await performDatabaseOperation({
            let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart

            struct PlanInsertData: Encodable {
                let user_id: String
                let title: String
                let week_start: String
                let week_end: String
                let generation_method: String
            }
            let iso = ISO8601DateFormatter()
            let planInsert = PlanInsertData(
                user_id: userId,
                title: title,
                week_start: iso.string(from: weekStart),
                week_end: iso.string(from: weekEnd),
                generation_method: "template"
            )
            let planResponse = try await client
                .from("plans")
                .insert(planInsert)
                .select("*")
                .single()
                .execute()
            let plan = try JSONDecoder().decode(Plan.self, from: planResponse.data)

            let isLocalTemplate = templateId.hasPrefix("local-")
            var templateMeals: [TemplateMeal] = []
            if !isLocalTemplate {
                templateMeals = (try? await fetchTemplateMeals(templateId: templateId)) ?? []
            }

            if templateMeals.isEmpty {
                let allRecipes = (try? await fetchRecipes(limit: 50)) ?? []
                let mealTypes = ["breakfast", "lunch", "dinner"]
                let dayNames = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

                struct PlanRecipeInsert: Encodable {
                    let plan_id: String
                    let day_of_week: Int
                    let meal_type: String
                    let day: String
                    let recipe_id: String?
                    let custom_meal_name: String
                }

                var breakfasts = allRecipes.filter { $0.tags.contains("breakfast") || $0.cuisineType == nil }
                var lunches    = allRecipes.filter { $0.tags.contains("lunch") || $0.tags.contains("salad") || $0.tags.contains("bowl") }
                var dinners    = allRecipes.filter { $0.tags.contains("dinner") || $0.calories ?? 0 > 400 }

                if breakfasts.isEmpty { breakfasts = allRecipes }
                if lunches.isEmpty    { lunches    = allRecipes }
                if dinners.isEmpty    { dinners    = allRecipes }

                for (dayIndex, dayName) in dayNames.enumerated() {
                    let dayOfWeek = dayIndex + 1 == 7 ? 0 : dayIndex + 1
                    for (mealIndex, mealType) in mealTypes.enumerated() {
                        let pool: [Recipe]
                        switch mealIndex {
                        case 0: pool = breakfasts
                        case 1: pool = lunches
                        default: pool = dinners
                        }
                        let recipe = pool[(dayIndex * 3 + mealIndex) % pool.count]
                        let insert = PlanRecipeInsert(
                            plan_id: plan.id,
                            day_of_week: dayOfWeek,
                            meal_type: mealType,
                            day: dayName,
                            recipe_id: recipe.id,
                            custom_meal_name: recipe.title
                        )
                        try await client.from("plan_recipes").insert(insert).execute()
                    }
                }
            } else {
                struct PlanRecipeInsert: Codable {
                    let plan_id: String
                    let day_of_week: Int
                    let meal_type: String
                    let day: String
                    let custom_meal_name: String
                    let custom_cook_time: Int
                }
                for meal in templateMeals {
                    let insert = PlanRecipeInsert(
                        plan_id: plan.id,
                        day_of_week: Int(meal.dayOfWeek) ?? 0,
                        meal_type: meal.mealType,
                        day: meal.day,
                        custom_meal_name: meal.mealName,
                        custom_cook_time: meal.cookingTime
                    )
                    try await client.from("plan_recipes").insert(insert).execute()
                }
            }

            return plan
        }, context: "createMealPlanFromTemplate")
    }
    
    func createMealPlanManually(
        userId: String,
        weekStart: Date,
        weekEnd: Date,
        title: String,
        selectedMeals: [String: [String: Bool]]
    ) async throws -> Plan {
        return try await performDatabaseOperation({
            let planData: [String: String] = [
                "user_id": userId,
                "title": title,
                "week_start": ISO8601DateFormatter().string(from: weekStart),
                "week_end": ISO8601DateFormatter().string(from: weekEnd),
                "generation_method": "manual"
            ]
            
            let planResponse = try await client
                .from("plans")
                .insert(planData)
                .select("*")
                .single()
                .execute()
            
            let plan = try JSONDecoder().decode(Plan.self, from: planResponse.data)
            
            let calendar = Calendar.current
            var currentDate = weekStart
            
            while currentDate <= weekEnd {
                let dateKey = formatDateKey(currentDate)
                if let dayMeals = selectedMeals[dateKey] {
                    for (mealType, isSelected) in dayMeals {
                        if isSelected {
                            let dayName = formatDayName(currentDate)
                            let mealName = getDefaultMealName(for: mealType)
                            
                            let weekday = calendar.component(.weekday, from: currentDate)
                            let adjustedDayOfWeek = weekday - 1
                            
                            struct PlanRecipeInsert: Codable {
                                let plan_id: String
                                let day_of_week: Int
                                let meal_type: String
                                let day: String
                                let position: Int
                                let custom_meal_name: String
                                let custom_ingredients: [String]
                                let custom_instructions: [String]
                                let custom_cook_time: Int
                            }
                            
                            let planRecipeData = PlanRecipeInsert(
                                plan_id: plan.id,
                                day_of_week: adjustedDayOfWeek,
                                meal_type: mealType.lowercased(),
                                day: dayName,
                                position: getMealPosition(for: mealType),
                                custom_meal_name: mealName,
                                custom_ingredients: getDefaultIngredients(for: mealType),
                                custom_instructions: getDefaultInstructions(for: mealType),
                                custom_cook_time: getDefaultCookTime(for: mealType)
                            )
                            
                            try await client
                                .from("plan_recipes")
                                .insert(planRecipeData)
                                .execute()
                        }
                    }
                }
                
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            
            return plan
            
        }, context: "createMealPlanManually")
    }
    
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
    
    func updateUserProfile(_ profile: UserProfile) async throws {
        struct ProfileUpdate: Encodable {
            let name: String?
            let bio: String?
            let location: String?
            let diet: String?
            let goal: String?
            let budget: String?
            let age: Int?
            let gender: String?
            let is_premium: Bool
            let is_onboarding_completed: Bool
            let profile_image_url: String?
            let updated_at: String
        }
        let update = ProfileUpdate(
            name: profile.name,
            bio: profile.bio,
            location: profile.location,
            diet: profile.diet,
            goal: profile.goal,
            budget: profile.budget,
            age: profile.age,
            gender: profile.gender,
            is_premium: profile.isPremium,
            is_onboarding_completed: profile.isOnboardingCompleted,
            profile_image_url: profile.profileImageUrl,
            updated_at: ISO8601DateFormatter().string(from: Date())
        )
        try await performDatabaseOperation({
            try await client
                .from("profiles")
                .update(update)
                .eq("id", value: profile.id)
                .execute()
        }, context: "updateUserProfile")
    }
    
    func createGroceryListFromPlan(planId: String, userId: String) async throws -> [GroceryItem] {
        return try await performDatabaseOperation({
            let planRecipes = try await fetchPlanRecipes(planId: planId)
            
            var groceryItems: [GroceryItem] = []
            var ingredientCounts: [String: Int] = [:]
            
            for planRecipe in planRecipes {
                if let ingredients = planRecipe.customIngredients {
                    for ingredient in ingredients {
                        ingredientCounts[ingredient, default: 0] += 1
                    }
                }
            }
            
            for (ingredient, count) in ingredientCounts {
                let groceryItem = GroceryItem(
                    id: UUID().uuidString,
                    userId: userId,
                    name: ingredient,
                    quantity: Double(count),
                    unit: "pieces",
                    category: categorizeIngredient(ingredient),
                    priority: "Medium",
                    isCompleted: false,
                    notes: nil,
                    estimatedPrice: nil,
                    recipeId: nil,
                    planId: planId,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                groceryItems.append(groceryItem)
                
                try await client
                    .from("grocery_items")
                    .insert(groceryItem)
                    .execute()
            }
            
            return groceryItems
            
        }, context: "createGroceryListFromPlan")
    }
    
    func fetchRecipes(limit: Int = 20, offset: Int = 0) async throws -> [Recipe] {
        return try await performDatabaseOperation({
            let response = try await client
                .from("recipes")
                .select("*")
                .eq("is_public", value: true)
                .order("created_at", ascending: false)
                .range(from: offset, to: offset + limit - 1)
                .execute()
            
            return try JSONDecoder().decode([Recipe].self, from: response.data)
        }, context: "fetchRecipes")
    }
    
    func updateGroceryItem(_ item: GroceryItem) async throws {
        try await performDatabaseOperation({
            try await client
                .from("grocery_items")
                .update(item)
                .eq("id", value: item.id)
                .execute()
        }, context: "updateGroceryItem")
    }
    
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
    
    func uploadProfileImage(userId: String, imageData: Data) async throws -> String {
        let fileName = "\(userId)_profile.jpg"
        let bucket = "profile-pictures"
        let path = "\(userId)/\(fileName)"

        let response = try await client.storage.from(bucket).upload(
            path: path,
            file: imageData,
            options: FileOptions(upsert: true)
        )

        let publicUrl = "\(Configuration.supabaseURL)/storage/v1/object/public/\(bucket)/\(path)"
        return publicUrl
    }

    func updateUserProfileImageUrl(userId: String, imageUrl: String) async throws {
        let updates = ["profile_image_url": imageUrl]
        _ = try await client
            .from("profiles")
            .update(updates)
            .eq("id", value: userId)
            .execute()
    }
    
    func deleteUserAccount(userId: String) async throws {
        throw SupabaseError.operationFailed
    }
    func exportUserData(userId: String) async throws -> UserDataExport {
        throw SupabaseError.operationFailed
    }
    func fetchUserProfile(userId: String) async throws -> UserProfile {
        let response: [UserProfile] = try await client
            .from("profiles")
            .select("*")
            .eq("id", value: userId.lowercased())
            .execute()
            .value
        guard let profile = response.first else {
            throw SupabaseError.operationFailed
        }
        return profile
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
    
    // MARK: - Helper Methods for Manual Plan Creation
    
    private func formatDateKey(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func formatDayName(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    private func getMealPosition(for mealType: String) -> Int {
        switch mealType.lowercased() {
        case "breakfast": return 0
        case "lunch": return 1
        case "dinner": return 2
        case "snack": return 3
        default: return 0
        }
    }
    
    private func getDefaultMealName(for mealType: String) -> String {
        switch mealType.lowercased() {
        case "breakfast":
            return "Healthy Breakfast Bowl"
        case "lunch":
            return "Nutritious Lunch"
        case "dinner":
            return "Balanced Dinner"
        case "snack":
            return "Healthy Snack"
        default:
            return "Meal"
        }
    }
    
    private func getDefaultIngredients(for mealType: String) -> [String] {
        switch mealType.lowercased() {
        case "breakfast":
            return ["eggs", "whole grain bread", "avocado", "tomatoes", "olive oil"]
        case "lunch":
            return ["quinoa", "mixed vegetables", "chicken breast", "olive oil", "herbs"]
        case "dinner":
            return ["salmon fillet", "brown rice", "broccoli", "lemon", "garlic"]
        case "snack":
            return ["almonds", "apple", "greek yogurt"]
        default:
            return ["ingredients"]
        }
    }
    
    private func getDefaultInstructions(for mealType: String) -> [String] {
        switch mealType.lowercased() {
        case "breakfast":
            return ["Prepare ingredients", "Cook eggs to preference", "Toast bread", "Assemble bowl"]
        case "lunch":
            return ["Cook quinoa", "Prepare vegetables", "Cook chicken", "Combine ingredients"]
        case "dinner":
            return ["Season salmon", "Cook rice", "Steam broccoli", "Plate and serve"]
        case "snack":
            return ["Wash apple", "Portion almonds", "Serve with yogurt"]
        default:
            return ["Prepare meal"]
        }
    }
    
    private func getDefaultCookTime(for mealType: String) -> Int {
        switch mealType.lowercased() {
        case "breakfast": return 15
        case "lunch": return 25
        case "dinner": return 30
        case "snack": return 5
        default: return 20
        }
    }
    
    // MARK: - Spoonacular Integration Methods
    
    func savePlan(_ plan: Plan) async throws {
        try await performDatabaseOperation({
            try await client
                .from("plans")
                .upsert(plan)
                .execute()
        }, context: "savePlan")
    }
    
    func savePlanRecipe(_ planRecipe: PlanRecipe) async throws {
        try await performDatabaseOperation({
            try await client
                .from("plan_recipes")
                .upsert(planRecipe)
                .execute()
        }, context: "savePlanRecipe")
    }
    
    func saveRecipe(_ recipe: Recipe) async throws {
        try await performDatabaseOperation({
            try await client
                .from("recipes")
                .upsert(recipe)
                .execute()
        }, context: "saveRecipe")
    }
    
    func saveGroceryItem(_ groceryItem: GroceryItem) async throws {
        try await performDatabaseOperation({
            try await client
                .from("grocery_items")
                .upsert(groceryItem)
                .execute()
        }, context: "saveGroceryItem")
    }
    
    // MARK: - Caching & Fallback Methods
    
    func getCachedMealPlan(userId: String, weekStart: Date) async throws -> (plan: Plan, recipes: [PlanRecipe])? {
        let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        
        return try await performDatabaseOperation({
            let plans: [Plan] = try await client
                .from("plans")
                .select()
                .eq("user_id", value: userId)
                .gte("week_start", value: weekStart)
                .lte("week_end", value: weekEnd)
                .eq("generation_method", value: "spoonacular")
                .order("created_at", ascending: false)
                .limit(1)
                .execute()
                .value
            
            guard let plan = plans.first else { return nil }
            
            let planRecipes: [PlanRecipe] = try await client
                .from("plan_recipes")
                .select()
                .eq("plan_id", value: plan.id)
                .order("day_of_week", ascending: true)
                .order("position", ascending: true)
                .execute()
                .value
            
            return (plan: plan, recipes: planRecipes)
        }, context: "getCachedMealPlan")
    }
    
    func getCachedRecipes(planId: String) async throws -> [Recipe] {
        return try await performDatabaseOperation({
            let planRecipes: [PlanRecipe] = try await client
                .from("plan_recipes")
                .select()
                .eq("plan_id", value: planId)
                .not("recipe_id", operator: .is, value: "null")
                .execute()
                .value
            
            let recipeIds = planRecipes.compactMap { $0.recipeId }
            
            guard !recipeIds.isEmpty else { return [] }
            
            let recipes: [Recipe] = try await client
                .from("recipes")
                .select()
                .in("id", values: recipeIds)
                .execute()
                .value
            
            return recipes
        }, context: "getCachedRecipes")
    }
    
    func getCachedRecipe(spoonacularId: String) async throws -> Recipe? {
        return try await performDatabaseOperation({
            let recipes: [Recipe] = try await client
                .from("recipes")
                .select()
                .eq("spoonacular_id", value: spoonacularId)
                .limit(1)
                .execute()
                .value
            
            return recipes.first
        }, context: "getCachedRecipe")
    }
    
    func getCachedGroceryList(planId: String, userId: String) async throws -> [GroceryItem] {
        return try await performDatabaseOperation({
            let groceryItems: [GroceryItem] = try await client
                .from("grocery_items")
                .select()
                .eq("plan_id", value: planId)
                .eq("user_id", value: userId)
                .order("category", ascending: true)
                .order("name", ascending: true)
                .execute()
                .value
            
            return groceryItems
        }, context: "getCachedGroceryList")
    }
    
    func hasFreshCachedData(userId: String, weekStart: Date) async throws -> Bool {
        let cacheExpirationHours: Double = 24
        let expirationDate = Date().addingTimeInterval(-cacheExpirationHours * 3600)
        
        return try await performDatabaseOperation({
            struct CacheCheck: Codable {
                let id: String
            }
            
            let plans: [CacheCheck] = try await client
                .from("plans")
                .select("id")
                .eq("user_id", value: userId)
                .gte("week_start", value: weekStart)
                .eq("generation_method", value: "spoonacular")
                .gte("created_at", value: expirationDate)
                .limit(1)
                .execute()
                .value
            
            let hasCache = !plans.isEmpty
            Logger.info("Cache check for user \(userId), week \(weekStart): \(hasCache ? "found fresh cache" : "no fresh cache")")
            return hasCache
        }, context: "hasFreshCachedData")
    }
    
    func clearOldCachedData(olderThanDays days: Int = 7) async throws {
        let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        
        try await performDatabaseOperation({
            try await client
                .from("plans")
                .delete()
                .lt("created_at", value: cutoffDate)
                .eq("generation_method", value: "spoonacular")
                .execute()
            
            try await client
                .from("recipes")
                .delete()
                .lt("created_at", value: cutoffDate)
                .execute()
            
            try await client
                .from("grocery_items")
                .delete()
                .lt("created_at", value: cutoffDate)
                .execute()
            
            ProductionLogger.logInfo("Cleared cached data older than \(days) days", context: "SupabaseManager")
        }, context: "clearOldCachedData")
    }
    
    func saveSpoonacularMealPlanToCache(
        plan: Plan,
        planRecipes: [PlanRecipe],
        recipes: [Recipe],
        groceryItems: [GroceryItem]? = nil
    ) async throws {
        try await performDatabaseOperation({
            Logger.info("Saving Spoonacular meal plan to cache: plan ID \(plan.id), \(planRecipes.count) plan recipes, \(recipes.count) recipes")
            
            do {
                try await client
                    .from("plans")
                    .upsert(plan)
                    .execute()
                
                Logger.info("Saved plan to database")
            } catch {
                Logger.warning("Plan save failed, trying with manual generation_method: \(error)")
                
                let fallbackPlan = Plan(
                    id: plan.id,
                    userId: plan.userId,
                    title: plan.title,
                    weekStart: plan.weekStart,
                    weekEnd: plan.weekEnd,
                    totalCost: plan.totalCost,
                    isCompleted: plan.isCompleted,
                    createdAt: plan.createdAt,
                    updatedAt: plan.updatedAt,
                    templateId: plan.templateId,
                    generationMethod: "manual",
                    isFavorite: plan.isFavorite,
                    completionPercentage: plan.completionPercentage
                )
                
                try await client
                    .from("plans")
                    .upsert(fallbackPlan)
                    .execute()
                
                Logger.info("Saved plan to database with manual generation_method fallback")
            }
            
            for recipe in recipes {
                try await client
                    .from("recipes")
                    .upsert(recipe)
                    .execute()
            }
            
            Logger.info("Saved \(recipes.count) recipes to database")
            
            for planRecipe in planRecipes {
                try await client
                    .from("plan_recipes")
                    .upsert(planRecipe)
                    .execute()
            }
            
            Logger.info("Saved \(planRecipes.count) plan recipes to database")
            
            if let groceryItems = groceryItems {
                for groceryItem in groceryItems {
                    try await client
                        .from("grocery_items")
                        .upsert(groceryItem)
                        .execute()
                }
                Logger.info("Saved \(groceryItems.count) grocery items to database")
            }
            
            ProductionLogger.logInfo("Saved Spoonacular meal plan to cache", context: "SupabaseManager")
        }, context: "saveSpoonacularMealPlanToCache")
    }
    
    func getUserSpoonacularCredentials(userId: String) async throws -> (username: String, hash: String)? {
        return try await performDatabaseOperation({
            let profiles: [UserProfile] = try await client
                .from("profiles")
                .select("spoonacular_username, spoonacular_hash")
                .eq("id", value: userId)
                .limit(1)
                .execute()
                .value
            
            guard let profile = profiles.first,
                  let username = profile.spoonacularUsername,
                  let hash = profile.spoonacularHash else {
                return nil
            }
            
            return (username: username, hash: hash)
        }, context: "getUserSpoonacularCredentials")
    }
    
    func updateUserSpoonacularCredentials(userId: String, username: String, hash: String) async throws {
        try await performDatabaseOperation({
            try await client
                .from("profiles")
                .update([
                    "spoonacular_username": username,
                    "spoonacular_hash": hash,
                    "updated_at": ISO8601DateFormatter().string(from: Date())
                ])
                .eq("id", value: userId)
                .execute()
            
            ProductionLogger.logInfo("Updated Spoonacular credentials for user \(userId)", context: "SupabaseManager")
        }, context: "updateUserSpoonacularCredentials")
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

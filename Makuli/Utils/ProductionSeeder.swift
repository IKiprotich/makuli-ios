//
//  ProductionSeeder.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production database seeder for Supabase.
//

import Foundation

@MainActor
class ProductionSeeder {
    
    private static let supabase = SupabaseManager.shared.client
    
    // MARK: - Main Seeding Functions
    
    /// Seeds the production database with all templates and recipes
    static func seedProductionDatabase() async throws {
        ProductionLogger.logInfo("Starting production database seeding", context: "ProductionSeeder")
        
        do {
            // 1. Clear existing template data if needed
            if Configuration.isProduction {
                ProductionLogger.logInfo("Clearing existing templates in production")
                try await clearExistingTemplates()
            }
            
            // 2. Seed all recipes
            try await seedAllRecipes()
            
            // 3. Seed meal plan templates
            try await seedAllMealPlanTemplates()
            
            // 4. Verify seeded data
            try await verifySeededData()
            
            ProductionLogger.logInfo("Production database seeding completed successfully", context: "ProductionSeeder")
            
        } catch {
            ProductionLogger.logError(error, context: "ProductionSeeder.seedProductionDatabase")
            throw error
        }
    }
    
    /// Quick seed for development and testing
    static func quickSeed() async throws {
        try await seedProductionDatabase()
    }
    
    // MARK: - Recipe Seeding
    
    private static func seedAllRecipes() async throws {
        ProductionLogger.logInfo("Seeding recipes database", context: "ProductionSeeder")
        
        // Get current authenticated user's ID for RLS compliance
        let session = try await supabase.auth.session
        let currentUserId = session.user.id.uuidString
        
        let recipeData = getAllProductionRecipes()
        
        for recipe in recipeData {
            do {
                // Convert to CreateRecipeRequest for proper Encodable compliance
                let createRequest = CreateRecipeRequest(
                    title: recipe["title"] as? String ?? "",
                    cookTime: recipe["cook_time"] as? String,
                    prepTime: recipe["prep_time"] as? Int,
                    servings: recipe["servings"] as? Int,
                    calories: recipe["calories"] as? Int,
                    imageUrl: recipe["image_url"] as? String,
                    ingredients: recipe["ingredients"] as? [String] ?? [],
                    steps: recipe["steps"] as? [String] ?? [],
                    substitutions: recipe["substitutions"] as? [String] ?? [],
                    tags: recipe["tags"] as? [String] ?? [],
                    difficulty: recipe["difficulty"] as? String,
                    cuisineType: recipe["cuisine_type"] as? String,
                    costEstimate: recipe["cost_estimate"] as? Double,
                    isPublic: recipe["is_public"] as? Bool ?? true,
                    createdBy: currentUserId
                )
                
                try await supabase
                    .from("recipes")
                    .insert(createRequest)
                    .execute()
                
                ProductionLogger.logInfo("Seeded recipe: \(recipe["title"] ?? "Unknown")")
                
            } catch {
                ProductionLogger.logError(error, context: "Seeding recipe: \(recipe["title"] ?? "Unknown")")
                // Continue with other recipes even if one fails
            }
        }
        
        ProductionLogger.logInfo("Completed seeding \(recipeData.count) recipes")
    }
    
    // MARK: - Template Seeding
    
    private static func seedAllMealPlanTemplates() async throws {
        ProductionLogger.logInfo("Seeding meal plan templates", context: "ProductionSeeder")
        
        // Get current authenticated user's ID for RLS compliance
        let session = try await supabase.auth.session
        let currentUserId = session.user.id.uuidString
        
        let templates = getAllProductionTemplates()
        
        for template in templates {
            do {
                // Insert template
                let createTemplateRequest = CreateMealPlanTemplateRequest(
                    name: template.name,
                    description: template.description,
                    category: template.category,
                    difficulty: template.difficulty,
                    durationDays: 7,
                    estimatedCostMin: template.estimatedCostMin,
                    estimatedCostMax: template.estimatedCostMax,
                    imageUrl: nil,
                    tags: template.tags,
                    isActive: true,
                    icon: template.icon,
                    colorScheme: nil,
                    targetCaloriesPerDay: nil,
                    macros: nil,
                    createdBy: currentUserId
                )
                
                let templateData = try await supabase
                    .from("meal_plan_templates")
                    .insert(createTemplateRequest)
                    .select("id")
                    .single()
                    .execute()
                
                guard let templateId = extractId(from: templateData) else {
                    throw ProductionSeederError.templateCreationFailed(template.name)
                }
                
                // Insert template meals
                let meals = getTemplateMeals(for: template)
                for meal in meals {
                    let createMealRequest = CreateTemplateMealRequest(
                        templateId: templateId,
                        dayOfWeek: meal["day_of_week"] as? Int ?? 0,
                        mealType: meal["meal_type"] as? String ?? "",
                        mealName: meal["meal_name"] as? String ?? "",
                        recipeId: meal["recipe_id"] as? String,
                        cookingTime: meal["cooking_time"] as? Int,
                        difficulty: meal["difficulty"] as? String,
                        position: meal["position"] as? Int ?? 0,
                        day: meal["day"] as? String ?? "",
                        estimatedCost: meal["estimated_cost"] as? Double,
                        calories: meal["calories"] as? Int,
                        prepTime: meal["prep_time"] as? Int,
                        ingredients: meal["ingredients"] as? [String],
                        instructions: meal["instructions"] as? [String]
                    )
                    
                    try await supabase
                        .from("template_meals")
                        .insert(createMealRequest)
                        .execute()
                }
                
                ProductionLogger.logInfo("Seeded template: \(template.name) with \(meals.count) meals")
                
            } catch {
                ProductionLogger.logError(error, context: "Seeding template: \(template.name)")
                throw error
            }
        }
        
        ProductionLogger.logInfo("Completed seeding \(templates.count) meal plan templates")
    }
    
    // MARK: - Data Verification
    
    private static func verifySeededData() async throws {
        ProductionLogger.logInfo("Verifying seeded data", context: "ProductionSeeder")
        
        // Verify templates
        let templatesResponse = try await supabase
            .from("meal_plan_templates")
            .select("id, name")
            .execute()
        
        let templateCount = try extractCount(from: templatesResponse)
        ProductionLogger.logInfo("Verified \(templateCount) templates in database")
        
        // Verify template meals
        let mealsResponse = try await supabase
            .from("template_meals")
            .select("id")
            .execute()
        
        let mealCount = try extractCount(from: mealsResponse)
        ProductionLogger.logInfo("Verified \(mealCount) template meals in database")
        
        // Verify recipes
        let recipesResponse = try await supabase
            .from("recipes")
            .select("id")
            .execute()
        
        let recipeCount = try extractCount(from: recipesResponse)
        ProductionLogger.logInfo("Verified \(recipeCount) recipes in database")
        
        if templateCount < 10 || mealCount < 200 || recipeCount < 50 {
            throw ProductionSeederError.verificationFailed("Insufficient data seeded")
        }
        
        ProductionLogger.logInfo("Data verification completed successfully")
    }
    
    // MARK: - Cleanup Functions
    
    private static func clearExistingTemplates() async throws {
        // Delete template meals first (due to foreign key constraints)
        try await supabase
            .from("template_meals")
            .delete()
            .neq("template_id", value: "00000000-0000-0000-0000-000000000000") // Delete all
            .execute()
        
        // Delete templates
        try await supabase
            .from("meal_plan_templates")
            .delete()
            .neq("id", value: "00000000-0000-0000-0000-000000000000") // Delete all
            .execute()
        
        ProductionLogger.logInfo("Cleared existing templates from database")
    }
    
    // MARK: - Helper Functions
    
    private static func extractId(from response: Any) -> String? {
        // Extract ID from Supabase response
        if let data = response as? [String: Any],
           let id = data["id"] as? String {
            return id
        }
        // Try alternative response format
        if let dataArray = response as? [[String: Any]],
           let firstItem = dataArray.first,
           let id = firstItem["id"] as? String {
            return id
        }
        return nil
    }
    
    private static func extractCount(from response: Any) -> Int {
        // Extract count from Supabase response
        if let dataArray = response as? [[String: Any]] {
            return dataArray.count
        }
        return 0
    }
    
    // MARK: - Production Data
    
    private static func getAllProductionTemplates() -> [ProductionTemplate] {
        return [
            ProductionTemplate(
                name: "Mediterranean Week",
                description: "Fresh, healthy Mediterranean cuisine with olive oil, fish, and vegetables",
                category: "mediterranean",
                difficulty: "intermediate",
                estimatedCostMin: 75.0,
                estimatedCostMax: 100.0,
                icon: "🫒",
                tags: ["healthy", "fish", "vegetables", "olive oil"]
            ),
            ProductionTemplate(
                name: "Budget-Friendly Week",
                description: "Delicious meals on a budget using affordable ingredients",
                category: "budget",
                difficulty: "beginner",
                estimatedCostMin: 35.0,
                estimatedCostMax: 50.0,
                icon: "💰",
                tags: ["budget", "affordable", "simple"]
            ),
            ProductionTemplate(
                name: "Quick & Easy Week",
                description: "Fast meals for busy lifestyles, most under 30 minutes",
                category: "quick",
                difficulty: "beginner",
                estimatedCostMin: 60.0,
                estimatedCostMax: 80.0,
                icon: "⚡",
                tags: ["quick", "easy", "30min"]
            ),
            ProductionTemplate(
                name: "Healthy & Balanced Week",
                description: "Nutritionally balanced meals with proper portions and variety",
                category: "healthy",
                difficulty: "intermediate",
                estimatedCostMin: 85.0,
                estimatedCostMax: 110.0,
                icon: "🥗",
                tags: ["healthy", "balanced", "nutrition"]
            ),
            ProductionTemplate(
                name: "Asian Fusion Week",
                description: "Authentic Asian flavors with modern twists",
                category: "asian",
                difficulty: "intermediate",
                estimatedCostMin: 70.0,
                estimatedCostMax: 95.0,
                icon: "🥢",
                tags: ["asian", "fusion", "authentic"]
            ),
            ProductionTemplate(
                name: "Mexican Fiesta Week",
                description: "Vibrant Mexican cuisine with bold flavors and spices",
                category: "mexican",
                difficulty: "beginner",
                estimatedCostMin: 55.0,
                estimatedCostMax: 75.0,
                icon: "🌮",
                tags: ["mexican", "spicy", "colorful"]
            ),
            ProductionTemplate(
                name: "Italian Classics Week",
                description: "Traditional Italian dishes with authentic ingredients",
                category: "italian",
                difficulty: "intermediate",
                estimatedCostMin: 80.0,
                estimatedCostMax: 120.0,
                icon: "🍝",
                tags: ["italian", "classic", "pasta"]
            ),
            ProductionTemplate(
                name: "Ultimate Comfort Food",
                description: "Hearty, soul-warming dishes perfect for cozy nights",
                category: "comfort",
                difficulty: "beginner",
                estimatedCostMin: 65.0,
                estimatedCostMax: 85.0,
                icon: "🍲",
                tags: ["comfort", "hearty", "warming"]
            ),
            ProductionTemplate(
                name: "High-Protein Fitness Week",
                description: "Protein-rich meals designed for fitness enthusiasts",
                category: "fitness",
                difficulty: "intermediate",
                estimatedCostMin: 90.0,
                estimatedCostMax: 130.0,
                icon: "💪",
                tags: ["protein", "fitness", "muscle"]
            ),
            ProductionTemplate(
                name: "Plant-Powered Vegetarian",
                description: "Delicious vegetarian meals packed with plant-based nutrition",
                category: "vegetarian",
                difficulty: "intermediate",
                estimatedCostMin: 60.0,
                estimatedCostMax: 80.0,
                icon: "🥬",
                tags: ["vegetarian", "plant-based", "green"]
            ),
            ProductionTemplate(
                name: "Family-Style Favorites",
                description: "Kid-friendly meals that the whole family will love",
                category: "family",
                difficulty: "beginner",
                estimatedCostMin: 70.0,
                estimatedCostMax: 100.0,
                icon: "👨‍👩‍👧‍👦",
                tags: ["family", "kid-friendly", "crowd-pleasing"]
            ),
            ProductionTemplate(
                name: "Ketogenic Lifestyle",
                description: "Low-carb, high-fat meals for the keto lifestyle",
                category: "keto",
                difficulty: "intermediate",
                estimatedCostMin: 85.0,
                estimatedCostMax: 115.0,
                icon: "🥑",
                tags: ["keto", "low-carb", "high-fat"]
            ),
            ProductionTemplate(
                name: "Meal Prep Master",
                description: "Batch-cookable meals perfect for weekly meal prep",
                category: "meal-prep",
                difficulty: "intermediate",
                estimatedCostMin: 65.0,
                estimatedCostMax: 90.0,
                icon: "📦",
                tags: ["meal-prep", "batch-cooking", "efficient"]
            ),
            ProductionTemplate(
                name: "Around the World",
                description: "A culinary journey featuring dishes from different countries",
                category: "international",
                difficulty: "advanced",
                estimatedCostMin: 95.0,
                estimatedCostMax: 140.0,
                icon: "🌍",
                tags: ["international", "diverse", "gourmet"]
            )
        ]
    }
    
    private static func getTemplateMeals(for template: ProductionTemplate) -> [[String: Any]] {
        // This would return the meals for each template
        // For brevity, returning a sample structure
        // In production, this would contain all 294 meals (21 meals × 14 templates)
        
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var meals: [[String: Any]] = []
        var position = 0
        
        for (dayIndex, day) in days.enumerated() {
            // Breakfast
            meals.append([
                "day_of_week": dayIndex,
                "meal_type": "breakfast",
                "meal_name": "\(template.category.capitalized) Breakfast \(dayIndex + 1)",
                "day": day,
                "cooking_time": 15,
                "difficulty": "easy",
                "estimated_cost": 8.0,
                "calories": 350,
                "prep_time": 10,
                "position": position,
                "ingredients": ["ingredient1", "ingredient2", "ingredient3"],
                "instructions": ["Step 1", "Step 2", "Step 3"]
            ])
            position += 1
            
            // Lunch
            meals.append([
                "day_of_week": dayIndex,
                "meal_type": "lunch",
                "meal_name": "\(template.category.capitalized) Lunch \(dayIndex + 1)",
                "day": day,
                "cooking_time": 25,
                "difficulty": "medium",
                "estimated_cost": 12.0,
                "calories": 450,
                "prep_time": 15,
                "position": position,
                "ingredients": ["ingredient1", "ingredient2", "ingredient3"],
                "instructions": ["Step 1", "Step 2", "Step 3"]
            ])
            position += 1
            
            // Dinner
            meals.append([
                "day_of_week": dayIndex,
                "meal_type": "dinner",
                "meal_name": "\(template.category.capitalized) Dinner \(dayIndex + 1)",
                "day": day,
                "cooking_time": 35,
                "difficulty": template.difficulty,
                "estimated_cost": 18.0,
                "calories": 550,
                "prep_time": 20,
                "position": position,
                "ingredients": ["ingredient1", "ingredient2", "ingredient3"],
                "instructions": ["Step 1", "Step 2", "Step 3"]
            ])
            position += 1
        }
        
        return meals
    }
    
    private static func getAllProductionRecipes() -> [[String: Any]] {
        // Sample recipes for production
        return [
            [
                "title": "Mediterranean Grilled Salmon",
                "cook_time": "20 minutes",
                "prep_time": 15,
                "servings": 4,
                "calories": 380,
                "ingredients": ["salmon fillets", "olive oil", "lemon", "herbs"],
                "steps": ["Season salmon", "Grill 6-8 minutes per side", "Serve with lemon"],
                "difficulty": "medium",
                "cuisine_type": "mediterranean",
                "cost_estimate": 18.50,
                "is_public": true,
                "tags": ["healthy", "fish", "mediterranean"]
            ],
            [
                "title": "Quick Chicken Stir Fry",
                "cook_time": "15 minutes",
                "prep_time": 10,
                "servings": 3,
                "calories": 320,
                "ingredients": ["chicken breast", "mixed vegetables", "soy sauce", "garlic"],
                "steps": ["Cut chicken into strips", "Stir fry with vegetables", "Add sauce"],
                "difficulty": "easy",
                "cuisine_type": "asian",
                "cost_estimate": 12.00,
                "is_public": true,
                "tags": ["quick", "healthy", "asian"]
            ],
            // Add more recipes as needed...
        ]
    }
}

// MARK: - Supporting Types

struct ProductionTemplate {
    let name: String
    let description: String
    let category: String
    let difficulty: String
    let estimatedCostMin: Double
    let estimatedCostMax: Double
    let icon: String
    let tags: [String]
}

enum ProductionSeederError: Error {
    case templateCreationFailed(String)
    case verificationFailed(String)
    case databaseConnectionFailed
    
    var localizedDescription: String {
        switch self {
        case .templateCreationFailed(let templateName):
            return "Failed to create template: \(templateName)"
        case .verificationFailed(let reason):
            return "Data verification failed: \(reason)"
        case .databaseConnectionFailed:
            return "Unable to connect to database"
        }
    }
} 
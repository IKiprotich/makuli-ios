//
//  SpoonacularMapper.swift
//  Makuli
//
//  Created by ian on 2025-08-05.
//
//  Clean, efficient utility for mapping Spoonacular API responses to app models.
//  This class handles all data transformation between Spoonacular and the app's
//  existing data structures.
//

import Foundation

/// Utility class for mapping Spoonacular API responses to app models.
/// This provides clean, efficient data transformation with proper error handling.
struct SpoonacularMapper {
    
    // MARK: - Meal Plan Mapping
    
    /// Maps a SpoonacularMealPlan to the app's Plan model.
    /// - Parameters:
    ///   - spoonacularMealPlan: The Spoonacular meal plan response
    ///   - userId: The user ID for the plan
    ///   - weekStart: The start date of the week
    /// - Returns: A Plan model with associated PlanRecipes and Spoonacular recipe IDs
    static func mapMealPlan(
        _ spoonacularMealPlan: SpoonacularMealPlan,
        userId: String,
        weekStart: Date
    ) -> (plan: Plan, recipes: [PlanRecipe], spoonacularIds: [Int]) {
        
        let planId = UUID().uuidString
        let weekEnd = Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart
        
        // Create the plan
        let plan = Plan(
            id: planId,
            userId: userId,
            title: "Spoonacular Meal Plan",
            weekStart: weekStart,
            weekEnd: weekEnd,
            totalCost: calculateTotalCost(from: spoonacularMealPlan),
            isCompleted: false,
            createdAt: Date(),
            updatedAt: Date(),
            templateId: nil,
            generationMethod: "spoonacular",
            isFavorite: false,
            completionPercentage: 0.0
        )
        
        // Create plan recipes for each meal
        var recipes: [PlanRecipe] = []
        var spoonacularIds: [Int] = []
        
        Logger.info("Mapping Spoonacular meal plan with \(spoonacularMealPlan.week.allDays.count) days")
        
        for dayOfWeek in 0..<7 {
            if let dayMeals = spoonacularMealPlan.week.mealsForDay(dayOfWeek) {
                let dayName = getDayName(for: dayOfWeek)
                Logger.info("Day \(dayName) has \(dayMeals.allMeals.count) meals")
                
                // Add all meals for the day (no longer separated by meal type)
                for (index, meal) in dayMeals.allMeals.enumerated() {
                    // Determine meal type based on position or default to "dinner"
                    let mealType = index == 0 ? "breakfast" : index == 1 ? "lunch" : "dinner"
                    
                    let recipe = createPlanRecipe(
                        from: meal,
                        planId: planId,
                        dayOfWeek: dayOfWeek,
                        mealType: mealType,
                        day: dayName,
                        position: index
                    )
                    recipes.append(recipe)
                    spoonacularIds.append(meal.id)
                    Logger.info("Added meal: \(meal.title) for \(mealType)")
                }
            } else {
                Logger.warning("No meals found for day \(dayOfWeek)")
            }
        }
        
        Logger.info("Total recipes created: \(recipes.count)")
        
        return (plan: plan, recipes: recipes, spoonacularIds: spoonacularIds)
    }
    
    // MARK: - Recipe Mapping
    
    /// Maps a SpoonacularRecipe to the app's Recipe model.
    /// - Parameter spoonacularRecipe: The Spoonacular recipe response
    /// - Returns: A Recipe model
    static func mapRecipe(_ spoonacularRecipe: SpoonacularRecipe) -> Recipe {
        
        // Extract ingredients from extended ingredients
        let ingredients = spoonacularRecipe.extendedIngredients.map { ingredient in
            return ingredient.original
        }
        
        // Extract steps from analyzed instructions
        let steps = spoonacularRecipe.analyzedInstructions.flatMap { instruction in
            return instruction.steps.map { step in
                return step.step
            }
        }
        
        // Create tags from various recipe properties
        var tags: [String] = []
        
        // Add cuisine types
        tags.append(contentsOf: spoonacularRecipe.cuisines)
        
        // Add dietary tags
        if spoonacularRecipe.vegetarian {
            tags.append("vegetarian")
        }
        if spoonacularRecipe.vegan {
            tags.append("vegan")
        }
        if spoonacularRecipe.glutenFree {
            tags.append("gluten-free")
        }
        if spoonacularRecipe.dairyFree {
            tags.append("dairy-free")
        }
        if spoonacularRecipe.ketogenic == true {
            tags.append("keto")
        }
        if spoonacularRecipe.veryHealthy {
            tags.append("healthy")
        }
        if spoonacularRecipe.cheap {
            tags.append("budget-friendly")
        }
        
        // Add dish types
        tags.append(contentsOf: spoonacularRecipe.dishTypes)
        
        // Determine difficulty based on ready time
        let difficulty: String
        if spoonacularRecipe.readyInMinutes <= 30 {
            difficulty = "easy"
        } else if spoonacularRecipe.readyInMinutes <= 60 {
            difficulty = "medium"
        } else {
            difficulty = "hard"
        }
        
        // Determine cuisine type
        let cuisineType = spoonacularRecipe.cuisines.first ?? "western"
        
        return Recipe(
            id: UUID().uuidString,
            title: spoonacularRecipe.title,
            cookTime: "\(spoonacularRecipe.readyInMinutes) mins",
            prepTime: nil, // Not provided by Spoonacular
            servings: spoonacularRecipe.servings,
            calories: nil, // Will be calculated from nutrition if needed
            imageUrl: spoonacularRecipe.image,
            ingredients: ingredients,
            steps: steps,
            substitutions: [], // Not provided by Spoonacular
            tags: tags,
            difficulty: difficulty,
            cuisineType: cuisineType,
            costEstimate: spoonacularRecipe.pricePerServing / 100.0, // Convert from cents
            createdAt: Date(),
            updatedAt: Date(),
            createdBy: "spoonacular",
            spoonacularId: String(spoonacularRecipe.id),
            isPublic: true,
            rating: Double(spoonacularRecipe.aggregateLikes) / 100.0, // Normalize rating
            ratingCount: spoonacularRecipe.aggregateLikes
        )
    }
    
    // MARK: - Grocery List Mapping
    
    /// Maps a SpoonacularShoppingList to an array of GroceryItem models.
    /// - Parameters:
    ///   - spoonacularShoppingList: The Spoonacular shopping list response
    ///   - userId: The user ID for the grocery items
    ///   - planId: The plan ID associated with the grocery list
    /// - Returns: An array of GroceryItem models
    static func mapGroceryList(
        _ spoonacularShoppingList: SpoonacularShoppingList,
        userId: String,
        planId: String
    ) -> [GroceryItem] {
        
        var groceryItems: [GroceryItem] = []
        
        for aisle in spoonacularShoppingList.aisles {
            for item in aisle.items {
                let groceryItem = GroceryItem(
                    id: UUID().uuidString,
                    userId: userId,
                    name: item.name,
                    quantity: item.measures.original.amount,
                    unit: item.measures.original.unitShort,
                    category: mapAisleToCategory(aisle.aisle),
                    priority: "Medium",
                    isCompleted: false,
                    notes: nil,
                    estimatedPrice: item.cost,
                    recipeId: nil,
                    planId: planId,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                groceryItems.append(groceryItem)
            }
        }
        
        return groceryItems
    }
    
    // MARK: - Private Helper Methods
    
    /// Creates a PlanRecipe from a SpoonacularMeal.
    /// - Parameters:
    ///   - meal: The Spoonacular meal
    ///   - planId: The plan ID
    ///   - dayOfWeek: The day of the week (0-6)
    ///   - mealType: The type of meal (breakfast, lunch, dinner)
    ///   - day: The day name
    ///   - position: The position/order of the meal
    /// - Returns: A PlanRecipe model
    private static func createPlanRecipe(
        from meal: SpoonacularMeal,
        planId: String,
        dayOfWeek: Int,
        mealType: String,
        day: String,
        position: Int
    ) -> PlanRecipe {
        
        return PlanRecipe(
            id: UUID().uuidString,
            planId: planId,
            recipeId: nil, // Will be set later when we have the Recipe UUID
            dayOfWeek: dayOfWeek,
            mealType: mealType,
            position: position,
            day: day,
            isCompleted: false,
            completedAt: nil,
            customMealName: meal.title,
            customIngredients: [], // Will be populated when recipe details are fetched
            customInstructions: [], // Will be populated when recipe details are fetched
            customCookTime: meal.readyInMinutes,
            notes: nil
        )
    }
    
    /// Calculates the total cost from a Spoonacular meal plan.
    /// - Parameter mealPlan: The Spoonacular meal plan
    /// - Returns: The total estimated cost
    private static func calculateTotalCost(from mealPlan: SpoonacularMealPlan) -> Double {
        var totalCost: Double = 0.0
        
        for dayMeals in mealPlan.week.allDays {
            for meal in dayMeals.meals {
                // Estimate cost based on servings and complexity
                let baseCost = 5.0 // Base cost per meal
                let servingMultiplier = Double(meal.servings) / 4.0 // Normalize to 4 servings
                let timeMultiplier = Double(meal.readyInMinutes) / 30.0 // Normalize to 30 minutes
                
                let estimatedCost = baseCost * servingMultiplier * timeMultiplier
                totalCost += estimatedCost
            }
        }
        
        return totalCost
    }
    
    /// Gets the day name for a given day of the week.
    /// - Parameter dayOfWeek: The day of the week (0-6)
    /// - Returns: The day name
    private static func getDayName(for dayOfWeek: Int) -> String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[dayOfWeek]
    }
    
    /// Maps a Spoonacular aisle to a grocery category.
    /// - Parameter aisle: The Spoonacular aisle name
    /// - Returns: A grocery category
    private static func mapAisleToCategory(_ aisle: String) -> String {
        let lowercasedAisle = aisle.lowercased()
        
        if lowercasedAisle.contains("produce") || lowercasedAisle.contains("vegetables") || lowercasedAisle.contains("fruits") {
            return "Produce"
        } else if lowercasedAisle.contains("dairy") || lowercasedAisle.contains("milk") || lowercasedAisle.contains("cheese") {
            return "Dairy & Eggs"
        } else if lowercasedAisle.contains("meat") || lowercasedAisle.contains("protein") || lowercasedAisle.contains("seafood") {
            return "Meat & Seafood"
        } else if lowercasedAisle.contains("pantry") || lowercasedAisle.contains("grains") || lowercasedAisle.contains("canned") {
            return "Pantry"
        } else if lowercasedAisle.contains("frozen") {
            return "Frozen"
        } else if lowercasedAisle.contains("beverages") {
            return "Beverages"
        } else if lowercasedAisle.contains("snacks") {
            return "Snacks"
        } else if lowercasedAisle.contains("bakery") {
            return "Bakery"
        } else if lowercasedAisle.contains("condiments") {
            return "Condiments"
        } else if lowercasedAisle.contains("spices") || lowercasedAisle.contains("herbs") {
            return "Spices & Herbs"
        } else {
            return "Other"
        }
    }
} 
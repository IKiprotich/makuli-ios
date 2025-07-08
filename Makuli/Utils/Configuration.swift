//
//  Configuration.swift
//  Buildplate
//
//  Created by ian on 2025-01-03.
//

import Foundation

struct Configuration {
    /// OpenAI API Key for meal plan generation
    static var openAIAPIKey: String {
        // First, try to get from environment variable
        if let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !apiKey.isEmpty {
            return apiKey
        }
        
        // First, try to get from a plist file (not tracked in git)
        if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
           let plist = NSDictionary(contentsOfFile: path),
           let apiKey = plist["OpenAI_API_Key"] as? String {
            return apiKey
        }
        
        // Fallback to hardcoded value (not recommended for production)
        return ""
    }
    
    /// Whether to use mock responses instead of real API calls
    static var useMockAIResponses: Bool {
        return openAIAPIKey.isEmpty
    }
    
    /// Mock AI response for testing without API key
    static var mockAIResponse: MealPlanGenerationResponse {
        return MealPlanGenerationResponse(
            weekTitle: "Week of Jan 6",
            totalEstimatedCost: 85.50,
            meals: mockWeekMeals
        )
    }
    
    private static var mockWeekMeals: [DayMealPlan] {
        return [
                         // Monday
             DayMealPlan(
                 day: "Monday",
                dayOfWeek: 0,
                breakfast: GeneratedMeal(
                    name: "Avocado Toast with Eggs",
                    cookingTime: 10,
                    difficulty: "easy",
                    ingredients: ["sourdough bread", "avocado", "free-range eggs", "cherry tomatoes"],
                    instructions: ["Toast bread until golden", "Mash avocado with salt and pepper", "Fry eggs to preference", "Top toast with avocado and egg"],
                    estimatedCost: 8.50
                ),
                lunch: GeneratedMeal(
                    name: "Mediterranean Quinoa Bowl",
                    cookingTime: 25,
                    difficulty: "medium",
                    ingredients: ["quinoa", "chickpeas", "cucumber", "cherry tomatoes", "feta cheese", "olive oil"],
                    instructions: ["Cook quinoa according to package", "Drain chickpeas", "Dice vegetables", "Combine all ingredients", "Drizzle with olive oil"],
                    estimatedCost: 12.00
                ),
                dinner: GeneratedMeal(
                    name: "Grilled Salmon with Asparagus",
                    cookingTime: 20,
                    difficulty: "medium",
                    ingredients: ["salmon fillets", "asparagus", "lemon", "olive oil", "garlic"],
                    instructions: ["Season salmon with herbs", "Trim asparagus", "Grill salmon 4-5 minutes per side", "Grill asparagus until tender", "Serve with lemon"],
                    estimatedCost: 18.00
                )
            ),
                         // Tuesday  
             DayMealPlan(
                 day: "Tuesday",
                dayOfWeek: 1,
                breakfast: GeneratedMeal(
                    name: "Overnight Oats Bowl",
                    cookingTime: 5,
                    difficulty: "easy",
                    ingredients: ["rolled oats", "almond milk", "Greek yogurt", "berries", "honey"],
                    instructions: ["Mix oats with milk and yogurt", "Add honey", "Refrigerate overnight", "Top with berries in morning"],
                    estimatedCost: 6.50
                ),
                lunch: GeneratedMeal(
                    name: "Chicken Caesar Salad",
                    cookingTime: 15,
                    difficulty: "easy",
                    ingredients: ["chicken breast", "romaine lettuce", "caesar dressing", "parmesan", "croutons"],
                    instructions: ["Grill chicken until cooked", "Chop lettuce", "Slice chicken", "Toss with dressing", "Top with cheese and croutons"],
                    estimatedCost: 11.00
                ),
                dinner: GeneratedMeal(
                    name: "Creamy Mushroom Risotto",
                    cookingTime: 35,
                    difficulty: "medium",
                    ingredients: ["arborio rice", "mixed mushrooms", "vegetable stock", "parmesan", "white wine"],
                    instructions: ["Heat stock in separate pan", "Sauté mushrooms", "Add rice and toast", "Add wine and stock gradually", "Stir in cheese"],
                    estimatedCost: 14.50
                )
            ),
                         // Wednesday
             DayMealPlan(
                 day: "Wednesday",
                dayOfWeek: 2,
                breakfast: GeneratedMeal(
                    name: "Pancakes with Berries",
                    cookingTime: 20,
                    difficulty: "medium",
                    ingredients: ["flour", "eggs", "milk", "mixed berries", "maple syrup"],
                    instructions: ["Mix pancake batter", "Heat pan with butter", "Cook pancakes until golden", "Serve with berries and syrup"],
                    estimatedCost: 7.00
                ),
                lunch: GeneratedMeal(
                    name: "Turkey Club Sandwich",
                    cookingTime: 10,
                    difficulty: "easy",
                    ingredients: ["turkey slices", "bacon", "lettuce", "tomato", "sourdough bread", "mayo"],
                    instructions: ["Toast bread", "Cook bacon until crispy", "Layer turkey, bacon, lettuce, tomato", "Add mayo and assemble"],
                    estimatedCost: 9.50
                ),
                dinner: GeneratedMeal(
                    name: "Classic Beef Tacos",
                    cookingTime: 25,
                    difficulty: "medium",
                    ingredients: ["ground beef", "taco shells", "cheddar cheese", "lettuce", "sour cream"],
                    instructions: ["Cook ground beef with seasonings", "Warm taco shells", "Shred lettuce and cheese", "Assemble tacos with toppings"],
                    estimatedCost: 15.00
                )
            ),
                         // Thursday
             DayMealPlan(
                 day: "Thursday",
                dayOfWeek: 3,
                breakfast: GeneratedMeal(
                    name: "Greek Yogurt Parfait",
                    cookingTime: 5,
                    difficulty: "easy",
                    ingredients: ["Greek yogurt", "granola", "mixed berries", "honey"],
                    instructions: ["Layer yogurt in bowl", "Add berries and granola", "Drizzle with honey"],
                    estimatedCost: 6.00
                ),
                lunch: GeneratedMeal(
                    name: "Caprese Salad",
                    cookingTime: 10,
                    difficulty: "easy",
                    ingredients: ["fresh mozzarella", "tomatoes", "basil", "balsamic glaze", "olive oil"],
                    instructions: ["Slice tomatoes and mozzarella", "Arrange with basil leaves", "Drizzle with oil and balsamic"],
                    estimatedCost: 10.00
                ),
                dinner: GeneratedMeal(
                    name: "Chicken Caesar Pasta",
                    cookingTime: 30,
                    difficulty: "medium",
                    ingredients: ["penne pasta", "chicken breast", "caesar dressing", "parmesan", "romaine"],
                    instructions: ["Cook pasta until al dente", "Grill and slice chicken", "Toss pasta with dressing", "Add chicken and lettuce", "Top with cheese"],
                    estimatedCost: 16.00
                )
            ),
                         // Friday
             DayMealPlan(
                 day: "Friday",
                dayOfWeek: 4,
                breakfast: GeneratedMeal(
                    name: "Scrambled Eggs with Toast",
                    cookingTime: 8,
                    difficulty: "easy",
                    ingredients: ["eggs", "butter", "whole grain bread", "chives"],
                    instructions: ["Scramble eggs with butter", "Toast bread", "Garnish with chives"],
                    estimatedCost: 5.50
                ),
                lunch: GeneratedMeal(
                    name: "Asian Stir Fry",
                    cookingTime: 15,
                    difficulty: "medium",
                    ingredients: ["mixed vegetables", "soy sauce", "ginger", "garlic", "sesame oil"],
                    instructions: ["Heat oil in wok", "Add vegetables", "Stir fry with seasonings", "Serve over rice"],
                    estimatedCost: 11.50
                ),
                dinner: GeneratedMeal(
                    name: "Honey Garlic Stir Fry",
                    cookingTime: 15,
                    difficulty: "easy",
                    ingredients: ["mixed vegetables", "honey", "soy sauce", "garlic", "ginger"],
                    instructions: ["Prepare sauce with honey and soy", "Stir fry vegetables", "Add sauce and toss", "Serve hot"],
                    estimatedCost: 12.50
                )
            ),
                         // Saturday  
             DayMealPlan(
                 day: "Saturday",
                dayOfWeek: 5,
                breakfast: GeneratedMeal(
                    name: "French Toast",
                    cookingTime: 15,
                    difficulty: "medium",
                    ingredients: ["brioche bread", "eggs", "milk", "vanilla", "cinnamon", "maple syrup"],
                    instructions: ["Whisk eggs with milk and spices", "Dip bread in mixture", "Cook in buttered pan", "Serve with syrup"],
                    estimatedCost: 8.00
                ),
                lunch: GeneratedMeal(
                    name: "Fish and Chips",
                    cookingTime: 25,
                    difficulty: "medium",
                    ingredients: ["white fish fillets", "potatoes", "flour", "beer batter", "oil"],
                    instructions: ["Cut potatoes into chips", "Make beer batter", "Batter and fry fish", "Fry chips until golden"],
                    estimatedCost: 14.00
                ),
                dinner: GeneratedMeal(
                    name: "BBQ Ribs",
                    cookingTime: 45,
                    difficulty: "hard",
                    ingredients: ["pork ribs", "BBQ sauce", "dry rub spices", "coleslaw"],
                    instructions: ["Apply dry rub to ribs", "Slow cook in oven", "Brush with BBQ sauce", "Serve with coleslaw"],
                    estimatedCost: 20.00
                )
            ),
                         // Sunday
             DayMealPlan(
                 day: "Sunday",
                dayOfWeek: 6,
                breakfast: GeneratedMeal(
                    name: "Full English Breakfast",
                    cookingTime: 25,
                    difficulty: "medium",
                    ingredients: ["eggs", "bacon", "sausages", "beans", "mushrooms", "toast"],
                    instructions: ["Fry bacon and sausages", "Cook eggs to preference", "Sauté mushrooms", "Heat beans", "Serve with toast"],
                    estimatedCost: 12.00
                ),
                lunch: GeneratedMeal(
                    name: "Caesar Wrap",
                    cookingTime: 10,
                    difficulty: "easy",
                    ingredients: ["tortilla wraps", "grilled chicken", "romaine lettuce", "caesar dressing", "parmesan"],
                    instructions: ["Warm tortillas", "Fill with chicken and lettuce", "Add dressing and cheese", "Roll tightly"],
                    estimatedCost: 9.00
                ),
                dinner: GeneratedMeal(
                    name: "Spaghetti Bolognese",
                    cookingTime: 40,
                    difficulty: "medium",
                    ingredients: ["spaghetti", "ground beef", "tomato sauce", "onions", "garlic", "herbs"],
                    instructions: ["Cook pasta until al dente", "Brown ground beef", "Add sauce and simmer", "Toss with pasta", "Garnish with herbs"],
                    estimatedCost: 13.50
                )
            )
        ]
    }
}

// MARK: - Configuration Extension for AIService

extension AIService {
    /// Gets the configured OpenAI API key
    var configuredAPIKey: String {
        return Configuration.openAIAPIKey
    }
    
    /// Whether to use mock responses
    var shouldUseMockResponses: Bool {
        return Configuration.useMockAIResponses
    }
} 
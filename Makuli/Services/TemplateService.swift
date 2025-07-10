//
//  TemplateService.swift
//  Makuli
//
//  Created by Ian on 2025-01-08.
//
//  Service for managing meal plan templates in Supabase database.
//

import Foundation
import Supabase

@MainActor
class TemplateService: ObservableObject {
    static let shared = TemplateService()
    
    @Published var templates: [MealPlanTemplate] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client
    private var fetchTask: Task<Void, Never>?
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Fetches all active meal plan templates from database
    func fetchTemplates() async {
        fetchTask?.cancel()
        
        fetchTask = Task {
            await performFetch()
        }
        
        await fetchTask?.value
    }
    
    /// Fetches a specific template with its meals
    func fetchFullTemplate(id: String) async -> FullMealPlanTemplate? {
        do {
            // Fetch template details
            let templateResponse = try await supabase
                .from("meal_plan_templates")
                .select("*")
                .eq("id", value: id)
                .single()
                .execute()
            
            let template = try JSONDecoder().decode(MealPlanTemplate.self, from: templateResponse.data)
            
            // Fetch template meals
            let mealsResponse = try await supabase
                .from("template_meals")
                .select("*")
                .eq("template_id", value: id)
                .order("day_of_week", ascending: true)
                .order("position", ascending: true)
                .execute()
            
            let meals = try JSONDecoder().decode([TemplateMeal].self, from: mealsResponse.data)
            
            return FullMealPlanTemplate(id: id, template: template, meals: meals)
            
        } catch {
            Logger.error("Failed to fetch full template \(id): \(error)")
            return nil
        }
    }
    
    /// Creates a user plan from a template
    func createPlanFromTemplate(_ template: FullMealPlanTemplate, for userId: String, weekStart: Date) async -> Bool {
        do {
            // Create plan request from template
            let planRequest = CreatePlanRequest(
                userId: userId,
                title: template.template.name,
                weekStart: ISO8601DateFormatter().string(from: weekStart),
                weekEnd: ISO8601DateFormatter().string(from: Calendar.current.date(byAdding: .day, value: 6, to: weekStart) ?? weekStart),
                totalCost: template.template.estimatedCostMax,
                templateId: template.template.id,
                generationMethod: "template"
            )
            
            // 1. Create the plan
            let planResponse = try await supabase
                .from("plans")
                .insert(planRequest)
                .select()
                .single()
                .execute()
            
            let createdPlan = try JSONDecoder().decode(Plan.self, from: planResponse.data)
            
            // 2. Create meal requests from template meals
            let mealRequests = template.meals.map { meal in
                CreatePlanRecipeRequest(
                    planId: createdPlan.id,
                    recipeId: meal.recipeId,
                    dayOfWeek: meal.dayOfWeek,
                    mealType: meal.mealType,
                    position: meal.position,
                    day: meal.day,
                    customMealName: meal.mealName,
                    customIngredients: nil,
                    customInstructions: nil,
                    customCookTime: meal.cookingTime
                )
            }
            
            // 3. Create plan recipes if we have meals with recipes
            if !mealRequests.isEmpty {
                try await supabase
                    .from("plan_recipes")
                    .insert(mealRequests)
                    .execute()
            }
            
            Logger.info("Successfully created plan from template: \(template.template.name)")
            return true
            
        } catch {
            Logger.error("Failed to create plan from template: \(error)")
            errorMessage = "Failed to create meal plan from template. Please try again."
            return false
        }
    }
    
    /// Seeds the database with sample templates (for initial setup)
    func seedSampleTemplates() async -> Bool {
        do {
            let sampleTemplates = createSampleTemplates()
            
            for templateData in sampleTemplates {
                // Create template
                let templateResponse = try await supabase
                    .from("meal_plan_templates")
                    .insert(templateData.template)
                    .select()
                    .single()
                    .execute()
                
                let createdTemplate = try JSONDecoder().decode(MealPlanTemplate.self, from: templateResponse.data)
                
                // Create template meals
                let mealsWithTemplateId = templateData.meals.map { meal in
                    CreateTemplateMealRequest(
                        templateId: createdTemplate.id,
                        dayOfWeek: meal.dayOfWeek,
                        mealType: meal.mealType,
                        mealName: meal.mealName,
                        recipeId: meal.recipeId,
                        cookingTime: meal.cookingTime,
                        difficulty: meal.difficulty,
                        position: meal.position,
                        day: meal.day,
                        estimatedCost: meal.estimatedCost,
                        calories: meal.calories,
                        prepTime: meal.prepTime,
                        ingredients: meal.ingredients,
                        instructions: meal.instructions
                    )
                }
                
                if !mealsWithTemplateId.isEmpty {
                    try await supabase
                        .from("template_meals")
                        .insert(mealsWithTemplateId)
                        .execute()
                }
                
                Logger.info("Seeded template: \(templateData.template.name)")
            }
            
            // Refresh templates after seeding
            await fetchTemplates()
            
            Logger.info("Successfully seeded \(sampleTemplates.count) sample templates")
            return true
            
        } catch {
            Logger.error("Failed to seed sample templates: \(error)")
            errorMessage = "Failed to set up sample templates. Please try again."
            return false
        }
    }
    
    // MARK: - Private Methods
    
    private func performFetch() async {
        isLoading = true
        errorMessage = nil
        
        defer { isLoading = false }
        
        do {
            let response = try await supabase
                .from("meal_plan_templates")
                .select("*")
                .eq("is_active", value: true)
                .order("popularity_score", ascending: false)
                .execute()
            
            let templates = try JSONDecoder().decode([MealPlanTemplate].self, from: response.data)
            self.templates = templates
            
            Logger.debug("Successfully loaded \(templates.count) meal plan templates")
            
        } catch {
            let errorDescription = error.localizedDescription
            
            if errorDescription.contains("does not exist") {
                self.errorMessage = "Template system is being set up. Please try again in a moment."
                Logger.info("Templates table not yet created - using empty list")
            } else if errorDescription.contains("No rows") || errorDescription.contains("not found") {
                self.errorMessage = nil // Empty list is normal for new setup
                Logger.info("No templates found in database")
            } else {
                self.errorMessage = "Failed to load meal plan templates. Please check your connection and try again."
                Logger.error("Error fetching templates: \(errorDescription)")
            }
            
            self.templates = []
        }
    }
    
    private func createSampleTemplates() -> [(template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest])] {
        return [
            // Original 4 templates
            createMediterraneanTemplate(),
            createBudgetFriendlyTemplate(),
            createQuickMealsTemplate(),
            createHealthyTemplate(),
            
            // New expanded templates
            createAsianFusionTemplate(),
            createMexicanFiestaTemplate(),
            createItalianClassicsTemplate(),
            createComfortFoodTemplate(),
            createHighProteinTemplate(),
            createVegetarianTemplate(),
            createFamilyStyleTemplate(),
            createKetoTemplate(),
            createMealPrepTemplate(),
            createGlobalCuisineTemplate()
        ]
    }
    
    private func createMediterraneanTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Mediterranean Week",
            description: "Fresh, healthy meals inspired by Mediterranean cuisine featuring olive oil, fresh vegetables, and lean proteins",
            category: TemplateCategory.mediterranean.rawValue,
            difficulty: "Intermediate",
            durationDays: 7,
            estimatedCostMin: 75.0,
            estimatedCostMax: 100.0,
            imageUrl: nil,
            tags: ["healthy", "mediterranean", "fresh", "balanced"],
            isActive: true,
            icon: "🫒",
            colorScheme: "blue",
            targetCaloriesPerDay: 2000,
            macros: MacroDistribution(protein: 20, carbs: 45, fat: 35)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Greek Yogurt with Honey and Nuts", 15, "easy"),
            ("Monday", 0, "lunch", "Mediterranean Quinoa Bowl", 25, "medium"),
            ("Monday", 0, "dinner", "Grilled Salmon with Asparagus", 30, "medium"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Avocado Toast with Tomatoes", 10, "easy"),
            ("Tuesday", 1, "lunch", "Greek Salad with Chicken", 20, "easy"),
            ("Tuesday", 1, "dinner", "Lemon Herb Chicken with Roasted Vegetables", 35, "medium"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Mediterranean Smoothie Bowl", 10, "easy"),
            ("Wednesday", 2, "lunch", "Hummus and Vegetable Wrap", 15, "easy"),
            ("Wednesday", 2, "dinner", "Baked Fish with Herbs and Lemon", 25, "medium"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Oatmeal with Fresh Berries", 10, "easy"),
            ("Thursday", 3, "lunch", "Tabbouleh with Grilled Halloumi", 20, "medium"),
            ("Thursday", 3, "dinner", "Mediterranean Pasta with Olives", 25, "easy"),
            
            // Friday
            ("Friday", 4, "breakfast", "Scrambled Eggs with Spinach", 15, "easy"),
            ("Friday", 4, "lunch", "Caprese Salad with Basil", 10, "easy"),
            ("Friday", 4, "dinner", "Grilled Lamb with Mediterranean Vegetables", 40, "hard"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Fresh Fruit and Yogurt Parfait", 5, "easy"),
            ("Saturday", 5, "lunch", "Mediterranean Flatbread Pizza", 20, "medium"),
            ("Saturday", 5, "dinner", "Seafood Paella", 45, "hard"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Mediterranean Breakfast Bowl", 15, "easy"),
            ("Sunday", 6, "lunch", "Lentil and Vegetable Soup", 30, "medium"),
            ("Sunday", 6, "dinner", "Herb-Crusted Chicken with Potatoes", 35, "medium")
        ])
        
        return (template, meals)
    }
    
    private func createBudgetFriendlyTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Budget-Friendly Week",
            description: "Delicious, nutritious meals that won't break the bank. Perfect for students and families on a budget",
            category: TemplateCategory.budget.rawValue,
            difficulty: "Beginner",
            durationDays: 7,
            estimatedCostMin: 35.0,
            estimatedCostMax: 50.0,
            imageUrl: nil,
            tags: ["budget", "affordable", "simple", "family-friendly"],
            isActive: true,
            icon: "💰",
            colorScheme: "green",
            targetCaloriesPerDay: 2500,
            macros: MacroDistribution(protein: 25, carbs: 40, fat: 35)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Oatmeal with Banana", 10, "easy"),
            ("Monday", 0, "lunch", "Peanut Butter and Jelly Sandwich", 5, "easy"),
            ("Monday", 0, "dinner", "Spaghetti with Meat Sauce", 30, "easy"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Scrambled Eggs and Toast", 10, "easy"),
            ("Tuesday", 1, "lunch", "Tuna Sandwich", 10, "easy"),
            ("Tuesday", 1, "dinner", "Bean and Rice Bowl", 25, "easy"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Cereal with Milk", 5, "easy"),
            ("Wednesday", 2, "lunch", "Grilled Cheese and Soup", 15, "easy"),
            ("Wednesday", 2, "dinner", "Chicken and Vegetable Stir Fry", 25, "medium"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Toast with Jam", 5, "easy"),
            ("Thursday", 3, "lunch", "Leftover Stir Fry", 5, "easy"),
            ("Thursday", 3, "dinner", "Baked Potato with Cheese and Beans", 20, "easy"),
            
            // Friday
            ("Friday", 4, "breakfast", "Pancakes from Mix", 15, "easy"),
            ("Friday", 4, "lunch", "Ham and Cheese Wrap", 10, "easy"),
            ("Friday", 4, "dinner", "One-Pot Pasta with Vegetables", 25, "easy"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "French Toast", 15, "easy"),
            ("Saturday", 5, "lunch", "Quesadilla with Salsa", 10, "easy"),
            ("Saturday", 5, "dinner", "Homemade Pizza", 30, "medium"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Eggs and Hash Browns", 20, "easy"),
            ("Sunday", 6, "lunch", "Soup and Crackers", 10, "easy"),
            ("Sunday", 6, "dinner", "Slow Cooker Chicken and Vegetables", 15, "easy")
        ])
        
        return (template, meals)
    }
    
    private func createQuickMealsTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Quick & Easy Week",
            description: "Fast meals for busy schedules. Most meals ready in 20 minutes or less",
            category: TemplateCategory.quick.rawValue,
            difficulty: "Beginner",
            durationDays: 7,
            estimatedCostMin: 60.0,
            estimatedCostMax: 80.0,
            imageUrl: nil,
            tags: ["quick", "easy", "fast", "busy", "20min"],
            isActive: true,
            icon: "⚡️",
            colorScheme: "yellow",
            targetCaloriesPerDay: 2200,
            macros: MacroDistribution(protein: 20, carbs: 40, fat: 40)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Smoothie with Protein Powder", 5, "easy"),
            ("Monday", 0, "lunch", "Pre-made Salad with Chicken", 10, "easy"),
            ("Monday", 0, "dinner", "15-Minute Pasta Primavera", 15, "easy"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Instant Oatmeal with Berries", 5, "easy"),
            ("Tuesday", 1, "lunch", "Microwave Baked Potato with Toppings", 10, "easy"),
            ("Tuesday", 1, "dinner", "Quick Stir Fry with Frozen Vegetables", 15, "easy"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Greek Yogurt with Granola", 3, "easy"),
            ("Wednesday", 2, "lunch", "Avocado Toast with Egg", 10, "easy"),
            ("Wednesday", 2, "dinner", "Sheet Pan Chicken and Vegetables", 20, "easy"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Protein Bar and Banana", 2, "easy"),
            ("Thursday", 3, "lunch", "Quick Caesar Wrap", 8, "easy"),
            ("Thursday", 3, "dinner", "Microwave Fish with Steamed Vegetables", 12, "easy"),
            
            // Friday
            ("Friday", 4, "breakfast", "Breakfast Burrito (frozen)", 3, "easy"),
            ("Friday", 4, "lunch", "Soup and Pre-made Sandwich", 5, "easy"),
            ("Friday", 4, "dinner", "Quick Fried Rice", 15, "easy"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Cereal and Fruit", 5, "easy"),
            ("Saturday", 5, "lunch", "Quick Quesadilla", 10, "easy"),
            ("Saturday", 5, "dinner", "20-Minute Chicken Fajitas", 20, "easy"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Bagel with Cream Cheese", 5, "easy"),
            ("Sunday", 6, "lunch", "Quick Salad with Canned Tuna", 8, "easy"),
            ("Sunday", 6, "dinner", "One-Pot Pasta with Sauce", 18, "easy")
        ])
        
        return (template, meals)
    }
    
    private func createHealthyTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Healthy & Balanced Week",
            description: "Nutritious, well-balanced meals designed for optimal health and energy",
            category: TemplateCategory.healthy.rawValue,
            difficulty: "Intermediate",
            durationDays: 7,
            estimatedCostMin: 85.0,
            estimatedCostMax: 110.0,
            imageUrl: nil,
            tags: ["healthy", "balanced", "nutritious", "clean eating", "wellness"],
            isActive: true,
            icon: "🥗",
            colorScheme: "purple",
            targetCaloriesPerDay: 2100,
            macros: MacroDistribution(protein: 25, carbs: 40, fat: 35)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Green Smoothie Bowl with Seeds", 15, "easy"),
            ("Monday", 0, "lunch", "Quinoa Buddha Bowl", 25, "medium"),
            ("Monday", 0, "dinner", "Baked Salmon with Sweet Potato", 30, "medium"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Overnight Chia Pudding", 5, "easy"),
            ("Tuesday", 1, "lunch", "Kale and Chickpea Salad", 20, "easy"),
            ("Tuesday", 1, "dinner", "Grilled Chicken with Roasted Vegetables", 35, "medium"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Avocado Toast with Hemp Seeds", 10, "easy"),
            ("Wednesday", 2, "lunch", "Lentil and Vegetable Soup", 30, "medium"),
            ("Wednesday", 2, "dinner", "Zucchini Noodles with Turkey Meatballs", 25, "medium"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Steel Cut Oats with Berries", 15, "easy"),
            ("Thursday", 3, "lunch", "Rainbow Veggie Wrap", 15, "easy"),
            ("Thursday", 3, "dinner", "Baked Cod with Quinoa Pilaf", 30, "medium"),
            
            // Friday
            ("Friday", 4, "breakfast", "Protein Smoothie with Spinach", 10, "easy"),
            ("Friday", 4, "lunch", "Asian Lettuce Wraps", 20, "medium"),
            ("Friday", 4, "dinner", "Stuffed Bell Peppers with Brown Rice", 35, "medium"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Greek Yogurt Parfait with Nuts", 10, "easy"),
            ("Saturday", 5, "lunch", "Cauliflower Rice Bowl", 20, "medium"),
            ("Saturday", 5, "dinner", "Herb-Crusted Pork Tenderloin", 40, "hard"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Vegetable Omelet with Herbs", 15, "medium"),
            ("Sunday", 6, "lunch", "Buddha Bowl with Tahini Dressing", 25, "medium"),
            ("Sunday", 6, "dinner", "Grilled Fish Tacos with Cabbage Slaw", 30, "medium")
        ])
        
        return (template, meals)
    }
    
    private func createWeekMeals(templateId: String, meals: [(day: String, dayOfWeek: Int, mealType: String, name: String, cookingTime: Int, difficulty: String)]) -> [CreateTemplateMealRequest] {
        return meals.enumerated().map { index, meal in
            CreateTemplateMealRequest(
                templateId: templateId,
                dayOfWeek: meal.dayOfWeek,
                mealType: meal.mealType,
                mealName: meal.name,
                recipeId: nil, // Will be populated when recipes are matched
                cookingTime: meal.cookingTime,
                difficulty: meal.difficulty,
                position: index,
                day: meal.day,
                estimatedCost: 10.0,
                calories: 400,
                prepTime: 10,
                ingredients: ["Basic ingredients"],
                instructions: ["Basic instructions"]
            )
        }
    }
    
    // MARK: - New Enhanced Templates
    
    private func createAsianFusionTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Asian Fusion Week",
            description: "Delicious Asian-inspired meals featuring fresh ingredients, bold flavors, and healthy cooking methods",
            category: "Asian Fusion",
            difficulty: "Intermediate", 
            durationDays: 7,
            estimatedCostMin: 70.0,
            estimatedCostMax: 95.0,
            imageUrl: nil,
            tags: ["asian", "fresh", "healthy", "flavorful", "stir-fry"],
            isActive: true,
            icon: "🍣",
            colorScheme: "red",
            targetCaloriesPerDay: 2200,
            macros: MacroDistribution(protein: 25, carbs: 40, fat: 35)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Congee with Green Onions", 20, "easy"),
            ("Monday", 0, "lunch", "Korean Bibimbap Bowl", 30, "medium"),
            ("Monday", 0, "dinner", "Chinese Orange Chicken with Rice", 35, "medium"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Japanese Tamago and Rice", 15, "medium"),
            ("Tuesday", 1, "lunch", "Vietnamese Pho Soup", 25, "medium"),
            ("Tuesday", 1, "dinner", "Thai Green Curry with Vegetables", 30, "medium"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Miso Soup with Tofu", 10, "easy"),
            ("Wednesday", 2, "lunch", "Chinese Chicken and Broccoli", 20, "easy"),
            ("Wednesday", 2, "dinner", "Japanese Teriyaki Salmon", 25, "medium"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Asian Fruit Smoothie Bowl", 10, "easy"),
            ("Thursday", 3, "lunch", "Korean Kimchi Fried Rice", 15, "easy"),
            ("Thursday", 3, "dinner", "Thai Pad Thai with Shrimp", 25, "medium"),
            
            // Friday
            ("Friday", 4, "breakfast", "Chinese Steamed Buns", 20, "medium"),
            ("Friday", 4, "lunch", "Japanese Sushi Bowl", 25, "medium"),
            ("Friday", 4, "dinner", "Mongolian Beef Stir Fry", 30, "medium"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Bubble Tea Overnight Oats", 5, "easy"),
            ("Saturday", 5, "lunch", "Vietnamese Spring Rolls", 30, "hard"),
            ("Saturday", 5, "dinner", "Korean BBQ with Banchan", 45, "hard"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Asian Pancakes with Syrup", 20, "medium"),
            ("Sunday", 6, "lunch", "Thai Tom Yum Soup", 25, "medium"),
            ("Sunday", 6, "dinner", "Chinese Honey Walnut Shrimp", 35, "medium")
        ])
        
        return (template, meals)
    }
    
    private func createMexicanFiestaTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Mexican Fiesta Week",
            description: "Vibrant Mexican flavors with fresh ingredients, bold spices, and colorful presentations",
            category: "Mexican",
            difficulty: "Beginner",
            durationDays: 7,
            estimatedCostMin: 55.0,
            estimatedCostMax: 75.0,
            imageUrl: nil,
            tags: ["mexican", "spicy", "colorful", "fresh", "family-friendly"],
            isActive: true,
            icon: "🌮",
            colorScheme: "orange",
            targetCaloriesPerDay: 2400,
            macros: MacroDistribution(protein: 20, carbs: 45, fat: 35)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Huevos Rancheros with Beans", 20, "medium"),
            ("Monday", 0, "lunch", "Chicken Quesadillas", 15, "easy"),
            ("Monday", 0, "dinner", "Beef Tacos with Fresh Salsa", 25, "easy"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Mexican Scrambled Eggs", 10, "easy"),
            ("Tuesday", 1, "lunch", "Chicken Burrito Bowl", 20, "easy"),
            ("Tuesday", 1, "dinner", "Chicken Enchiladas Verde", 35, "medium"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Chorizo and Egg Burrito", 15, "easy"),
            ("Wednesday", 2, "lunch", "Mexican Street Corn Salad", 15, "easy"),
            ("Wednesday", 2, "dinner", "Carne Asada with Rice and Beans", 30, "medium"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Mexican Fruit Bowl with Chili", 10, "easy"),
            ("Thursday", 3, "lunch", "Chicken Tortilla Soup", 25, "medium"),
            ("Thursday", 3, "dinner", "Fish Tacos with Cabbage Slaw", 25, "medium"),
            
            // Friday
            ("Friday", 4, "breakfast", "Mexican Coffee and Pastry", 5, "easy"),
            ("Friday", 4, "lunch", "Nachos with Black Beans", 15, "easy"),
            ("Friday", 4, "dinner", "Chiles Rellenos", 40, "hard"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Mexican Hot Chocolate and Toast", 10, "easy"),
            ("Saturday", 5, "lunch", "Pozole Soup", 30, "medium"),
            ("Saturday", 5, "dinner", "Mole Chicken with Rice", 50, "hard"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Mexican Benedict with Salsa", 20, "medium"),
            ("Sunday", 6, "lunch", "Elote (Mexican Street Corn)", 10, "easy"),
            ("Sunday", 6, "dinner", "Carnitas with Flour Tortillas", 40, "medium")
        ])
        
        return (template, meals)
    }
    
    private func createItalianClassicsTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Italian Classics Week",
            description: "Authentic Italian recipes featuring fresh pasta, quality ingredients, and traditional cooking methods",
            category: "Italian",
            difficulty: "Intermediate",
            durationDays: 7,
            estimatedCostMin: 80.0,
            estimatedCostMax: 120.0,
            imageUrl: nil,
            tags: ["italian", "pasta", "authentic", "classic", "comfort"],
            isActive: true,
            icon: "🍝",
            colorScheme: "brown",
            targetCaloriesPerDay: 2300,
            macros: MacroDistribution(protein: 25, carbs: 40, fat: 35)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Cappuccino and Cornetto", 10, "easy"),
            ("Monday", 0, "lunch", "Caprese Salad with Focaccia", 15, "easy"),
            ("Monday", 0, "dinner", "Spaghetti Carbonara", 25, "medium"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Espresso and Biscotti", 5, "easy"),
            ("Tuesday", 1, "lunch", "Minestrone Soup", 30, "medium"),
            ("Tuesday", 1, "dinner", "Chicken Parmigiana with Pasta", 40, "medium"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Italian Yogurt with Honey", 5, "easy"),
            ("Wednesday", 2, "lunch", "Prosciutto and Melon", 10, "easy"),
            ("Wednesday", 2, "dinner", "Risotto alla Milanese", 35, "hard"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Frittata with Herbs", 15, "medium"),
            ("Thursday", 3, "lunch", "Panzanella Bread Salad", 20, "easy"),
            ("Thursday", 3, "dinner", "Osso Buco with Polenta", 60, "hard"),
            
            // Friday
            ("Friday", 4, "breakfast", "Maritozzo with Coffee", 10, "easy"),
            ("Friday", 4, "lunch", "Pizza Margherita", 25, "medium"),
            ("Friday", 4, "dinner", "Seafood Linguine", 30, "medium"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Italian Pancakes with Nutella", 15, "easy"),
            ("Saturday", 5, "lunch", "Antipasti Platter", 20, "easy"),
            ("Saturday", 5, "dinner", "Veal Marsala with Pasta", 45, "hard"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Bomboloni and Espresso", 15, "medium"),
            ("Sunday", 6, "lunch", "Caesar Salad (Italian Style)", 15, "easy"),
            ("Sunday", 6, "dinner", "Lasagna Bolognese", 90, "hard")
        ])
        
        return (template, meals)
    }
    
    private func createComfortFoodTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Ultimate Comfort Food",
            description: "Soul-warming, hearty meals that bring back childhood memories and satisfy your cravings",
            category: TemplateCategory.comfort.rawValue,
            difficulty: "Beginner",
            durationDays: 7,
            estimatedCostMin: 65.0,
            estimatedCostMax: 85.0,
            imageUrl: nil,
            tags: ["comfort", "hearty", "satisfying", "nostalgic", "warm"],
            isActive: true,
            icon: "🍴",
            colorScheme: "pink",
            targetCaloriesPerDay: 2500,
            macros: MacroDistribution(protein: 20, carbs: 45, fat: 35)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Fluffy Pancakes with Bacon", 20, "easy"),
            ("Monday", 0, "lunch", "Grilled Cheese and Tomato Soup", 20, "easy"),
            ("Monday", 0, "dinner", "Meatloaf with Mashed Potatoes", 60, "medium"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Biscuits and Gravy", 25, "medium"),
            ("Tuesday", 1, "lunch", "Mac and Cheese", 15, "easy"),
            ("Tuesday", 1, "dinner", "Fried Chicken with Coleslaw", 45, "medium"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "French Toast with Syrup", 15, "easy"),
            ("Wednesday", 2, "lunch", "Chicken Noodle Soup", 30, "medium"),
            ("Wednesday", 2, "dinner", "Beef Pot Roast with Vegetables", 180, "easy"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Eggs Benedict", 20, "medium"),
            ("Thursday", 3, "lunch", "Tuna Melt Sandwich", 10, "easy"),
            ("Thursday", 3, "dinner", "Spaghetti and Meatballs", 40, "medium"),
            
            // Friday
            ("Friday", 4, "breakfast", "Belgian Waffles with Berries", 20, "medium"),
            ("Friday", 4, "lunch", "Fish and Chips", 30, "medium"),
            ("Friday", 4, "dinner", "BBQ Ribs with Cornbread", 120, "medium"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Full English Breakfast", 30, "medium"),
            ("Saturday", 5, "lunch", "Chili with Cornbread", 45, "medium"),
            ("Saturday", 5, "dinner", "Shepherd's Pie", 60, "medium"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Cinnamon Rolls and Coffee", 45, "medium"),
            ("Sunday", 6, "lunch", "Chicken and Dumplings", 60, "medium"),
            ("Sunday", 6, "dinner", "Sunday Roast with Yorkshire Pudding", 120, "hard")
        ])
        
        return (template, meals)
    }
    
    private func createHighProteinTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "High-Protein Fitness Week",
            description: "Protein-packed meals designed for muscle building, recovery, and athletic performance",
            category: "High-Protein",
            difficulty: "Intermediate",
            durationDays: 7,
            estimatedCostMin: 90.0,
            estimatedCostMax: 130.0,
            imageUrl: nil,
            tags: ["high-protein", "fitness", "muscle-building", "recovery", "athletic"],
            isActive: true,
            icon: "💪",
            colorScheme: "purple",
            targetCaloriesPerDay: 2400,
            macros: MacroDistribution(protein: 30, carbs: 30, fat: 40)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Protein Pancakes with Greek Yogurt", 15, "medium"),
            ("Monday", 0, "lunch", "Grilled Chicken Power Bowl", 25, "medium"),
            ("Monday", 0, "dinner", "Steak with Sweet Potato", 30, "medium"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Egg White Omelet with Spinach", 15, "easy"),
            ("Tuesday", 1, "lunch", "Tuna and Quinoa Salad", 15, "easy"),
            ("Tuesday", 1, "dinner", "Salmon with Asparagus", 25, "medium"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Protein Smoothie Bowl", 10, "easy"),
            ("Wednesday", 2, "lunch", "Turkey and Avocado Wrap", 10, "easy"),
            ("Wednesday", 2, "dinner", "Lean Beef Stir Fry", 25, "medium"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Cottage Cheese with Berries", 5, "easy"),
            ("Thursday", 3, "lunch", "Chicken Caesar Salad", 20, "easy"),
            ("Thursday", 3, "dinner", "Baked Cod with Vegetables", 30, "medium"),
            
            // Friday
            ("Friday", 4, "breakfast", "Protein French Toast", 20, "medium"),
            ("Friday", 4, "lunch", "Protein-Packed Lentil Soup", 30, "medium"),
            ("Friday", 4, "dinner", "Grilled Chicken Breast with Broccoli", 25, "easy"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Post-Workout Protein Shake", 5, "easy"),
            ("Saturday", 5, "lunch", "Quinoa Power Bowl", 20, "medium"),
            ("Saturday", 5, "dinner", "Lean Turkey Meatballs", 35, "medium"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "High-Protein Overnight Oats", 5, "easy"),
            ("Sunday", 6, "lunch", "Chicken and Bean Salad", 15, "easy"),
            ("Sunday", 6, "dinner", "Protein-Packed Chili", 45, "medium")
        ])
        
        return (template, meals)
    }
    
    private func createVegetarianTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Plant-Powered Vegetarian",
            description: "Delicious vegetarian meals full of flavor, nutrients, and satisfying plant-based proteins",
            category: TemplateCategory.vegetarian.rawValue,
            difficulty: "Intermediate",
            durationDays: 7,
            estimatedCostMin: 60.0,
            estimatedCostMax: 80.0,
            imageUrl: nil,
            tags: ["vegetarian", "plant-based", "nutritious", "colorful", "sustainable"],
            isActive: true,
            icon: "🌱",
            colorScheme: "green",
            targetCaloriesPerDay: 2200,
            macros: MacroDistribution(protein: 20, carbs: 40, fat: 40)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Avocado Toast with Hemp Seeds", 10, "easy"),
            ("Monday", 0, "lunch", "Quinoa Buddha Bowl", 25, "medium"),
            ("Monday", 0, "dinner", "Eggplant Parmesan", 45, "medium"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Chia Pudding with Berries", 5, "easy"),
            ("Tuesday", 1, "lunch", "Caprese Stuffed Portobello", 20, "medium"),
            ("Tuesday", 1, "dinner", "Vegetarian Chili with Cornbread", 40, "medium"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Green Smoothie with Protein", 10, "easy"),
            ("Wednesday", 2, "lunch", "Mediterranean Chickpea Salad", 15, "easy"),
            ("Wednesday", 2, "dinner", "Stuffed Bell Peppers with Rice", 45, "medium"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Oatmeal with Nuts and Seeds", 10, "easy"),
            ("Thursday", 3, "lunch", "Black Bean and Sweet Potato Tacos", 25, "medium"),
            ("Thursday", 3, "dinner", "Mushroom Risotto", 35, "hard"),
            
            // Friday
            ("Friday", 4, "breakfast", "Tofu Scramble with Vegetables", 15, "medium"),
            ("Friday", 4, "lunch", "Falafel with Tahini Sauce", 30, "medium"),
            ("Friday", 4, "dinner", "Vegetarian Pad Thai", 25, "medium"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Acai Bowl with Granola", 10, "easy"),
            ("Saturday", 5, "lunch", "Roasted Vegetable and Hummus Wrap", 20, "easy"),
            ("Saturday", 5, "dinner", "Spinach and Ricotta Lasagna", 60, "hard"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Vegetarian Benedict with Hollandaise", 25, "hard"),
            ("Sunday", 6, "lunch", "Lentil and Vegetable Curry", 35, "medium"),
            ("Sunday", 6, "dinner", "Stuffed Acorn Squash", 50, "medium")
        ])
        
        return (template, meals)
    }
    
    private func createFamilyStyleTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Family-Style Favorites",
            description: "Large-portion, kid-friendly meals perfect for families and meal prepping",
            category: TemplateCategory.family.rawValue,
            difficulty: "Beginner",
            durationDays: 7,
            estimatedCostMin: 70.0,
            estimatedCostMax: 100.0,
            imageUrl: nil,
            tags: ["family-friendly", "kid-approved", "large-portions", "meal-prep", "easy"],
            isActive: true,
            icon: "👨‍👩‍👧‍👦",
            colorScheme: "orange",
            targetCaloriesPerDay: 2800,
            macros: MacroDistribution(protein: 25, carbs: 40, fat: 35)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Family Pancake Stack", 20, "easy"),
            ("Monday", 0, "lunch", "Chicken Nuggets with Sweet Potato Fries", 25, "easy"),
            ("Monday", 0, "dinner", "Family Taco Night", 30, "easy"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Overnight French Toast Casserole", 15, "easy"),
            ("Tuesday", 1, "lunch", "Mini Pizzas", 20, "easy"),
            ("Tuesday", 1, "dinner", "Slow Cooker Chicken and Rice", 15, "easy"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Breakfast Burritos (Make-Ahead)", 10, "easy"),
            ("Wednesday", 2, "lunch", "Grilled Cheese and Tomato Soup", 20, "easy"),
            ("Wednesday", 2, "dinner", "Baked Ziti with Garlic Bread", 45, "medium"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Muffins and Fresh Fruit", 30, "easy"),
            ("Thursday", 3, "lunch", "Chicken Quesadillas", 15, "easy"),
            ("Thursday", 3, "dinner", "Meatball Subs", 35, "medium"),
            
            // Friday
            ("Friday", 4, "breakfast", "Cereal Bar Setup", 5, "easy"),
            ("Friday", 4, "lunch", "Hot Dogs with Baked Beans", 15, "easy"),
            ("Friday", 4, "dinner", "Homemade Pizza Night", 30, "medium"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Weekend Brunch Spread", 45, "medium"),
            ("Saturday", 5, "lunch", "Chicken Salad Sandwiches", 15, "easy"),
            ("Saturday", 5, "dinner", "BBQ Pulled Pork with Coleslaw", 120, "easy"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Sunday Morning Waffles", 25, "easy"),
            ("Sunday", 6, "lunch", "Leftover Buffet", 10, "easy"),
            ("Sunday", 6, "dinner", "Family Roast Chicken Dinner", 90, "medium")
        ])
        
        return (template, meals)
    }
    
    private func createKetoTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Ketogenic Lifestyle",
            description: "Low-carb, high-fat meals designed for ketogenic diet and weight management",
            category: TemplateCategory.keto.rawValue,
            difficulty: "Intermediate", 
            durationDays: 7,
            estimatedCostMin: 85.0,
            estimatedCostMax: 115.0,
            imageUrl: nil,
            tags: ["keto", "low-carb", "high-fat", "weight-loss", "ketogenic"],
            isActive: true,
            icon: "🥑",
            colorScheme: "purple",
            targetCaloriesPerDay: 2000,
            macros: MacroDistribution(protein: 20, carbs: 30, fat: 50)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Keto Coffee and Bacon Eggs", 15, "easy"),
            ("Monday", 0, "lunch", "Avocado Chicken Salad", 15, "easy"),
            ("Monday", 0, "dinner", "Steak with Butter and Asparagus", 25, "medium"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Cheese and Spinach Omelet", 15, "easy"),
            ("Tuesday", 1, "lunch", "Tuna Salad Lettuce Wraps", 10, "easy"),
            ("Tuesday", 1, "dinner", "Salmon with Creamy Spinach", 25, "medium"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Keto Smoothie with MCT Oil", 10, "easy"),
            ("Wednesday", 2, "lunch", "Caesar Salad with Chicken", 15, "easy"),
            ("Wednesday", 2, "dinner", "Pork Chops with Cauliflower Mash", 30, "medium"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Avocado and Egg Bowl", 10, "easy"),
            ("Thursday", 3, "lunch", "Keto Cobb Salad", 15, "easy"),
            ("Thursday", 3, "dinner", "Lamb with Greek Salad", 35, "medium"),
            
            // Friday
            ("Friday", 4, "breakfast", "Cream Cheese Pancakes", 15, "medium"),
            ("Friday", 4, "lunch", "Keto Chicken Wraps", 15, "easy"),
            ("Friday", 4, "dinner", "Ribeye with Roasted Brussels Sprouts", 30, "medium"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Keto Breakfast Casserole", 45, "medium"),
            ("Saturday", 5, "lunch", "Antipasto Plate", 10, "easy"),
            ("Saturday", 5, "dinner", "Keto Lasagna with Zucchini", 60, "hard"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Keto Benedict with Portobello", 25, "medium"),
            ("Sunday", 6, "lunch", "Buffalo Chicken Salad", 15, "easy"),
            ("Sunday", 6, "dinner", "Prime Rib with Garlic Butter Vegetables", 90, "hard")
        ])
        
        return (template, meals)
    }
    
    private func createMealPrepTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Meal Prep Master",
            description: "Efficient meal prep recipes designed for batch cooking and easy weekly planning",
            category: "Meal Prep",
            difficulty: "Intermediate",
            durationDays: 7,
            estimatedCostMin: 65.0,
            estimatedCostMax: 90.0,
            imageUrl: nil,
            tags: ["meal-prep", "batch-cooking", "efficient", "time-saving", "containers"],
            isActive: true,
            icon: "🥣",
            colorScheme: "blue",
            targetCaloriesPerDay: 2200,
            macros: MacroDistribution(protein: 25, carbs: 40, fat: 35)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday
            ("Monday", 0, "breakfast", "Overnight Oats (5 portions)", 15, "easy"),
            ("Monday", 0, "lunch", "Chicken and Rice Bowls (5 portions)", 60, "medium"),
            ("Monday", 0, "dinner", "Sheet Pan Chicken with Vegetables", 45, "easy"),
            
            // Tuesday
            ("Tuesday", 1, "breakfast", "Breakfast Muffins (12 portions)", 45, "medium"),
            ("Tuesday", 1, "lunch", "Mason Jar Salads (5 portions)", 30, "easy"),
            ("Tuesday", 1, "dinner", "Slow Cooker Beef Stew", 15, "easy"),
            
            // Wednesday
            ("Wednesday", 2, "breakfast", "Egg Muffin Cups (12 portions)", 30, "medium"),
            ("Wednesday", 2, "lunch", "Quinoa Power Bowls (5 portions)", 40, "medium"),
            ("Wednesday", 2, "dinner", "Batch Cooked Ground Turkey", 30, "easy"),
            
            // Thursday
            ("Thursday", 3, "breakfast", "Chia Pudding Parfaits (5 portions)", 15, "easy"),
            ("Thursday", 3, "lunch", "Soup and Sandwich Combos", 45, "medium"),
            ("Thursday", 3, "dinner", "One-Pan Salmon and Vegetables", 25, "easy"),
            
            // Friday
            ("Friday", 4, "breakfast", "Smoothie Prep Packs (5 portions)", 20, "easy"),
            ("Friday", 4, "lunch", "Buddha Bowl Components", 60, "medium"),
            ("Friday", 4, "dinner", "Freezer-Friendly Enchiladas", 60, "medium"),
            
            // Saturday
            ("Saturday", 5, "breakfast", "Weekend Pancake Batch", 30, "easy"),
            ("Saturday", 5, "lunch", "Prep-Ahead Wraps", 25, "easy"),
            ("Saturday", 5, "dinner", "Batch Cooking: Proteins and Grains", 90, "medium"),
            
            // Sunday
            ("Sunday", 6, "breakfast", "Prep Day: Cut Fruits and Vegetables", 30, "easy"),
            ("Sunday", 6, "lunch", "Sunday Meal Prep Assembly", 60, "easy"),
            ("Sunday", 6, "dinner", "Week Planning and Prep Wrap-up", 45, "easy")
        ])
        
        return (template, meals)
    }
    
    private func createGlobalCuisineTemplate() -> (template: CreateMealPlanTemplateRequest, meals: [CreateTemplateMealRequest]) {
        let template = CreateMealPlanTemplateRequest(
            name: "Around the World",
            description: "A culinary journey featuring authentic dishes from different countries and cultures",
            category: "Global Cuisine",
            difficulty: "Advanced",
            durationDays: 7,
            estimatedCostMin: 95.0,
            estimatedCostMax: 140.0,
            imageUrl: nil,
            tags: ["international", "diverse", "cultural", "authentic", "adventurous"],
            isActive: true,
            icon: "🌎",
            colorScheme: "purple",
            targetCaloriesPerDay: 2500,
            macros: MacroDistribution(protein: 25, carbs: 40, fat: 35)
        )
        
        let meals = createWeekMeals(templateId: "", meals: [
            // Monday - French
            ("Monday", 0, "breakfast", "French Croissants with Café au Lait", 20, "medium"),
            ("Monday", 0, "lunch", "Croque Monsieur", 25, "medium"),
            ("Monday", 0, "dinner", "Coq au Vin with Potatoes", 120, "hard"),
            
            // Tuesday - Indian
            ("Tuesday", 1, "breakfast", "Masala Chai with Paratha", 30, "medium"),
            ("Tuesday", 1, "lunch", "Chicken Tikka Masala with Naan", 45, "hard"),
            ("Tuesday", 1, "dinner", "Lamb Biryani", 90, "hard"),
            
            // Wednesday - Japanese
            ("Wednesday", 2, "breakfast", "Traditional Japanese Breakfast", 30, "hard"),
            ("Wednesday", 2, "lunch", "Chicken Katsu Curry", 40, "medium"),
            ("Wednesday", 2, "dinner", "Sushi and Miso Soup", 60, "hard"),
            
            // Thursday - Moroccan
            ("Thursday", 3, "breakfast", "Moroccan Mint Tea and Pastries", 15, "easy"),
            ("Thursday", 3, "lunch", "Chicken Tagine", 60, "hard"),
            ("Thursday", 3, "dinner", "Lamb Couscous", 75, "hard"),
            
            // Friday - Brazilian
            ("Friday", 4, "breakfast", "Açaí Bowl with Tropical Fruits", 15, "easy"),
            ("Friday", 4, "lunch", "Feijoada (Black Bean Stew)", 90, "hard"),
            ("Friday", 4, "dinner", "Grilled Picanha with Farofa", 45, "medium"),
            
            // Saturday - Greek
            ("Saturday", 5, "breakfast", "Greek Yogurt with Honey and Nuts", 10, "easy"),
            ("Saturday", 5, "lunch", "Moussaka", 90, "hard"),
            ("Saturday", 5, "dinner", "Souvlaki with Greek Salad", 35, "medium"),
            
            // Sunday - Ethiopian
            ("Sunday", 6, "breakfast", "Ethiopian Coffee Ceremony", 45, "hard"),
            ("Sunday", 6, "lunch", "Injera with Various Stews", 120, "hard"),
            ("Sunday", 6, "dinner", "Doro Wat (Chicken Stew)", 90, "hard")
        ])
        
        return (template, meals)
    }
    
    deinit {
        fetchTask?.cancel()
    }
} 
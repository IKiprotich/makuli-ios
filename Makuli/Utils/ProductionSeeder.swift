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
    
    static func seedProductionDatabase() async throws {
        ProductionLogger.logInfo("Starting production database seeding", context: "ProductionSeeder")
        
        do {
            if Configuration.isProduction {
                ProductionLogger.logInfo("Clearing existing templates in production")
                try await clearExistingTemplates()
            }
            
            try await seedAllRecipes()
            
            try await seedAllMealPlanTemplates()
            
            try await verifySeededData()
            
            ProductionLogger.logInfo("Production database seeding completed successfully", context: "ProductionSeeder")
            
        } catch {
            ProductionLogger.logError(error, context: "ProductionSeeder.seedProductionDatabase")
            throw error
        }
    }
    
    static func quickSeed() async throws {
        try await seedProductionDatabase()
    }

    static func seedSamplePlansForCurrentUser() async throws {
        ProductionLogger.logInfo("Seeding sample plans for current user", context: "ProductionSeeder")

        let session = try await supabase.auth.session
        let userId = session.user.id.uuidString

        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let weekday = cal.component(.weekday, from: today)
        let daysToMonday = (weekday == 2) ? 0 : ((9 - weekday) % 7)
        let thisMonday = cal.date(byAdding: .day, value: -((weekday == 1 ? 6 : weekday - 2)), to: today)!
        let lastMonday = cal.date(byAdding: .day, value: -7, to: thisMonday)!

        let currentPlanMeals: [(Int, String, String, Int?, Bool)] = [
            (1, "breakfast", "Avocado Toast with Poached Eggs",   10, true),
            (1, "lunch",     "Roasted Vegetable Quinoa Bowl",      30, true),
            (1, "dinner",    "Mediterranean Herb-Crusted Salmon",  20, true),
            (2, "breakfast", "Spinach & Feta Omelette",             8, true),
            (2, "lunch",     "Classic Caesar Salad",               10, true),
            (2, "dinner",    "Wild Mushroom Risotto",              35, true),
            (3, "breakfast", "Greek Yogurt Parfait with Granola",   0, false),
            (3, "lunch",     "Tuna Niçoise Salad",                 15, false),
            (3, "dinner",    "Chicken Tikka Masala",               40, false),
            (4, "breakfast", "Overnight Oats with Chia & Berries",  0, false),
            (4, "lunch",     "Spiced Red Lentil Soup",             35, false),
            (4, "dinner",    "Classic Spaghetti Bolognese",        60, false),
            (5, "breakfast", "Banana Protein Pancakes",            15, false),
            (5, "lunch",     "Turkey & Avocado Club Wrap",          5, false),
            (5, "dinner",    "Herb Butter Roast Chicken",          90, false),
            (6, "breakfast", "Shakshuka with Feta",                25, false),
            (6, "lunch",     "Korean Bibimbap Bowl",               30, false),
            (6, "dinner",    "Korean Beef Bulgogi",                15, false),
            (0, "breakfast", "Acai Power Bowl",                     0, false),
            (0, "lunch",     "Fresh Vietnamese Spring Rolls",      15, false),
            (0, "dinner",    "Thai Green Curry with Tofu",         25, false),
        ]

        let lastWeekMeals: [(Int, String, String, Int?, Bool)] = [
            (1, "breakfast", "Overnight Oats with Chia & Berries",  0, true),
            (1, "lunch",     "Thai Peanut Noodles",                 15, true),
            (1, "dinner",    "Korean Beef Bulgogi",                 15, true),
            (2, "breakfast", "Greek Yogurt Parfait with Granola",    0, true),
            (2, "lunch",     "Korean Bibimbap Bowl",                30, true),
            (2, "dinner",    "Classic Pad Thai with Prawns",        20, true),
            (3, "breakfast", "Banana Protein Pancakes",             15, true),
            (3, "lunch",     "Fresh Vietnamese Spring Rolls",       15, true),
            (3, "dinner",    "Thai Green Curry with Tofu",          25, true),
            (4, "breakfast", "Spinach & Feta Omelette",              8, true),
            (4, "lunch",     "Thai Peanut Noodles",                 15, true),
            (4, "dinner",    "Chicken Tikka Masala",                40, true),
            (5, "breakfast", "Overnight Oats with Chia & Berries",   0, true),
            (5, "lunch",     "Korean Bibimbap Bowl",                30, true),
            (5, "dinner",    "Korean Beef Bulgogi",                 15, true),
            (6, "breakfast", "Avocado Toast with Poached Eggs",     10, true),
            (6, "lunch",     "Fresh Vietnamese Spring Rolls",       15, true),
            (6, "dinner",    "Classic Pad Thai with Prawns",        20, true),
            (0, "breakfast", "Shakshuka with Feta",                 25, true),
            (0, "lunch",     "Thai Peanut Noodles",                 15, true),
            (0, "dinner",    "Thai Green Curry with Tofu",          25, true),
        ]

        let kenyaWeekMeals: [(Int, String, String, Int?, Bool)] = [
            (1, "breakfast", "Mandazi with Kenyan Chai",                   20, true),
            (1, "lunch",     "Githeri (Maize & Bean Stew)",                 90, true),
            (1, "dinner",    "Nyama Choma (Kenyan Grilled Goat)",           60, true),
            (2, "breakfast", "Uji wa Wimbi (Finger Millet Porridge)",       15, true),
            (2, "lunch",     "Mukimo with Sukuma Wiki",                     30, true),
            (2, "dinner",    "Mchuzi wa Kuku (Kenyan Chicken Stew)",        50, true),
            (3, "breakfast", "Scrambled Eggs with Sukuma Wiki",             10, true),
            (3, "lunch",     "Kenyan Chapati with Maharagwe ya Nazi",       50, true),
            (3, "dinner",    "Kenyan Pilau",                                50, true),
            (4, "breakfast", "Mandazi with Kenyan Chai",                   20, false),
            (4, "lunch",     "Viazi Karai (Potato Fritters)",               25, false),
            (4, "dinner",    "Samaki wa Nazi (Coastal Fish in Coconut)",    30, false),
            (5, "breakfast", "Githeri Breakfast Bowl",                     20, false),
            (5, "lunch",     "Mukimo with Sukuma Wiki",                     30, false),
            (5, "dinner",    "Ugali na Mchuzi wa Kuku",                    50, false),
            (6, "breakfast", "Vitumbua (Coconut Rice Pancakes)",           20, false),
            (6, "lunch",     "Kenyan Pilau",                               50, false),
            (6, "dinner",    "Nyama Choma (Kenyan Grilled Goat)",          60, false),
            (0, "breakfast", "Mandazi with Kenyan Chai",                   20, false),
            (0, "lunch",     "Githeri (Maize & Bean Stew)",                90, false),
            (0, "dinner",    "Maharagwe ya Nazi (Coconut Kidney Beans)",   60, false),
        ]

        let twoWeeksAgo = cal.date(byAdding: .day, value: -7, to: lastMonday)!

        let plans: [(title: String, weekStart: Date, weekEnd: Date, meals: [(Int, String, String, Int?, Bool)], completionPct: Double)] = [
            ("Mediterranean Week",  thisMonday,   cal.date(byAdding: .day, value: 6, to: thisMonday)!,   currentPlanMeals, 28.6),
            ("Asian Fusion Week",   lastMonday,   cal.date(byAdding: .day, value: 6, to: lastMonday)!,   lastWeekMeals,   100.0),
            ("Kenyan Cuisine Week", twoWeeksAgo,  cal.date(byAdding: .day, value: 6, to: twoWeeksAgo)!,  kenyaWeekMeals,  100.0),
        ]

        let isoFormatter = ISO8601DateFormatter()

        for planData in plans {
            struct PlanInsert: Encodable {
                let user_id: String
                let title: String
                let week_start: String
                let week_end: String
                let is_completed: Bool
                let completion_percentage: Double
                let generation_method: String
                let is_favorite: Bool
            }

            let planInsert = PlanInsert(
                user_id: userId,
                title: planData.title,
                week_start: isoFormatter.string(from: planData.weekStart),
                week_end: isoFormatter.string(from: planData.weekEnd),
                is_completed: planData.completionPct >= 100,
                completion_percentage: planData.completionPct,
                generation_method: "template",
                is_favorite: planData.completionPct >= 100
            )

            let planResponse = try await supabase
                .from("plans")
                .insert(planInsert)
                .select("id")
                .single()
                .execute()

            guard let planId = try? JSONDecoder()
                .decode([String: String].self, from: planResponse.data)["id"] else {
                ProductionLogger.logInfo("Could not extract plan ID, skipping meals for \(planData.title)")
                continue
            }

            let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

            for (position, meal) in planData.meals.enumerated() {
                let (dayOfWeek, mealType, mealName, cookTime, isCompleted) = meal

                struct PlanRecipeInsert: Encodable {
                    let plan_id: String
                    let day_of_week: Int
                    let meal_type: String
                    let position: Int
                    let day: String
                    let is_completed: Bool
                    let custom_meal_name: String
                    let custom_cook_time: Int?
                    let custom_image_url: String?
                }

                let recipeInsert = PlanRecipeInsert(
                    plan_id: planId,
                    day_of_week: dayOfWeek,
                    meal_type: mealType,
                    position: position,
                    day: days[dayOfWeek],
                    is_completed: isCompleted,
                    custom_meal_name: mealName,
                    custom_cook_time: cookTime,
                    custom_image_url: mealImageURL(for: mealName)
                )

                try await supabase
                    .from("plan_recipes")
                    .insert(recipeInsert)
                    .execute()
            }

            ProductionLogger.logInfo("Seeded plan '\(planData.title)' with \(planData.meals.count) meals")
        }

        ProductionLogger.logInfo("Sample plans seeded successfully for user \(userId)")
    }

    // MARK: - Meal Image Lookup

    static func mealImageURL(for name: String) -> String? {
        let n = name.lowercased()
        if n.contains("nyama choma")        { return "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80" }
        if n.contains("pilau")              { return "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80" }
        if n.contains("ugali")              { return "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80" }
        if n.contains("githeri")            { return "https://images.unsplash.com/photo-1574926054530-4bcf145fe25e?auto=format&fit=crop&w=800&q=80" }
        if n.contains("mukimo")             { return "https://images.unsplash.com/photo-1466637574441-749b8f19452f?auto=format&fit=crop&w=800&q=80" }
        if n.contains("mandazi")            { return "https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=800&q=80" }
        if n.contains("maharagwe")          { return "https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80" }
        if n.contains("chapati")            { return "https://images.unsplash.com/photo-1574894709920-11b28e7367e3?auto=format&fit=crop&w=800&q=80" }
        if n.contains("mchuzi wa kuku")     { return "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=800&q=80" }
        if n.contains("mchuzi")             { return "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=800&q=80" }
        if n.contains("viazi karai")        { return "https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=800&q=80" }
        if n.contains("samaki wa nazi")     { return "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=800&q=80" }
        if n.contains("samaki")             { return "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=800&q=80" }
        if n.contains("vitumbua")           { return "https://images.unsplash.com/photo-1567620832903-9fc6debc209f?auto=format&fit=crop&w=800&q=80" }
        if n.contains("uji")                { return "https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80" }
        if n.contains("matoke")             { return "https://images.unsplash.com/photo-1571748982800-fa51082c2224?auto=format&fit=crop&w=800&q=80" }
        if n.contains("sukuma wiki")        { return "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80" }
        if n.contains("kenyan chai")        { return "https://images.unsplash.com/photo-1564890369478-c89ca6d9cde9?auto=format&fit=crop&w=800&q=80" }
        if n.contains("avocado toast")      { return "https://images.unsplash.com/photo-1541519227354-08fa5d50c820?auto=format&fit=crop&w=800&q=80" }
        if n.contains("shakshuka")          { return "https://images.unsplash.com/photo-1590412200988-a436970781fa?auto=format&fit=crop&w=800&q=80" }
        if n.contains("greek yogurt parfait") || n.contains("yogurt parfait") { return "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=800&q=80" }
        if n.contains("banana protein pancake") || (n.contains("pancake") && n.contains("protein")) { return "https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=800&q=80" }
        if n.contains("overnight oats")     { return "https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80" }
        if n.contains("spinach") && n.contains("omelette") { return "https://images.unsplash.com/photo-1612240498936-65f5101365d2?auto=format&fit=crop&w=800&q=80" }
        if n.contains("scrambled eggs")     { return "https://images.unsplash.com/photo-1612240498936-65f5101365d2?auto=format&fit=crop&w=800&q=80" }
        if n.contains("acai")               { return "https://images.unsplash.com/photo-1590301157284-f0c7a08e0bef?auto=format&fit=crop&w=800&q=80" }
        if n.contains("pancake")            { return "https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=800&q=80" }
        if n.contains("porridge") || n.contains("oats") { return "https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80" }
        if n.contains("omelette") || n.contains("frittata") { return "https://images.unsplash.com/photo-1612240498936-65f5101365d2?auto=format&fit=crop&w=800&q=80" }
        if n.contains("caesar salad")       { return "https://images.unsplash.com/photo-1550304943-4f24f54ddde9?auto=format&fit=crop&w=800&q=80" }
        if n.contains("quinoa bowl") || n.contains("roasted vegetable") { return "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80" }
        if n.contains("niçoise") || n.contains("nicoise") { return "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=800&q=80" }
        if n.contains("bibimbap")           { return "https://images.unsplash.com/photo-1590301157890-4810ed352733?auto=format&fit=crop&w=800&q=80" }
        if n.contains("spring rolls")       { return "https://images.unsplash.com/photo-1562802378-063ec186a863?auto=format&fit=crop&w=800&q=80" }
        if n.contains("peanut noodle")      { return "https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?auto=format&fit=crop&w=800&q=80" }
        if n.contains("lentil soup")        { return "https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80" }
        if n.contains("soup")               { return "https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80" }
        if n.contains("turkey") && n.contains("wrap") { return "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80" }
        if n.contains("shawarma")           { return "https://images.unsplash.com/photo-1529006557810-274b9b2fc783?auto=format&fit=crop&w=800&q=80" }
        if n.contains("taco")               { return "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=800&q=80" }
        if n.contains("wrap")               { return "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80" }
        if n.contains("jollof")             { return "https://images.unsplash.com/photo-1536304993881-ff86d57456de?auto=format&fit=crop&w=800&q=80" }
        if n.contains("biryani")            { return "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80" }
        if n.contains("fried rice")         { return "https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80" }
        if n.contains("risotto")            { return "https://images.unsplash.com/photo-1476124369491-e7addf5db371?auto=format&fit=crop&w=800&q=80" }
        if n.contains("rice")               { return "https://images.unsplash.com/photo-1512058564366-18510be2db19?auto=format&fit=crop&w=800&q=80" }
        if n.contains("spaghetti bolognese") || n.contains("bolognese") { return "https://images.unsplash.com/photo-1598103442097-8b74394b95c1?auto=format&fit=crop&w=800&q=80" }
        if n.contains("pad thai")           { return "https://images.unsplash.com/photo-1559314809-0d155014e29e?auto=format&fit=crop&w=800&q=80" }
        if n.contains("pasta")              { return "https://images.unsplash.com/photo-1598103442097-8b74394b95c1?auto=format&fit=crop&w=800&q=80" }
        if n.contains("tikka masala")       { return "https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80" }
        if n.contains("thai green curry") || (n.contains("green curry")) { return "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?auto=format&fit=crop&w=800&q=80" }
        if n.contains("curry")              { return "https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80" }
        if n.contains("stew")               { return "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=800&q=80" }
        if n.contains("salmon")             { return "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80" }
        if n.contains("bulgogi")            { return "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80" }
        if n.contains("roast chicken") || n.contains("herb butter") { return "https://images.unsplash.com/photo-1598866594230-a7c12756260f?auto=format&fit=crop&w=800&q=80" }
        if n.contains("chicken")            { return "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=800&q=80" }
        if n.contains("kofta")              { return "https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=800&q=80" }
        if n.contains("grilled")            { return "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80" }
        if n.contains("fish") || n.contains("seafood") { return "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=800&q=80" }
        if n.contains("enchilada")          { return "https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?auto=format&fit=crop&w=800&q=80" }
        if n.contains("mushroom")           { return "https://images.unsplash.com/photo-1476124369491-e7addf5db371?auto=format&fit=crop&w=800&q=80" }
        if n.contains("aubergine") || n.contains("eggplant") { return "https://images.unsplash.com/photo-1481304453051-c5f7a1a6c0b0?auto=format&fit=crop&w=800&q=80" }
        if n.contains("hummus")             { return "https://images.unsplash.com/photo-1534939561126-855b8675edd7?auto=format&fit=crop&w=800&q=80" }
        if n.contains("bean") || n.contains("lentil") { return "https://images.unsplash.com/photo-1574926054530-4bcf145fe25e?auto=format&fit=crop&w=800&q=80" }
        if n.contains("vegetable") || n.contains("veggie") { return "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80" }
        if n.contains("breakfast")          { return "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=800&q=80" }
        if n.contains("salad")              { return "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=800&q=80" }
        if n.contains("bowl")               { return "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80" }
        return nil
    }

    // MARK: - Recipe Seeding
    
    private static func seedAllRecipes() async throws {
        ProductionLogger.logInfo("Seeding recipes database", context: "ProductionSeeder")
        
        let session = try await supabase.auth.session
        let currentUserId = session.user.id.uuidString
        
        let recipeData = getAllProductionRecipes()
        
        for recipe in recipeData {
            do {
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
                )
                
                try await supabase
                    .from("recipes")
                    .insert(createRequest)
                    .execute()
                
                ProductionLogger.logInfo("Seeded recipe: \(recipe["title"] ?? "Unknown")")
                
            } catch {
                ProductionLogger.logError(error, context: "Seeding recipe: \(recipe["title"] ?? "Unknown")")
            }
        }
        
        ProductionLogger.logInfo("Completed seeding \(recipeData.count) recipes")
    }
    
    // MARK: - Template Seeding
    
    private static func seedAllMealPlanTemplates() async throws {
        ProductionLogger.logInfo("Seeding meal plan templates", context: "ProductionSeeder")
        
        let session = try await supabase.auth.session
        let currentUserId = session.user.id.uuidString
        
        let templates = getAllProductionTemplates()
        
        for template in templates {
            do {
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
                    icon: template.icon,
                    colorScheme: nil,
                    targetCaloriesPerDay: nil,
                    macros: nil,
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
        
        let templatesResponse = try await supabase
            .from("meal_plan_templates")
            .select("id, name")
            .execute()
        
        let templateCount = try extractCount(from: templatesResponse)
        ProductionLogger.logInfo("Verified \(templateCount) templates in database")
        
        let mealsResponse = try await supabase
            .from("template_meals")
            .select("id")
            .execute()
        
        let mealCount = try extractCount(from: mealsResponse)
        ProductionLogger.logInfo("Verified \(mealCount) template meals in database")
        
        let recipesResponse = try await supabase
            .from("recipes")
            .select("id")
            .execute()
        
        let recipeCount = try extractCount(from: recipesResponse)
        ProductionLogger.logInfo("Verified \(recipeCount) recipes in database")
        
        if templateCount < 5 || mealCount < 50 || recipeCount < 20 {
            throw ProductionSeederError.verificationFailed("Insufficient data seeded")
        }
        
        ProductionLogger.logInfo("Data verification completed successfully")
    }
    
    // MARK: - Cleanup Functions
    
    private static func clearExistingTemplates() async throws {
        try await supabase
            .from("template_meals")
            .delete()
            .neq("template_id", value: "00000000-0000-0000-0000-000000000000")
            .execute()
        
        try await supabase
            .from("meal_plan_templates")
            .delete()
            .neq("id", value: "00000000-0000-0000-0000-000000000000")
            .execute()
        
        ProductionLogger.logInfo("Cleared existing templates from database")
    }
    
    // MARK: - Helper Functions
    
    private static func extractId(from response: Any) -> String? {
        if let data = response as? [String: Any],
           let id = data["id"] as? String {
            return id
        }
        if let dataArray = response as? [[String: Any]],
           let firstItem = dataArray.first,
           let id = firstItem["id"] as? String {
            return id
        }
        return nil
    }
    
    private static func extractCount(from response: Any) -> Int {
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
            ),
            ProductionTemplate(
                name: "Kenyan Cuisine Week",
                description: "Authentic Kenyan and East African flavours — nyama choma, pilau, githeri and more",
                category: "kenyan",
                difficulty: "beginner",
                estimatedCostMin: 40.0,
                estimatedCostMax: 65.0,
                icon: "🇰🇪",
                tags: ["kenyan", "east-african", "traditional", "authentic"]
            ),
        ]
    }
    
    private static func getTemplateMeals(for template: ProductionTemplate) -> [[String: Any]] {
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var meals: [[String: Any]] = []
        var position = 0

        let mealNames = templateMealNames(for: template.category)

        for (dayIndex, day) in days.enumerated() {
            let breakfast = mealNames.breakfasts[dayIndex]
            let lunch = mealNames.lunches[dayIndex]
            let dinner = mealNames.dinners[dayIndex]

            meals.append([
                "day_of_week": dayIndex,
                "meal_type": "breakfast",
                "meal_name": breakfast.name,
                "day": day,
                "cooking_time": breakfast.cookTime,
                "difficulty": "easy",
                "estimated_cost": breakfast.cost,
                "calories": breakfast.calories,
                "prep_time": breakfast.prepTime,
                "position": position,
                "ingredients": breakfast.ingredients,
                "instructions": breakfast.steps
            ])
            position += 1

            meals.append([
                "day_of_week": dayIndex,
                "meal_type": "lunch",
                "meal_name": lunch.name,
                "day": day,
                "cooking_time": lunch.cookTime,
                "difficulty": "medium",
                "estimated_cost": lunch.cost,
                "calories": lunch.calories,
                "prep_time": lunch.prepTime,
                "position": position,
                "ingredients": lunch.ingredients,
                "instructions": lunch.steps
            ])
            position += 1

            meals.append([
                "day_of_week": dayIndex,
                "meal_type": "dinner",
                "meal_name": dinner.name,
                "day": day,
                "cooking_time": dinner.cookTime,
                "difficulty": template.difficulty,
                "estimated_cost": dinner.cost,
                "calories": dinner.calories,
                "prep_time": dinner.prepTime,
                "position": position,
                "ingredients": dinner.ingredients,
                "instructions": dinner.steps
            ])
            position += 1
        }

        return meals
    }

    private struct TemplateMeal {
        let name: String
        let cookTime: Int
        let prepTime: Int
        let calories: Int
        let cost: Double
        let ingredients: [String]
        let steps: [String]
    }

    private struct TemplateWeekMeals {
        let breakfasts: [TemplateMeal]
        let lunches: [TemplateMeal]
        let dinners: [TemplateMeal]
    }

    private static func templateMealNames(for category: String) -> TemplateWeekMeals {
        switch category {
        case "mediterranean":
            return TemplateWeekMeals(
                breakfasts: [
                    TemplateMeal(name: "Greek Yogurt with Honey & Walnuts", cookTime: 0, prepTime: 5, calories: 320, cost: 4.0, ingredients: ["Greek yogurt", "honey", "walnuts", "fresh figs"], steps: ["Spoon yogurt into a bowl", "Drizzle with honey", "Top with walnuts and figs"]),
                    TemplateMeal(name: "Shakshuka with Feta", cookTime: 25, prepTime: 10, calories: 290, cost: 6.0, ingredients: ["eggs", "crushed tomatoes", "feta", "onion", "cumin", "paprika"], steps: ["Sauté onion and spices", "Add tomatoes and simmer", "Add eggs and feta, cook until set"]),
                    TemplateMeal(name: "Avocado Toast with Za'atar", cookTime: 5, prepTime: 5, calories: 340, cost: 4.5, ingredients: ["sourdough bread", "avocado", "za'atar", "lemon", "olive oil"], steps: ["Toast bread", "Mash avocado with lemon", "Top with za'atar and olive oil"]),
                    TemplateMeal(name: "Overnight Oats with Pistachios", cookTime: 0, prepTime: 5, calories: 380, cost: 3.5, ingredients: ["rolled oats", "oat milk", "pistachios", "orange zest", "honey"], steps: ["Combine oats and milk", "Refrigerate overnight", "Top with pistachios and honey"]),
                    TemplateMeal(name: "Spinach & Feta Omelette", cookTime: 8, prepTime: 5, calories: 310, cost: 4.0, ingredients: ["eggs", "spinach", "feta", "olive oil", "garlic"], steps: ["Wilt spinach with garlic", "Pour in eggs", "Add feta and fold"]),
                    TemplateMeal(name: "Mediterranean Frittata", cookTime: 20, prepTime: 10, calories: 350, cost: 7.0, ingredients: ["eggs", "roasted peppers", "olives", "feta", "oregano"], steps: ["Whisk eggs with seasoning", "Add vegetables and cheese", "Bake at 180°C for 15 minutes"]),
                    TemplateMeal(name: "Labneh with Cucumber & Mint", cookTime: 0, prepTime: 5, calories: 280, cost: 3.5, ingredients: ["labneh", "cucumber", "fresh mint", "olive oil", "pitta"], steps: ["Spread labneh on a plate", "Top with cucumber and mint", "Drizzle with olive oil, serve with pitta"]),
                ],
                lunches: [
                    TemplateMeal(name: "Tabbouleh with Grilled Halloumi", cookTime: 10, prepTime: 15, calories: 420, cost: 9.0, ingredients: ["bulgur wheat", "parsley", "tomatoes", "halloumi", "lemon juice", "olive oil"], steps: ["Cook bulgur, cool", "Mix with parsley, tomatoes and dressing", "Grill halloumi and serve on top"]),
                    TemplateMeal(name: "Roasted Vegetable Quinoa Bowl", cookTime: 30, prepTime: 10, calories: 480, cost: 7.5, ingredients: ["quinoa", "courgette", "peppers", "chickpeas", "feta", "lemon"], steps: ["Roast vegetables and chickpeas", "Cook quinoa", "Assemble with feta and lemon"]),
                    TemplateMeal(name: "Greek Salad with Tuna", cookTime: 0, prepTime: 10, calories: 360, cost: 8.0, ingredients: ["romaine", "tomatoes", "cucumber", "olives", "feta", "tuna", "red onion"], steps: ["Chop vegetables", "Add tuna and feta", "Dress with olive oil and lemon"]),
                    TemplateMeal(name: "Lentil Soup with Lemon", cookTime: 35, prepTime: 10, calories: 320, cost: 4.5, ingredients: ["red lentils", "onion", "cumin", "turmeric", "lemon", "vegetable stock"], steps: ["Sauté onion and spices", "Add lentils and stock", "Simmer, blend partially, finish with lemon"]),
                    TemplateMeal(name: "Falafel Wrap with Tzatziki", cookTime: 20, prepTime: 15, calories: 480, cost: 7.0, ingredients: ["falafel", "flatbread", "tzatziki", "lettuce", "tomato", "pickled onions"], steps: ["Bake or fry falafel", "Warm flatbread", "Assemble wrap with all toppings"]),
                    TemplateMeal(name: "Stuffed Vine Leaves with Yogurt", cookTime: 40, prepTime: 20, calories: 390, cost: 8.5, ingredients: ["vine leaves", "rice", "lemon", "olive oil", "dill", "Greek yogurt"], steps: ["Prepare rice filling", "Stuff and roll vine leaves", "Simmer in lemon broth, serve with yogurt"]),
                    TemplateMeal(name: "Grilled Vegetable Pita", cookTime: 15, prepTime: 10, calories: 410, cost: 6.0, ingredients: ["pitta bread", "aubergine", "courgette", "peppers", "hummus", "feta"], steps: ["Grill vegetables", "Warm pitta", "Fill with hummus, vegetables and feta"]),
                ],
                dinners: [
                    TemplateMeal(name: "Mediterranean Herb-Crusted Salmon", cookTime: 20, prepTime: 10, calories: 420, cost: 18.5, ingredients: ["salmon fillets", "fresh herbs", "garlic", "lemon", "olive oil"], steps: ["Mix herb crust", "Press onto salmon", "Grill 12–14 minutes"]),
                    TemplateMeal(name: "Lamb Kofta with Tzatziki", cookTime: 20, prepTime: 15, calories: 460, cost: 15.0, ingredients: ["lamb mince", "cumin", "coriander", "garlic", "tzatziki", "flatbread"], steps: ["Season lamb, shape on skewers", "Grill 8–10 minutes", "Serve with tzatziki and flatbread"]),
                    TemplateMeal(name: "Baked Sea Bass with Olives & Capers", cookTime: 25, prepTime: 10, calories: 380, cost: 19.0, ingredients: ["sea bass fillets", "olives", "capers", "tomatoes", "garlic", "white wine"], steps: ["Layer tomatoes, olives and capers in dish", "Place sea bass on top", "Bake at 190°C for 20 minutes"]),
                    TemplateMeal(name: "Chicken Souvlaki with Rice Pilaf", cookTime: 30, prepTime: 20, calories: 510, cost: 13.0, ingredients: ["chicken thighs", "lemon", "oregano", "garlic", "rice", "chicken stock"], steps: ["Marinate chicken in lemon and oregano", "Grill on skewers", "Serve with rice pilaf"]),
                    TemplateMeal(name: "Wild Mushroom Risotto", cookTime: 35, prepTime: 10, calories: 480, cost: 11.0, ingredients: ["Arborio rice", "mixed mushrooms", "white wine", "parmesan", "butter", "stock"], steps: ["Sauté mushrooms", "Toast rice and add stock gradually", "Finish with butter and parmesan"]),
                    TemplateMeal(name: "Moussaka", cookTime: 60, prepTime: 25, calories: 550, cost: 14.0, ingredients: ["aubergine", "beef mince", "béchamel", "tomatoes", "cinnamon", "parmesan"], steps: ["Roast aubergine slices", "Make meat sauce with tomatoes and spices", "Layer and top with béchamel, bake 40 minutes"]),
                    TemplateMeal(name: "Grilled Swordfish with Salsa Verde", cookTime: 15, prepTime: 10, calories: 410, cost: 20.0, ingredients: ["swordfish steaks", "capers", "anchovies", "parsley", "lemon", "olive oil"], steps: ["Make salsa verde", "Season and grill swordfish 4 minutes per side", "Serve with salsa verde"]),
                ]
            )

        case "budget":
            return TemplateWeekMeals(
                breakfasts: [
                    TemplateMeal(name: "Banana Oat Porridge", cookTime: 5, prepTime: 2, calories: 310, cost: 1.5, ingredients: ["rolled oats", "banana", "oat milk", "cinnamon", "honey"], steps: ["Cook oats with milk", "Mash banana through oats", "Top with cinnamon and honey"]),
                    TemplateMeal(name: "Peanut Butter Toast with Banana", cookTime: 3, prepTime: 2, calories: 340, cost: 1.2, ingredients: ["wholemeal bread", "peanut butter", "banana", "honey"], steps: ["Toast bread", "Spread peanut butter", "Top with sliced banana and honey"]),
                    TemplateMeal(name: "Scrambled Eggs on Toast", cookTime: 5, prepTime: 3, calories: 320, cost: 1.8, ingredients: ["eggs", "butter", "wholemeal bread", "salt", "pepper"], steps: ["Whisk eggs with seasoning", "Scramble in butter over low heat", "Serve on buttered toast"]),
                    TemplateMeal(name: "Overnight Oats with Apple", cookTime: 0, prepTime: 5, calories: 360, cost: 1.5, ingredients: ["rolled oats", "oat milk", "apple", "cinnamon", "maple syrup"], steps: ["Mix oats with milk", "Refrigerate overnight", "Top with grated apple and cinnamon"]),
                    TemplateMeal(name: "Banana Protein Pancakes", cookTime: 15, prepTime: 5, calories: 350, cost: 2.0, ingredients: ["banana", "eggs", "oats", "baking powder", "cinnamon"], steps: ["Blend all ingredients", "Cook in a non-stick pan", "Serve with maple syrup"]),
                    TemplateMeal(name: "Boiled Eggs with Toast Soldiers", cookTime: 7, prepTime: 2, calories: 290, cost: 1.5, ingredients: ["eggs", "wholemeal bread", "butter", "salt"], steps: ["Boil eggs for 6 minutes", "Toast and butter bread", "Cut into soldiers to dip"]),
                    TemplateMeal(name: "Yogurt with Granola & Banana", cookTime: 0, prepTime: 3, calories: 330, cost: 1.8, ingredients: ["natural yogurt", "granola", "banana", "honey"], steps: ["Spoon yogurt into bowl", "Add granola", "Slice banana on top and drizzle honey"]),
                ],
                lunches: [
                    TemplateMeal(name: "Spiced Red Lentil Soup", cookTime: 35, prepTime: 10, calories: 280, cost: 2.5, ingredients: ["red lentils", "onion", "cumin", "turmeric", "vegetable stock", "lemon"], steps: ["Sauté onion and spices", "Add lentils and stock", "Simmer 25 minutes, season and serve"]),
                    TemplateMeal(name: "Egg Fried Rice", cookTime: 15, prepTime: 5, calories: 420, cost: 2.0, ingredients: ["cooked rice", "eggs", "frozen peas", "soy sauce", "sesame oil", "spring onions"], steps: ["Fry eggs, scramble", "Add cold rice and peas", "Season with soy sauce and sesame oil"]),
                    TemplateMeal(name: "Bean & Vegetable Wrap", cookTime: 5, prepTime: 10, calories: 390, cost: 2.8, ingredients: ["tortilla", "canned beans", "cheese", "lettuce", "salsa", "soured cream"], steps: ["Warm beans", "Layer onto tortilla", "Add toppings and wrap"]),
                    TemplateMeal(name: "Minestrone Soup", cookTime: 30, prepTime: 10, calories: 260, cost: 2.5, ingredients: ["onion", "carrots", "celery", "canned tomatoes", "pasta", "vegetable stock", "parmesan"], steps: ["Sauté vegetables", "Add tomatoes and stock", "Add pasta and cook, finish with parmesan"]),
                    TemplateMeal(name: "Tuna Pasta Salad", cookTime: 10, prepTime: 5, calories: 440, cost: 3.0, ingredients: ["pasta", "canned tuna", "mayonnaise", "sweetcorn", "spring onions"], steps: ["Cook and cool pasta", "Drain tuna", "Mix with mayo, sweetcorn and spring onions"]),
                    TemplateMeal(name: "Chickpea & Spinach Curry", cookTime: 25, prepTime: 10, calories: 360, cost: 2.8, ingredients: ["canned chickpeas", "spinach", "canned tomatoes", "onion", "curry powder", "garlic"], steps: ["Fry onion, garlic and curry powder", "Add chickpeas and tomatoes", "Simmer 15 minutes, stir in spinach"]),
                    TemplateMeal(name: "Jacket Potato with Cheese & Beans", cookTime: 60, prepTime: 2, calories: 480, cost: 2.0, ingredients: ["baking potato", "cheddar cheese", "canned baked beans", "butter"], steps: ["Bake potato at 200°C for 1 hour", "Score and add butter", "Top with beans and cheese"]),
                ],
                dinners: [
                    TemplateMeal(name: "Spaghetti Bolognese", cookTime: 60, prepTime: 15, calories: 550, cost: 6.0, ingredients: ["beef mince", "spaghetti", "canned tomatoes", "onion", "garlic", "parmesan"], steps: ["Brown mince", "Make tomato sauce", "Serve on pasta with parmesan"]),
                    TemplateMeal(name: "Chicken & Vegetable Stew", cookTime: 45, prepTime: 15, calories: 420, cost: 5.5, ingredients: ["chicken thighs", "potatoes", "carrots", "onion", "chicken stock", "thyme"], steps: ["Brown chicken", "Add vegetables and stock", "Simmer 40 minutes until tender"]),
                    TemplateMeal(name: "Sausage & Bean Casserole", cookTime: 40, prepTime: 10, calories: 510, cost: 5.0, ingredients: ["pork sausages", "canned beans", "canned tomatoes", "onion", "paprika"], steps: ["Brown sausages", "Add onion and paprika", "Pour in tomatoes and beans, simmer 30 minutes"]),
                    TemplateMeal(name: "Pasta Arrabbiata", cookTime: 25, prepTime: 5, calories: 430, cost: 3.5, ingredients: ["penne pasta", "canned tomatoes", "garlic", "chilli flakes", "olive oil", "parmesan"], steps: ["Fry garlic and chilli in oil", "Add tomatoes and simmer", "Toss with cooked pasta and parmesan"]),
                    TemplateMeal(name: "Homemade Fish & Chips", cookTime: 35, prepTime: 15, calories: 580, cost: 6.5, ingredients: ["cod fillets", "potatoes", "batter mix", "vegetable oil", "salt and vinegar"], steps: ["Bake chips at 200°C", "Dip fish in batter", "Fry fish until golden and crispy"]),
                    TemplateMeal(name: "Lentil Dal with Rice", cookTime: 30, prepTime: 10, calories: 420, cost: 3.0, ingredients: ["red lentils", "basmati rice", "onion", "garlic", "ginger", "turmeric", "garam masala"], steps: ["Cook rice separately", "Fry aromatics and spices", "Add lentils and water, simmer until thick"]),
                    TemplateMeal(name: "Chicken & Rice Soup", cookTime: 45, prepTime: 10, calories: 380, cost: 4.5, ingredients: ["chicken breasts", "rice", "carrots", "celery", "chicken stock", "parsley"], steps: ["Simmer chicken in stock", "Shred chicken, return to pot", "Add rice and vegetables, cook until tender"]),
                ]
            )

        case "quick":
            return TemplateWeekMeals(
                breakfasts: [
                    TemplateMeal(name: "Avocado Toast with Poached Egg", cookTime: 10, prepTime: 5, calories: 380, cost: 4.5, ingredients: ["sourdough", "avocado", "eggs", "chilli flakes", "lemon"], steps: ["Toast bread", "Mash avocado", "Poach egg and serve on top"]),
                    TemplateMeal(name: "Greek Yogurt Parfait", cookTime: 0, prepTime: 5, calories: 320, cost: 3.2, ingredients: ["Greek yogurt", "granola", "mixed berries", "honey"], steps: ["Layer yogurt", "Add granola and berries", "Drizzle honey"]),
                    TemplateMeal(name: "Smoothie Bowl", cookTime: 0, prepTime: 5, calories: 350, cost: 4.0, ingredients: ["frozen banana", "frozen berries", "almond milk", "granola", "chia seeds"], steps: ["Blend fruits with minimal milk", "Pour into bowl", "Top with granola and chia seeds"]),
                    TemplateMeal(name: "Overnight Oats", cookTime: 0, prepTime: 5, calories: 410, cost: 2.8, ingredients: ["rolled oats", "chia seeds", "oat milk", "almond butter", "berries"], steps: ["Mix oats, seeds and milk", "Refrigerate overnight", "Top with almond butter and berries"]),
                    TemplateMeal(name: "Scrambled Eggs with Smoked Salmon", cookTime: 5, prepTime: 3, calories: 360, cost: 6.5, ingredients: ["eggs", "smoked salmon", "cream cheese", "chives", "sourdough"], steps: ["Scramble eggs gently", "Serve on toast", "Top with salmon and cream cheese"]),
                    TemplateMeal(name: "Peanut Butter & Banana Smoothie", cookTime: 0, prepTime: 3, calories: 380, cost: 2.5, ingredients: ["banana", "peanut butter", "oat milk", "protein powder", "honey"], steps: ["Blend all ingredients", "Pour and serve immediately"]),
                    TemplateMeal(name: "Cottage Cheese with Fruit & Nuts", cookTime: 0, prepTime: 3, calories: 290, cost: 3.5, ingredients: ["cottage cheese", "pineapple", "almonds", "honey", "cinnamon"], steps: ["Spoon cottage cheese into bowl", "Add pineapple and almonds", "Drizzle honey and dust cinnamon"]),
                ],
                lunches: [
                    TemplateMeal(name: "Turkey & Avocado Wrap", cookTime: 5, prepTime: 10, calories: 430, cost: 6.5, ingredients: ["tortilla", "turkey", "avocado", "bacon", "lettuce", "tomato"], steps: ["Layer fillings on tortilla", "Roll tightly", "Cut and serve"]),
                    TemplateMeal(name: "Thai Peanut Noodles", cookTime: 15, prepTime: 10, calories: 510, cost: 5.8, ingredients: ["soba noodles", "peanut butter", "soy sauce", "sesame oil", "cucumber", "spring onions"], steps: ["Cook noodles", "Make peanut sauce", "Toss and top with vegetables"]),
                    TemplateMeal(name: "Caesar Salad", cookTime: 10, prepTime: 15, calories: 340, cost: 8.5, ingredients: ["romaine", "parmesan", "croutons", "caesar dressing", "anchovies"], steps: ["Toss lettuce with dressing", "Add croutons and parmesan", "Serve immediately"]),
                    TemplateMeal(name: "Quick Quesadillas", cookTime: 10, prepTime: 5, calories: 450, cost: 5.0, ingredients: ["flour tortillas", "cheddar", "black beans", "salsa", "soured cream"], steps: ["Layer cheese and beans between tortillas", "Cook in a dry pan until golden", "Serve with salsa and soured cream"]),
                    TemplateMeal(name: "Prawn & Avocado Salad", cookTime: 5, prepTime: 10, calories: 380, cost: 9.5, ingredients: ["king prawns", "avocado", "rocket", "cherry tomatoes", "lemon dressing"], steps: ["Cook prawns briefly", "Slice avocado", "Toss with rocket and dressing"]),
                    TemplateMeal(name: "Tuna & Sweetcorn Pitta", cookTime: 5, prepTime: 5, calories: 380, cost: 3.8, ingredients: ["pitta bread", "tuna", "sweetcorn", "mayo", "lettuce", "tomato"], steps: ["Mix tuna, sweetcorn and mayo", "Warm pitta", "Fill and serve"]),
                    TemplateMeal(name: "Hummus & Veggie Box", cookTime: 0, prepTime: 5, calories: 290, cost: 4.5, ingredients: ["hummus", "carrot sticks", "cucumber", "cherry tomatoes", "wholemeal pitta"], steps: ["Portion hummus into a container", "Prep vegetables", "Pack with pitta and serve"]),
                ],
                dinners: [
                    TemplateMeal(name: "Pad Thai with Prawns", cookTime: 20, prepTime: 15, calories: 540, cost: 13.5, ingredients: ["rice noodles", "prawns", "eggs", "bean sprouts", "peanuts", "lime", "fish sauce"], steps: ["Soak noodles", "Stir-fry prawns and eggs", "Toss with noodles and sauce"]),
                    TemplateMeal(name: "Quick Chicken Stir-Fry", cookTime: 15, prepTime: 10, calories: 420, cost: 9.0, ingredients: ["chicken breast", "mixed vegetables", "soy sauce", "oyster sauce", "garlic", "ginger"], steps: ["Slice chicken and vegetables", "Stir-fry in batches on high heat", "Toss with sauce"]),
                    TemplateMeal(name: "Grilled Salmon with Asparagus", cookTime: 15, prepTime: 5, calories: 390, cost: 16.0, ingredients: ["salmon fillets", "asparagus", "lemon", "garlic butter", "salt and pepper"], steps: ["Season salmon", "Grill 6 minutes per side", "Roast asparagus alongside"]),
                    TemplateMeal(name: "Pasta Aglio e Olio", cookTime: 15, prepTime: 5, calories: 480, cost: 4.0, ingredients: ["spaghetti", "garlic", "olive oil", "chilli flakes", "parsley", "parmesan"], steps: ["Cook pasta", "Fry garlic and chilli in oil", "Toss pasta in oil with parsley and parmesan"]),
                    TemplateMeal(name: "Sheet Pan Sausages & Vegetables", cookTime: 30, prepTime: 10, calories: 520, cost: 8.0, ingredients: ["sausages", "peppers", "courgette", "cherry tomatoes", "olive oil", "herbs"], steps: ["Toss vegetables with oil and herbs", "Add sausages to tray", "Roast at 200°C for 30 minutes"]),
                    TemplateMeal(name: "Chicken Fajitas", cookTime: 15, prepTime: 10, calories: 490, cost: 9.5, ingredients: ["chicken breast", "peppers", "onion", "fajita spice", "tortillas", "soured cream", "guacamole"], steps: ["Slice and season chicken and vegetables", "Stir-fry on high heat", "Serve in tortillas with toppings"]),
                    TemplateMeal(name: "Prawn Linguine", cookTime: 15, prepTime: 5, calories: 490, cost: 12.0, ingredients: ["linguine", "king prawns", "garlic", "white wine", "cherry tomatoes", "parsley", "chilli"], steps: ["Cook linguine", "Sauté prawns with garlic and wine", "Toss with pasta and cherry tomatoes"]),
                ]
            )

        case "kenyan":
            return TemplateWeekMeals(
                breakfasts: [
                    TemplateMeal(name: "Mandazi with Kenyan Chai", cookTime: 20, prepTime: 15, calories: 340, cost: 2.5, ingredients: ["2 cups plain flour", "1 tbsp sugar", "1 tsp baking powder", "½ tsp ground cardamom", "½ cup coconut milk", "1 egg", "Oil for frying", "Kenyan black tea", "Whole milk", "Cardamom pods", "Fresh ginger"], steps: ["Mix flour, sugar, baking powder and cardamom", "Add coconut milk and egg, knead 5 minutes", "Cut into triangles and deep-fry until golden", "Brew strong tea with cardamom and ginger", "Serve mandazi hot with spiced chai"]),
                    TemplateMeal(name: "Scrambled Eggs with Sukuma Wiki", cookTime: 10, prepTime: 5, calories: 290, cost: 2.0, ingredients: ["3 eggs", "1 bunch collard greens", "1 tomato diced", "1 onion diced", "1 tbsp oil", "Salt and pepper"], steps: ["Finely shred collard greens", "Sauté onion and tomato", "Add greens and wilt", "Scramble eggs alongside", "Serve together"]),
                    TemplateMeal(name: "Uji wa Wimbi (Millet Porridge)", cookTime: 15, prepTime: 5, calories: 310, cost: 1.5, ingredients: ["1 cup finger millet flour", "4 cups water", "2 tbsp sugar", "Pinch of salt", "Milk to serve"], steps: ["Mix millet flour with cold water", "Bring remaining water to boil", "Whisk in flour paste gradually", "Cook stirring constantly 10 minutes", "Sweeten and serve with milk"]),
                    TemplateMeal(name: "Vitumbua (Coconut Rice Pancakes)", cookTime: 20, prepTime: 10, calories: 320, cost: 2.8, ingredients: ["1 cup rice flour", "1 cup coconut milk", "2 tbsp sugar", "½ tsp yeast", "Pinch of cardamom"], steps: ["Mix rice flour with coconut milk and sugar", "Add yeast, rest 30 minutes", "Cook in a special vitumbua pan or takoyaki pan", "Each should have a domed shape", "Serve hot with chai"]),
                    TemplateMeal(name: "Kenyan French Toast (Mkate wa Kukaanga)", cookTime: 10, prepTime: 5, calories: 360, cost: 2.2, ingredients: ["4 slices white bread", "2 eggs", "¼ cup milk", "1 tsp vanilla", "1 tbsp sugar", "½ tsp cinnamon", "Butter for frying"], steps: ["Whisk eggs, milk, vanilla and sugar", "Dip bread slices in egg mixture", "Fry in butter until golden both sides", "Dust with cinnamon and sugar", "Serve with fresh mango"]),
                    TemplateMeal(name: "Maharagwe ya Nazi with Chapati", cookTime: 40, prepTime: 10, calories: 450, cost: 3.0, ingredients: ["1 cup red kidney beans soaked overnight", "400ml coconut milk", "1 onion diced", "2 tomatoes", "1 tsp turmeric", "1 tsp cumin", "Salt"], steps: ["Cook beans until tender", "Sauté onion and tomatoes with spices", "Add beans and coconut milk", "Simmer 20 minutes", "Serve with warm chapati"]),
                    TemplateMeal(name: "Githeri Breakfast Bowl", cookTime: 20, prepTime: 5, calories: 380, cost: 1.8, ingredients: ["1 cup cooked githeri (maize and beans)", "1 tomato diced", "1 onion diced", "1 tsp oil", "Salt and pepper", "Fresh coriander"], steps: ["Heat oil in a pan", "Fry onion until golden", "Add tomatoes and cook down", "Stir in githeri", "Season and garnish with coriander"]),
                ],
                lunches: [
                    TemplateMeal(name: "Githeri (Maize & Bean Stew)", cookTime: 60, prepTime: 10, calories: 380, cost: 2.5, ingredients: ["2 cups dried maize", "1 cup dried kidney beans", "1 large onion", "3 tomatoes", "2 tbsp oil", "1 tsp curry powder", "Salt and pepper", "Fresh coriander"], steps: ["Soak maize and beans overnight", "Boil together until tender (1 hour)", "Fry onion, add tomatoes and curry powder", "Add boiled maize and beans, stir well", "Simmer 15 minutes, garnish with coriander"]),
                    TemplateMeal(name: "Mukimo with Sukuma Wiki", cookTime: 30, prepTime: 15, calories: 410, cost: 2.8, ingredients: ["4 large potatoes peeled and cubed", "1 cup green peas", "1 cup sweetcorn kernels", "1 bunch collard greens shredded", "1 onion diced", "2 tbsp butter", "Salt to taste"], steps: ["Boil potatoes until tender", "Add peas and corn, boil together", "Separately wilt collard greens with onion", "Mash everything together with butter", "Season and serve as a thick green mash"]),
                    TemplateMeal(name: "Viazi Karai (Spiced Potato Fritters)", cookTime: 25, prepTime: 10, calories: 350, cost: 2.0, ingredients: ["4 medium potatoes boiled", "½ cup plain flour", "1 tsp cumin", "1 tsp coriander", "½ tsp turmeric", "½ tsp chilli powder", "Salt", "Oil for frying", "Tamarind chutney to serve"], steps: ["Slice boiled potatoes", "Mix flour with spices and enough water for thick batter", "Dip potato slices in batter", "Deep-fry until golden", "Serve with tamarind chutney"]),
                    TemplateMeal(name: "Kenyan Pilau Rice", cookTime: 45, prepTime: 15, calories: 480, cost: 5.5, ingredients: ["2 cups basmati rice", "300g beef cubed", "2 onions sliced", "4 garlic cloves", "1 tsp cumin", "4 cardamom pods", "2 cinnamon sticks", "6 cloves", "1 tsp black pepper", "3 cups beef stock"], steps: ["Brown beef with spices", "Caramelise onions deeply", "Add garlic and all spices", "Add rice and stock", "Cook covered on low heat 20 minutes", "Rest 10 minutes before serving"]),
                    TemplateMeal(name: "Wali wa Nazi (Coconut Rice)", cookTime: 25, prepTime: 5, calories: 420, cost: 3.5, ingredients: ["2 cups basmati rice", "400ml coconut milk", "200ml water", "1 tsp salt", "1 tsp sugar", "Fresh coriander"], steps: ["Rinse rice until water runs clear", "Combine coconut milk and water, bring to boil", "Add rice, salt and sugar", "Cook covered on low heat 18 minutes", "Fluff with fork and garnish with coriander"]),
                    TemplateMeal(name: "Mchuzi wa Samaki (Fish Curry)", cookTime: 25, prepTime: 10, calories: 360, cost: 6.5, ingredients: ["4 tilapia fillets", "400ml coconut milk", "2 tomatoes diced", "1 onion diced", "3 garlic cloves", "1 tsp turmeric", "1 tsp curry powder", "Fresh coriander and lime"], steps: ["Fry onion and garlic until golden", "Add tomatoes and spices, cook 5 minutes", "Pour in coconut milk, bring to simmer", "Add fish, cook 10 minutes", "Finish with coriander and lime"]),
                    TemplateMeal(name: "Kenyan Beef Samosa", cookTime: 30, prepTime: 20, calories: 320, cost: 4.0, ingredients: ["250g beef mince", "1 onion diced", "2 green chillies", "Fresh coriander", "½ tsp cumin", "½ tsp garam masala", "Samosa pastry sheets", "Oil for frying"], steps: ["Brown beef with onion and spices", "Cool filling completely", "Fold pastry into triangles with filling", "Seal edges with water", "Deep-fry until golden brown"]),
                ],
                dinners: [
                    TemplateMeal(name: "Nyama Choma (Kenyan Grilled Goat)", cookTime: 60, prepTime: 20, calories: 580, cost: 12.0, ingredients: ["1kg goat or beef on the bone", "2 tsp rock salt", "1 tsp black pepper", "1 tbsp oil", "Kachumbari (tomato-onion salad)", "Ugali to serve"], steps: ["Rub meat generously with salt and pepper", "Grill over hot charcoal or high-heat grill", "Turn every 10 minutes, grill 50–60 minutes total", "Meat should be slightly charred outside", "Serve with kachumbari and ugali"]),
                    TemplateMeal(name: "Ugali na Mchuzi wa Kuku", cookTime: 50, prepTime: 15, calories: 540, cost: 7.5, ingredients: ["1 whole chicken jointed", "2 cups maize meal (posho)", "4 cups water", "2 onions diced", "3 tomatoes", "2 garlic cloves", "1 tsp turmeric", "Salt to taste"], steps: ["Brown chicken pieces in oil", "Add onion, garlic and tomatoes", "Add turmeric and salt, pour in water", "Simmer 30 minutes", "Meanwhile make ugali: bring water to boil, add maize meal gradually, stir until stiff", "Serve stew with ugali"]),
                    TemplateMeal(name: "Samaki wa Nazi (Coastal Fish in Coconut)", cookTime: 30, prepTime: 15, calories: 420, cost: 9.0, ingredients: ["4 whole tilapia or snapper", "400ml coconut milk", "4 garlic cloves", "1 tbsp ginger", "2 tomatoes", "1 tsp turmeric", "1 tsp cumin", "Fresh coriander", "Lime wedges"], steps: ["Score fish and season with salt and turmeric", "Fry fish briefly to seal", "Blend garlic, ginger, tomatoes into a paste", "Cook paste in oil 5 minutes", "Add coconut milk and bring to simmer", "Add fish, cook 15 minutes, finish with coriander"]),
                    TemplateMeal(name: "Kenyan Beef Stew with Ugali", cookTime: 60, prepTime: 15, calories: 520, cost: 9.0, ingredients: ["700g beef cubed", "3 tomatoes diced", "2 onions diced", "3 garlic cloves", "1 tsp curry powder", "1 tsp turmeric", "2 potatoes cubed", "Salt and pepper", "Maize meal for ugali"], steps: ["Brown beef in batches", "Fry onion, garlic and spices", "Add tomatoes and cook until thick", "Add beef and cover with water", "Add potatoes, simmer 40 minutes", "Serve with hand-shaped ugali"]),
                    TemplateMeal(name: "Maharagwe ya Nazi (Coconut Kidney Beans)", cookTime: 50, prepTime: 10, calories: 440, cost: 4.5, ingredients: ["2 cups kidney beans soaked", "400ml coconut milk", "2 tomatoes diced", "1 onion diced", "3 garlic cloves", "1 tsp cumin", "1 tsp turmeric", "1 green chilli", "Salt", "Wali wa Nazi to serve"], steps: ["Boil beans until tender", "Fry onion, garlic and chilli", "Add tomatoes and spices, cook 5 minutes", "Add beans and coconut milk", "Simmer 20 minutes until thick and creamy", "Serve over coconut rice"]),
                    TemplateMeal(name: "Kenyan Chapati na Kachumbari", cookTime: 30, prepTime: 20, calories: 490, cost: 3.5, ingredients: ["3 cups plain flour", "1 cup warm water", "1 tsp salt", "Oil for layers", "3 tomatoes diced", "1 red onion diced", "Juice of 1 lemon", "Fresh coriander", "1 green chilli"], steps: ["Mix flour and salt, add water gradually, knead 10 minutes", "Divide into balls, rest 15 minutes", "Roll flat, brush with oil, roll up into a coil, flatten again", "Cook in a dry pan until golden with charred spots both sides", "Make kachumbari: mix tomatoes, onion, coriander and lemon"]),
                    TemplateMeal(name: "Matoke (Stewed Green Bananas)", cookTime: 45, prepTime: 15, calories: 380, cost: 4.0, ingredients: ["6 green bananas peeled", "300g beef or goat cubed", "2 tomatoes", "1 onion", "2 garlic cloves", "1 tsp curry powder", "Salt", "Banana leaves or foil to wrap"], steps: ["Brown meat with onion and garlic", "Add tomatoes and curry powder", "Add green bananas", "Wrap in banana leaves or foil", "Steam or braise 35–40 minutes until bananas are tender", "Serve as a complete one-pot dish"]),
                ]
            )

        default:
            return TemplateWeekMeals(
                breakfasts: (1...7).map { i in
                    TemplateMeal(name: "Overnight Oats Day \(i)", cookTime: 0, prepTime: 5, calories: 350, cost: 3.0, ingredients: ["rolled oats", "milk", "berries", "honey"], steps: ["Mix oats with milk", "Refrigerate overnight", "Top with berries"])
                },
                lunches: (1...7).map { i in
                    TemplateMeal(name: "Mixed Salad Bowl Day \(i)", cookTime: 10, prepTime: 10, calories: 380, cost: 6.0, ingredients: ["mixed greens", "cherry tomatoes", "cucumber", "protein", "dressing"], steps: ["Chop vegetables", "Add protein", "Dress and serve"])
                },
                dinners: (1...7).map { i in
                    TemplateMeal(name: "Grilled Protein with Vegetables Day \(i)", cookTime: 25, prepTime: 10, calories: 480, cost: 12.0, ingredients: ["protein of choice", "seasonal vegetables", "olive oil", "herbs", "lemon"], steps: ["Season protein", "Grill or roast", "Serve with vegetables"])
                }
            )
        }
    }
    
    private static func getAllProductionRecipes() -> [[String: Any]] {
        return [
            // MARK: Breakfasts
            [
                "title": "Avocado Toast with Poached Eggs",
                "cook_time": "10 min", "prep_time": 5, "servings": 2, "calories": 380,
                "image_url": "https://images.unsplash.com/photo-1541519227354-08fa5d50c820?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 thick slices sourdough bread", "1 ripe avocado", "2 large eggs", "1 tbsp white vinegar", "Pinch of chilli flakes", "Sea salt and black pepper", "Squeeze of lemon juice", "Fresh microgreens"],
                "steps": ["Toast sourdough until golden.", "Mash avocado with lemon, salt and pepper.", "Poach eggs in simmering water with vinegar for 3 minutes.", "Spread avocado on toast, top with egg, chilli flakes and microgreens."],
                "substitutions": ["Use gluten-free bread", "Add smoked salmon for extra protein"],
                "difficulty": "easy", "cuisine_type": "modern", "cost_estimate": 4.50, "is_public": true,
                "tags": ["breakfast", "vegetarian", "quick", "healthy"]
            ],
            [
                "title": "Shakshuka with Feta",
                "cook_time": "25 min", "prep_time": 10, "servings": 4, "calories": 290,
                "image_url": "https://images.unsplash.com/photo-1590412200988-a436970781fa?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 tbsp olive oil", "1 large onion diced", "1 red bell pepper sliced", "4 garlic cloves minced", "1 tsp cumin", "1 tsp smoked paprika", "½ tsp cayenne", "2 × 400g cans crushed tomatoes", "6 large eggs", "100g feta crumbled"],
                "steps": ["Sauté onion and pepper 8 minutes.", "Add garlic and spices, cook 1 minute.", "Add tomatoes, simmer 10 minutes.", "Make wells, crack in eggs.", "Cover and cook 5–7 minutes. Top with feta."],
                "substitutions": ["Replace feta with goat cheese", "Add harissa for more heat"],
                "difficulty": "medium", "cuisine_type": "middle-eastern", "cost_estimate": 6.80, "is_public": true,
                "tags": ["breakfast", "vegetarian", "mediterranean", "one-pan"]
            ],
            [
                "title": "Greek Yogurt Parfait with Granola",
                "cook_time": "0 min", "prep_time": 5, "servings": 1, "calories": 320,
                "image_url": "https://images.unsplash.com/photo-1488477181946-6428a0291777?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["200g full-fat Greek yogurt", "60g granola", "100g mixed berries", "1 tbsp honey", "1 tsp vanilla extract", "Pinch of cinnamon"],
                "steps": ["Stir vanilla into yogurt.", "Layer yogurt, granola and berries in a glass.", "Repeat layers.", "Drizzle honey and dust with cinnamon."],
                "substitutions": ["Use dairy-free coconut yogurt", "Swap honey for maple syrup (vegan)"],
                "difficulty": "easy", "cuisine_type": "mediterranean", "cost_estimate": 3.20, "is_public": true,
                "tags": ["breakfast", "no-cook", "vegetarian", "quick"]
            ],
            [
                "title": "Banana Protein Pancakes",
                "cook_time": "15 min", "prep_time": 5, "servings": 2, "calories": 350,
                "image_url": "https://images.unsplash.com/photo-1528207776546-365bb710ee93?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 ripe bananas", "2 large eggs", "1 scoop vanilla protein powder", "½ tsp baking powder", "½ tsp cinnamon", "1 tsp coconut oil", "Fresh berries and maple syrup to serve"],
                "steps": ["Mash bananas until smooth.", "Whisk in eggs.", "Fold in protein powder, baking powder and cinnamon.", "Cook small ladles of batter 2 minutes per side.", "Serve with berries and maple syrup."],
                "substitutions": ["Skip protein powder, add 2 tbsp almond flour", "Use flax eggs (vegan)"],
                "difficulty": "easy", "cuisine_type": "american", "cost_estimate": 3.50, "is_public": true,
                "tags": ["breakfast", "high-protein", "gluten-free", "fitness"]
            ],
            [
                "title": "Overnight Oats with Chia & Berries",
                "cook_time": "0 min", "prep_time": 5, "servings": 1, "calories": 410,
                "image_url": "https://images.unsplash.com/photo-1516714435131-44d6b64dc6a2?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["80g rolled oats", "1 tbsp chia seeds", "240ml oat milk", "2 tbsp Greek yogurt", "1 tbsp maple syrup", "½ tsp vanilla extract", "Handful of mixed berries", "1 tbsp almond butter"],
                "steps": ["Combine oats, chia, milk, yogurt, syrup and vanilla in a jar.", "Refrigerate overnight.", "In the morning, stir and add extra milk if too thick.", "Top with berries and almond butter."],
                "substitutions": ["Use any plant-based milk", "Add a protein powder scoop"],
                "difficulty": "easy", "cuisine_type": "modern", "cost_estimate": 2.80, "is_public": true,
                "tags": ["breakfast", "meal-prep", "no-cook", "vegetarian"]
            ],
            [
                "title": "Spinach & Feta Omelette",
                "cook_time": "8 min", "prep_time": 5, "servings": 1, "calories": 310,
                "image_url": "https://images.unsplash.com/photo-1612240498936-65f5101365d2?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["3 large eggs", "80g baby spinach", "60g feta crumbled", "1 tbsp butter", "1 garlic clove minced", "Salt and black pepper", "Fresh dill"],
                "steps": ["Whisk eggs with salt and pepper.", "Melt butter, sauté garlic, wilt spinach.", "Pour in eggs, cook until edges set.", "Add feta, fold and cook 1 more minute.", "Slide onto plate and garnish with dill."],
                "substitutions": ["Use goat cheese instead of feta", "Add sun-dried tomatoes"],
                "difficulty": "easy", "cuisine_type": "mediterranean", "cost_estimate": 3.80, "is_public": true,
                "tags": ["breakfast", "vegetarian", "low-carb", "high-protein", "quick"]
            ],
            // MARK: Lunches
            [
                "title": "Classic Caesar Salad",
                "cook_time": "10 min", "prep_time": 15, "servings": 4, "calories": 340,
                "image_url": "https://images.unsplash.com/photo-1550304943-4f24f54ddde9?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 romaine hearts chopped", "100g parmesan grated", "150g croutons", "2 garlic cloves", "3 anchovies", "2 egg yolks", "1 tsp Dijon mustard", "2 tbsp lemon juice", "120ml olive oil", "1 tsp Worcestershire sauce"],
                "steps": ["Pound garlic and anchovies into a paste.", "Whisk in egg yolks, Dijon, lemon and Worcestershire.", "Drizzle in olive oil whisking until emulsified.", "Toss romaine with dressing, parmesan and croutons."],
                "substitutions": ["Omit anchovies for vegetarian", "Use mayo dressing if avoiding raw egg"],
                "difficulty": "medium", "cuisine_type": "american", "cost_estimate": 8.50, "is_public": true,
                "tags": ["lunch", "salad", "classic", "low-carb"]
            ],
            [
                "title": "Roasted Vegetable Quinoa Bowl",
                "cook_time": "30 min", "prep_time": 10, "servings": 2, "calories": 480,
                "image_url": "https://images.unsplash.com/photo-1512621776951-a57141f2eefd?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["200g quinoa", "1 courgette cubed", "1 red pepper sliced", "1 red onion wedged", "200g cherry tomatoes", "400g can chickpeas drained", "3 tbsp olive oil", "1 tsp smoked paprika", "1 tsp cumin", "60g feta"],
                "steps": ["Preheat oven to 200°C.", "Toss vegetables and chickpeas with oil and spices.", "Roast 25 minutes until golden.", "Cook quinoa in salted water 15 minutes.", "Assemble bowls with quinoa, vegetables and feta."],
                "substitutions": ["Use brown rice instead of quinoa", "Add tahini dressing"],
                "difficulty": "easy", "cuisine_type": "mediterranean", "cost_estimate": 7.20, "is_public": true,
                "tags": ["lunch", "vegetarian", "meal-prep", "healthy"]
            ],
            [
                "title": "Spiced Red Lentil Soup",
                "cook_time": "35 min", "prep_time": 10, "servings": 6, "calories": 260,
                "image_url": "https://images.unsplash.com/photo-1547592166-23ac45744acd?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["300g red lentils rinsed", "1 large onion diced", "3 garlic cloves minced", "2 carrots diced", "2 tbsp olive oil", "1 tsp turmeric", "1 tsp cumin", "1 tsp coriander", "½ tsp cayenne", "1.5L vegetable stock", "400g can crushed tomatoes", "Juice of 1 lemon"],
                "steps": ["Sauté onion and carrot in oil 8 minutes.", "Add garlic and spices, cook 1 minute.", "Add lentils, tomatoes and stock.", "Simmer 25 minutes until lentils are tender.", "Partially blend, stir in lemon juice."],
                "substitutions": ["Use green lentils for more texture", "Add coconut milk for creaminess"],
                "difficulty": "easy", "cuisine_type": "middle-eastern", "cost_estimate": 4.50, "is_public": true,
                "tags": ["lunch", "vegan", "budget", "meal-prep", "soup"]
            ],
            [
                "title": "Fresh Vietnamese Spring Rolls",
                "cook_time": "15 min", "prep_time": 20, "servings": 4, "calories": 220,
                "image_url": "https://images.unsplash.com/photo-1562802378-063ec186a863?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["12 rice paper wrappers", "200g cooked prawns halved", "100g vermicelli noodles cooked", "1 carrot julienned", "1 cucumber julienned", "1 avocado sliced", "Fresh mint and coriander", "3 tbsp hoisin sauce", "2 tbsp peanut butter", "1 tbsp lime juice"],
                "steps": ["Whisk hoisin, peanut butter and lime for dipping sauce.", "Dip rice paper in warm water 20 seconds.", "Lay on damp board, fill with prawns, noodles and vegetables.", "Fold sides and roll tightly.", "Serve with peanut-hoisin sauce."],
                "substitutions": ["Use tofu for vegan version", "Replace vermicelli with shredded cabbage"],
                "difficulty": "medium", "cuisine_type": "asian", "cost_estimate": 9.00, "is_public": true,
                "tags": ["lunch", "vietnamese", "light", "gluten-free"]
            ],
            [
                "title": "Thai Peanut Noodles",
                "cook_time": "15 min", "prep_time": 10, "servings": 3, "calories": 510,
                "image_url": "https://images.unsplash.com/photo-1569050467447-ce54b3bbc37d?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["250g soba noodles", "3 tbsp peanut butter", "2 tbsp soy sauce", "1 tbsp sesame oil", "1 tbsp rice vinegar", "1 tbsp honey", "1 tsp grated ginger", "1 garlic clove minced", "Cucumber julienned", "Spring onions", "Roasted peanuts"],
                "steps": ["Cook soba noodles, drain and rinse cold.", "Whisk peanut butter, soy, sesame oil, vinegar, honey, ginger and garlic.", "Toss noodles with sauce.", "Top with cucumber, spring onions and peanuts."],
                "substitutions": ["Use rice noodles for gluten-free", "Add shredded chicken for protein"],
                "difficulty": "easy", "cuisine_type": "thai", "cost_estimate": 5.80, "is_public": true,
                "tags": ["lunch", "asian", "meal-prep", "quick"]
            ],
            [
                "title": "Turkey & Avocado Club Wrap",
                "cook_time": "5 min", "prep_time": 10, "servings": 2, "calories": 430,
                "image_url": "https://images.unsplash.com/photo-1626700051175-6818013e1d4f?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 large whole-wheat tortillas", "200g sliced turkey breast", "1 ripe avocado mashed", "4 bacon rashers cooked", "2 romaine lettuce leaves", "2 tomatoes sliced", "2 tbsp Greek yogurt", "1 tsp Dijon mustard"],
                "steps": ["Mix yogurt with Dijon.", "Spread on tortilla.", "Layer turkey, bacon, lettuce, tomato and avocado.", "Roll tightly, cut diagonally."],
                "substitutions": ["Use smoked salmon instead of turkey", "Remove bacon for lighter option"],
                "difficulty": "easy", "cuisine_type": "american", "cost_estimate": 6.50, "is_public": true,
                "tags": ["lunch", "quick", "high-protein", "wrap"]
            ],
            [
                "title": "Korean Bibimbap Bowl",
                "cook_time": "30 min", "prep_time": 20, "servings": 2, "calories": 560,
                "image_url": "https://images.unsplash.com/photo-1590301157890-4810ed352733?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["300g short-grain rice cooked", "200g beef mince", "1 tbsp soy sauce", "1 tsp sesame oil", "200g spinach blanched", "2 carrots julienned", "100g bean sprouts", "2 fried eggs", "4 tbsp gochujang", "1 tbsp rice vinegar", "1 tsp sugar"],
                "steps": ["Season beef with soy and sesame, stir-fry until cooked.", "Mix gochujang with vinegar and sugar for sauce.", "Prepare all vegetables.", "Arrange rice and toppings in bowls.", "Top with fried egg, serve with sauce."],
                "substitutions": ["Use mushrooms for vegetarian", "Add kimchi for authentic flavour"],
                "difficulty": "medium", "cuisine_type": "korean", "cost_estimate": 10.50, "is_public": true,
                "tags": ["lunch", "korean", "high-protein", "gluten-free"]
            ],
            [
                "title": "Tuna Niçoise Salad",
                "cook_time": "15 min", "prep_time": 10, "servings": 2, "calories": 390,
                "image_url": "https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 × 185g cans tuna in olive oil", "4 large eggs soft-boiled", "200g green beans blanched", "150g cherry tomatoes halved", "80g black olives", "1 little gem lettuce", "2 tbsp capers", "3 tbsp olive oil", "1 tbsp red wine vinegar", "1 tsp Dijon mustard"],
                "steps": ["Soft-boil eggs 7 minutes, cool and halve.", "Whisk oil, vinegar and Dijon for dressing.", "Arrange lettuce as base.", "Top with tuna, eggs, beans, tomatoes and olives.", "Scatter capers and drizzle dressing."],
                "substitutions": ["Sear fresh tuna for premium version", "Add roasted potatoes"],
                "difficulty": "easy", "cuisine_type": "french", "cost_estimate": 8.80, "is_public": true,
                "tags": ["lunch", "french", "high-protein", "low-carb", "salad"]
            ],
            // MARK: Dinners
            [
                "title": "Mediterranean Herb-Crusted Salmon",
                "cook_time": "20 min", "prep_time": 10, "servings": 4, "calories": 420,
                "image_url": "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["4 salmon fillets 180g each", "3 tbsp fresh parsley chopped", "2 tbsp fresh dill chopped", "2 garlic cloves minced", "Zest of 1 lemon", "3 tbsp olive oil", "Salt and black pepper", "Lemon wedges and capers to serve"],
                "steps": ["Mix herbs, garlic, lemon zest and oil into a paste.", "Season salmon and press crust onto each fillet.", "Grill or bake skin-side down 12–14 minutes.", "Serve with lemon wedges and capers."],
                "substitutions": ["Use sea bass or cod", "Add Dijon mustard to crust"],
                "difficulty": "easy", "cuisine_type": "mediterranean", "cost_estimate": 18.50, "is_public": true,
                "tags": ["dinner", "seafood", "mediterranean", "healthy", "gluten-free"]
            ],
            [
                "title": "Chicken Tikka Masala",
                "cook_time": "40 min", "prep_time": 20, "servings": 4, "calories": 490,
                "image_url": "https://images.unsplash.com/photo-1565557623262-b51c2513a641?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["800g chicken thighs cubed", "250ml full-fat yogurt", "3 tbsp tikka spice paste", "2 tbsp vegetable oil", "2 onions finely diced", "4 garlic cloves minced", "2 tsp grated ginger", "400g can crushed tomatoes", "200ml double cream", "1 tsp garam masala"],
                "steps": ["Marinate chicken in yogurt and tikka paste 1 hour.", "Grill chicken until charred, set aside.", "Fry onions until golden brown 15 minutes.", "Add garlic, ginger and more tikka paste.", "Add tomatoes and cream, simmer 15 minutes.", "Add chicken and garam masala, simmer 10 minutes."],
                "substitutions": ["Use paneer for vegetarian", "Replace cream with coconut cream"],
                "difficulty": "medium", "cuisine_type": "indian", "cost_estimate": 14.00, "is_public": true,
                "tags": ["dinner", "indian", "curry", "gluten-free"]
            ],
            [
                "title": "Classic Spaghetti Bolognese",
                "cook_time": "60 min", "prep_time": 15, "servings": 6, "calories": 580,
                "image_url": "https://images.unsplash.com/photo-1598103442097-8b74394b95c1?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["500g beef mince", "150g pancetta diced", "1 large onion diced", "2 celery stalks diced", "2 carrots diced", "4 garlic cloves minced", "200ml red wine", "2 × 400g cans crushed tomatoes", "2 tbsp tomato purée", "150ml whole milk", "500g spaghetti"],
                "steps": ["Render pancetta, remove.", "Brown mince in batches.", "Sauté onion, celery, carrot and garlic.", "Add wine and reduce.", "Add tomatoes and simmer 45 minutes.", "Stir in milk, cook 10 minutes.", "Serve with pasta and parmesan."],
                "substitutions": ["Mix beef and pork for richness", "Use tagliatelle instead of spaghetti"],
                "difficulty": "medium", "cuisine_type": "italian", "cost_estimate": 12.50, "is_public": true,
                "tags": ["dinner", "italian", "classic", "meal-prep"]
            ],
            [
                "title": "Korean Beef Bulgogi",
                "cook_time": "15 min", "prep_time": 15, "servings": 4, "calories": 450,
                "image_url": "https://images.unsplash.com/photo-1544025162-d76694265947?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["700g ribeye thinly sliced", "4 tbsp soy sauce", "2 tbsp sesame oil", "2 tbsp brown sugar", "4 garlic cloves minced", "2 tsp grated ginger", "1 Asian pear grated", "1 tbsp gochujang", "Spring onions and sesame seeds to serve"],
                "steps": ["Combine all marinade ingredients.", "Marinate beef at least 30 minutes.", "Cook beef in batches on very high heat 2–3 minutes until caramelised.", "Serve in lettuce cups with rice."],
                "substitutions": ["Use chicken thighs instead of beef", "Swap Asian pear for kiwi"],
                "difficulty": "medium", "cuisine_type": "korean", "cost_estimate": 16.00, "is_public": true,
                "tags": ["dinner", "korean", "gluten-free", "high-protein"]
            ],
            [
                "title": "Chicken & Black Bean Enchiladas",
                "cook_time": "35 min", "prep_time": 20, "servings": 4, "calories": 520,
                "image_url": "https://images.unsplash.com/photo-1599974579688-8dbdd335c77f?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["600g cooked chicken shredded", "400g can black beans drained", "8 flour tortillas", "400g enchilada sauce", "200g cheddar grated", "1 onion sautéed", "2 tsp cumin", "1 tsp smoked paprika", "Soured cream and guacamole to serve"],
                "steps": ["Preheat oven to 190°C.", "Mix chicken, beans, onion and spices.", "Spread sauce in baking dish.", "Roll filled tortillas seam-side down.", "Top with sauce and cheese, bake 30 minutes."],
                "substitutions": ["Use beef mince instead of chicken", "Corn tortillas for gluten-free"],
                "difficulty": "easy", "cuisine_type": "mexican", "cost_estimate": 13.00, "is_public": true,
                "tags": ["dinner", "mexican", "comfort", "family"]
            ],
            [
                "title": "Wild Mushroom Risotto",
                "cook_time": "35 min", "prep_time": 10, "servings": 4, "calories": 480,
                "image_url": "https://images.unsplash.com/photo-1476124369491-e7addf5db371?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["350g Arborio rice", "400g mixed wild mushrooms", "1 large onion diced", "3 garlic cloves minced", "150ml dry white wine", "1.2L hot vegetable stock", "60g butter", "100g parmesan grated", "2 tbsp olive oil", "Fresh thyme"],
                "steps": ["Keep stock warm separately.", "Sauté mushrooms until golden, set aside.", "Cook onion until soft, add garlic and rice.", "Toast rice 2 minutes, add wine until absorbed.", "Add stock one ladle at a time over 18–20 minutes.", "Remove from heat, stir in butter, parmesan and mushrooms."],
                "substitutions": ["Use asparagus or courgette", "Add truffle oil for a luxurious finish"],
                "difficulty": "medium", "cuisine_type": "italian", "cost_estimate": 11.00, "is_public": true,
                "tags": ["dinner", "vegetarian", "italian", "comfort"]
            ],
            [
                "title": "Classic Pad Thai with Prawns",
                "cook_time": "20 min", "prep_time": 15, "servings": 2, "calories": 540,
                "image_url": "https://images.unsplash.com/photo-1559314809-0d155014e29e?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["200g flat rice noodles", "300g raw king prawns peeled", "3 eggs", "3 tbsp fish sauce", "2 tbsp tamarind paste", "1 tbsp palm sugar", "100g bean sprouts", "50g roasted peanuts crushed", "Spring onions", "Lime wedges"],
                "steps": ["Soak noodles in warm water 20 minutes.", "Mix fish sauce, tamarind and sugar into sauce.", "Cook prawns in wok, push aside.", "Scramble eggs in wok.", "Add noodles and sauce, toss 2 minutes.", "Top with peanuts and lime."],
                "substitutions": ["Use tofu or chicken", "Soy sauce instead of fish sauce (vegan)"],
                "difficulty": "medium", "cuisine_type": "thai", "cost_estimate": 13.50, "is_public": true,
                "tags": ["dinner", "thai", "asian", "quick"]
            ],
            [
                "title": "Herb Butter Roast Chicken",
                "cook_time": "90 min", "prep_time": 15, "servings": 6, "calories": 510,
                "image_url": "https://images.unsplash.com/photo-1598103442097-8b74394b95c1?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["1 whole chicken 1.8kg", "100g butter softened", "4 garlic cloves minced", "1 tbsp fresh thyme", "1 tbsp fresh rosemary", "1 lemon halved", "Salt and black pepper", "500g new potatoes", "2 tbsp olive oil"],
                "steps": ["Preheat oven to 200°C.", "Mix butter with garlic and herbs.", "Rub herb butter under and over chicken skin.", "Season and stuff with lemon.", "Roast with potatoes 1h 20 min, basting halfway.", "Rest 15 minutes before carving."],
                "substitutions": ["Use chicken thighs for faster cooking", "Add root vegetables to roasting tin"],
                "difficulty": "medium", "cuisine_type": "british", "cost_estimate": 14.00, "is_public": true,
                "tags": ["dinner", "british", "comfort", "family", "meal-prep"]
            ],
            [
                "title": "Thai Green Curry with Tofu",
                "cook_time": "25 min", "prep_time": 10, "servings": 4, "calories": 420,
                "image_url": "https://images.unsplash.com/photo-1455619452474-d2be8b1e70cd?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["400g firm tofu cubed", "2 × 400ml cans coconut milk", "3 tbsp green curry paste", "200g baby corn", "150g mange tout", "1 red pepper sliced", "4 kaffir lime leaves", "2 tbsp fish sauce", "1 tbsp palm sugar", "Thai basil"],
                "steps": ["Pan-fry tofu until golden.", "Cook coconut cream from one can until bubbling.", "Add curry paste, cook 2 minutes.", "Add remaining coconut milk, lime leaves, fish sauce and sugar.", "Add vegetables and tofu, simmer 10 minutes.", "Finish with Thai basil."],
                "substitutions": ["Use chicken or prawns", "Soy sauce instead of fish sauce (vegan)"],
                "difficulty": "medium", "cuisine_type": "thai", "cost_estimate": 11.50, "is_public": true,
                "tags": ["dinner", "thai", "vegan", "gluten-free"]
            ],
            [
                "title": "Lamb Kofta with Tzatziki",
                "cook_time": "20 min", "prep_time": 15, "servings": 4, "calories": 460,
                "image_url": "https://images.unsplash.com/photo-1529042410759-befb1204b468?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["600g lamb mince", "1 onion grated", "3 garlic cloves minced", "2 tsp cumin", "1 tsp coriander", "½ tsp cinnamon", "2 tbsp parsley", "200g Greek yogurt", "1 cucumber grated and drained", "1 tbsp fresh mint"],
                "steps": ["Mix lamb with onion, garlic, cumin, coriander, cinnamon and parsley.", "Shape around skewers.", "Make tzatziki: combine yogurt, cucumber and mint.", "Grill kofta 8–10 minutes turning halfway.", "Serve with flatbread and tzatziki."],
                "substitutions": ["Use beef mince instead", "Shape into patties instead of skewers"],
                "difficulty": "easy", "cuisine_type": "middle-eastern", "cost_estimate": 15.00, "is_public": true,
                "tags": ["dinner", "middle-eastern", "gluten-free", "high-protein"]
            ],
            // MARK: Snacks
            [
                "title": "Homemade Hummus Platter",
                "cook_time": "5 min", "prep_time": 10, "servings": 6, "calories": 180,
                "image_url": "https://images.unsplash.com/photo-1534939561126-855b8675edd7?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 × 400g cans chickpeas drained", "4 tbsp tahini", "Juice of 2 lemons", "3 garlic cloves", "4 tbsp ice water", "Salt", "Extra-virgin olive oil", "Smoked paprika", "Pitta and crudités to serve"],
                "steps": ["Blend chickpeas, tahini, lemon and garlic 1 minute.", "Add ice water, blend 3 more minutes until very smooth.", "Season generously.", "Spread on a plate with a well in the centre.", "Drizzle with olive oil and dust with paprika."],
                "substitutions": ["Add roasted red peppers for variety", "Use white beans instead of chickpeas"],
                "difficulty": "easy", "cuisine_type": "middle-eastern", "cost_estimate": 5.00, "is_public": true,
                "tags": ["snack", "vegan", "middle-eastern", "meal-prep", "gluten-free"]
            ],
            [
                "title": "Dark Chocolate & Almond Energy Balls",
                "cook_time": "0 min", "prep_time": 15, "servings": 12, "calories": 140,
                "image_url": "https://images.unsplash.com/photo-1604329760661-e71dc83f8f26?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["200g medjool dates pitted", "100g rolled oats", "50g almond butter", "30g dark chocolate chips", "30g flaxseeds", "1 tsp vanilla extract", "Pinch of sea salt", "Desiccated coconut for rolling"],
                "steps": ["Soak dates 5 minutes, drain.", "Blend dates, oats, almond butter, flaxseeds, vanilla and salt.", "Stir in chocolate chips by hand.", "Roll into 12 balls, coat in coconut.", "Refrigerate 30 minutes. Store in fridge up to 2 weeks."],
                "substitutions": ["Use peanut butter instead", "Replace chips with dried cranberries"],
                "difficulty": "easy", "cuisine_type": "modern", "cost_estimate": 7.50, "is_public": true,
                "tags": ["snack", "vegan", "meal-prep", "no-bake", "healthy"]
            ],
            [
                "title": "Acai Power Bowl",
                "cook_time": "0 min", "prep_time": 10, "servings": 1, "calories": 390,
                "image_url": "https://images.unsplash.com/photo-1590301157284-f0c7a08e0bef?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["100g frozen acai pulp", "100g frozen blueberries", "1 frozen banana", "50ml coconut water", "2 tbsp granola", "Fresh banana slices", "Fresh strawberries", "1 tbsp honey", "1 tsp chia seeds", "Coconut flakes"],
                "steps": ["Blend acai, blueberries, banana and coconut water until thick.", "Pour into a chilled bowl.", "Arrange toppings: granola, fresh fruit, chia seeds and coconut flakes.", "Drizzle with honey and serve immediately."],
                "substitutions": ["Use frozen mango instead of acai", "Add spirulina for extra nutrients"],
                "difficulty": "easy", "cuisine_type": "brazilian", "cost_estimate": 6.00, "is_public": true,
                "tags": ["snack", "vegan", "no-cook", "healthy"]
            ],
            // MARK: Kenyan & East African
            [
                "title": "Nyama Choma (Kenyan Grilled Goat)",
                "cook_time": "60 min", "prep_time": 20, "servings": 4, "calories": 580,
                "image_url": "https://images.unsplash.com/photo-1555939594-58d7cb561ad1?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["1kg bone-in goat or beef ribs", "2 tsp coarse rock salt", "1 tsp coarsely ground black pepper", "1 tbsp vegetable oil", "3 tomatoes finely diced (kachumbari)", "1 red onion finely diced", "Juice of 1 lemon", "1 green chilli minced", "Fresh coriander"],
                "steps": ["Rub meat generously with salt, pepper and oil.", "Place over hot charcoal grill or high heat BBQ.", "Grill turning every 10 minutes for 50–60 minutes until charred outside and cooked through.", "Make kachumbari: combine tomatoes, onion, chilli, lemon juice and coriander.", "Serve meat sliced with kachumbari and ugali."],
                "substitutions": ["Use lamb chops or beef ribs", "Marinate overnight for deeper flavour"],
                "difficulty": "medium", "cuisine_type": "kenyan", "cost_estimate": 12.0, "is_public": true,
                "tags": ["dinner", "kenyan", "grilled", "gluten-free", "high-protein"]
            ],
            [
                "title": "Kenyan Pilau",
                "cook_time": "50 min", "prep_time": 15, "servings": 6, "calories": 520,
                "image_url": "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 cups basmati rice rinsed", "500g beef or chicken cubed", "2 large onions thinly sliced", "5 garlic cloves minced", "1 tsp grated ginger", "4 cardamom pods", "2 cinnamon sticks", "6 whole cloves", "1 tsp cumin seeds", "1 tsp black peppercorns", "1 tsp turmeric", "3 cups beef stock", "3 tbsp oil"],
                "steps": ["Toast cardamom, cinnamon, cloves, cumin and peppercorns in oil until fragrant.", "Add onion, cook on medium heat until deeply caramelised (20 minutes).", "Add garlic, ginger, turmeric and meat, brown well.", "Add rice, stir to coat in spices.", "Pour in stock, bring to boil then reduce heat.", "Cover and cook 20 minutes. Rest 10 minutes before serving."],
                "substitutions": ["Use goat instead of beef for more authentic flavour", "Add fried potato cubes on top"],
                "difficulty": "medium", "cuisine_type": "kenyan", "cost_estimate": 8.50, "is_public": true,
                "tags": ["dinner", "kenyan", "east-african", "rice", "spiced"]
            ],
            [
                "title": "Ugali na Sukuma Wiki",
                "cook_time": "30 min", "prep_time": 10, "servings": 4, "calories": 390,
                "image_url": "https://images.unsplash.com/photo-1546069901-ba9599a7e63c?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 cups maize meal (posho flour)", "4 cups water", "1 tsp salt", "1 large bunch collard greens finely shredded", "1 large onion diced", "3 tomatoes diced", "2 tbsp vegetable oil", "2 garlic cloves minced", "Salt and pepper to taste"],
                "steps": ["For ugali: bring salted water to boil, reduce heat, pour in maize meal in a steady stream while stirring.", "Stir continuously 10–15 minutes until very thick and pulls away from sides.", "Mould into a round dome to serve.", "For sukuma wiki: heat oil, fry onion and garlic until golden.", "Add tomatoes and cook until saucy.", "Add shredded greens, toss and cook 5 minutes until just tender."],
                "substitutions": ["Use kale or cavolo nero instead of collard greens", "Add fried egg on top for protein"],
                "difficulty": "easy", "cuisine_type": "kenyan", "cost_estimate": 3.50, "is_public": true,
                "tags": ["dinner", "kenyan", "vegan", "staple", "budget"]
            ],
            [
                "title": "Githeri (Maize & Bean Stew)",
                "cook_time": "90 min", "prep_time": 10, "servings": 6, "calories": 380,
                "image_url": "https://images.unsplash.com/photo-1574926054530-4bcf145fe25e?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 cups dried maize kernels soaked overnight", "1 cup dried kidney beans soaked overnight", "1 large onion diced", "3 large tomatoes diced", "2 tbsp oil", "3 garlic cloves minced", "1 tsp curry powder", "Salt and pepper", "Fresh coriander", "2 medium potatoes cubed (optional)"],
                "steps": ["Boil soaked maize and beans together in fresh water until tender (60–75 minutes).", "Heat oil in a separate pan, fry onion until golden.", "Add garlic, curry powder and tomatoes, cook into a thick sauce.", "Add potatoes if using and cook 15 minutes.", "Add boiled maize and beans to the sauce, mix well.", "Simmer 10 minutes, garnish with coriander."],
                "substitutions": ["Use canned beans and sweetcorn to save time", "Add spinach or sukuma wiki at the end"],
                "difficulty": "easy", "cuisine_type": "kenyan", "cost_estimate": 2.50, "is_public": true,
                "tags": ["lunch", "kenyan", "vegan", "budget", "meal-prep", "high-protein"]
            ],
            [
                "title": "Mukimo (Kenyan Green Potato Mash)",
                "cook_time": "30 min", "prep_time": 15, "servings": 4, "calories": 360,
                "image_url": "https://images.unsplash.com/photo-1466637574441-749b8f19452f?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["6 large potatoes peeled and cubed", "1 cup fresh or frozen green peas", "1 cup sweetcorn kernels", "1 cup pumpkin leaves or spinach shredded", "1 onion diced", "2 tbsp butter", "Salt to taste", "Milk to loosen (optional)"],
                "steps": ["Boil potatoes until tender, add peas and corn to pot for last 5 minutes.", "In a separate pan, sauté onion in butter until soft.", "Add shredded greens to onion, cook 3 minutes until wilted.", "Drain potatoes, peas and corn.", "Mash everything together including greens.", "Season with salt, add milk if too thick."],
                "substitutions": ["Use sweet potato for a different flavour", "Add roasted groundnuts for crunch"],
                "difficulty": "easy", "cuisine_type": "kenyan", "cost_estimate": 3.00, "is_public": true,
                "tags": ["lunch", "kenyan", "vegetarian", "budget", "comfort", "gluten-free"]
            ],
            [
                "title": "Mandazi (East African Doughnuts)",
                "cook_time": "20 min", "prep_time": 20, "servings": 16, "calories": 180,
                "image_url": "https://images.unsplash.com/photo-1551024601-bec78aea704b?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["3 cups plain flour", "½ cup sugar", "2 tsp baking powder", "1 tsp ground cardamom", "½ tsp cinnamon", "¾ cup coconut milk", "1 egg beaten", "1 tsp vanilla extract", "Oil for deep-frying", "Icing sugar to dust"],
                "steps": ["Mix flour, sugar, baking powder, cardamom and cinnamon.", "Whisk egg, coconut milk and vanilla together.", "Combine wet and dry ingredients into a soft dough, do not over-knead.", "Roll out to 1cm thick, cut into triangles.", "Heat oil to 180°C, fry in batches 3–4 minutes until golden.", "Drain on paper, dust with icing sugar."],
                "substitutions": ["Use regular milk instead of coconut milk", "Add grated coconut to the dough"],
                "difficulty": "easy", "cuisine_type": "kenyan", "cost_estimate": 2.00, "is_public": true,
                "tags": ["breakfast", "snack", "kenyan", "east-african", "fried", "sweet"]
            ],
            [
                "title": "Maharagwe ya Nazi (Coconut Kidney Beans)",
                "cook_time": "60 min", "prep_time": 10, "servings": 4, "calories": 420,
                "image_url": "https://images.unsplash.com/photo-1601050690597-df0568f70950?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 cups dried red kidney beans soaked overnight", "400ml coconut milk", "2 large tomatoes diced", "1 onion diced", "3 garlic cloves minced", "1 tsp turmeric", "1 tsp cumin", "1 green chilli", "Salt to taste", "Fresh coriander"],
                "steps": ["Boil kidney beans in fresh water until tender (45–60 minutes).", "Fry onion and garlic until golden.", "Add tomatoes, turmeric, cumin and chilli, cook into a sauce.", "Add cooked beans with some cooking liquid.", "Pour in coconut milk, simmer 20 minutes uncovered.", "Beans should be in a thick, creamy coconut sauce."],
                "substitutions": ["Use canned kidney beans to save time", "Add spinach for extra nutrients"],
                "difficulty": "easy", "cuisine_type": "kenyan", "cost_estimate": 4.00, "is_public": true,
                "tags": ["dinner", "kenyan", "coastal", "vegan", "gluten-free", "budget"]
            ],
            [
                "title": "Kenyan Chapati",
                "cook_time": "30 min", "prep_time": 20, "servings": 8, "calories": 240,
                "image_url": "https://images.unsplash.com/photo-1574894709920-11b28e7367e3?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["3 cups plain flour", "1 cup warm water", "1 tsp salt", "2 tbsp vegetable oil", "Extra oil for cooking layers"],
                "steps": ["Combine flour and salt, add oil and water gradually.", "Knead 10 minutes until smooth and elastic.", "Divide into 8 balls, cover and rest 20 minutes.", "Roll each ball flat, brush with oil.", "Roll into a log then coil like a snail, flatten again.", "Cook in a dry pan on medium heat 2–3 minutes per side until golden with charred spots."],
                "substitutions": ["Add a little milk for softer chapati", "Whole wheat flour for a healthier version"],
                "difficulty": "easy", "cuisine_type": "kenyan", "cost_estimate": 1.50, "is_public": true,
                "tags": ["bread", "kenyan", "vegan", "staple", "side"]
            ],
            [
                "title": "Mchuzi wa Kuku (Kenyan Chicken Stew)",
                "cook_time": "50 min", "prep_time": 15, "servings": 4, "calories": 460,
                "image_url": "https://images.unsplash.com/photo-1574071318508-1cdbab80d002?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["1 whole chicken jointed into pieces", "3 large tomatoes diced", "2 large onions diced", "4 garlic cloves minced", "1 tsp turmeric", "1 tsp curry powder", "1 tsp coriander powder", "2 tbsp oil", "400ml water or chicken stock", "Salt and pepper", "Fresh coriander"],
                "steps": ["Brown chicken pieces in hot oil on all sides.", "Remove chicken, fry onion and garlic until golden.", "Add tomatoes, turmeric, curry powder and coriander, cook 8 minutes.", "Return chicken to pan, add stock.", "Simmer covered 35–40 minutes until chicken is tender.", "Sauce should be thick and coating. Serve with ugali or rice."],
                "substitutions": ["Use goat for nyama ya mbuzi stew", "Add potatoes to make it more filling"],
                "difficulty": "easy", "cuisine_type": "kenyan", "cost_estimate": 8.50, "is_public": true,
                "tags": ["dinner", "kenyan", "gluten-free", "family", "comfort"]
            ],
            [
                "title": "Viazi Karai (Kenyan Street Potato Fritters)",
                "cook_time": "20 min", "prep_time": 15, "servings": 4, "calories": 320,
                "image_url": "https://images.unsplash.com/photo-1518977676601-b53f82aba655?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["500g medium potatoes", "1 cup chickpea flour (besan)", "1 tsp cumin", "1 tsp coriander", "½ tsp turmeric", "½ tsp chilli powder", "Water to make batter", "Oil for deep-frying", "Tamarind chutney to serve", "Sliced onion and coriander to garnish"],
                "steps": ["Boil potatoes until just cooked, cool and peel.", "Slice into thick rounds.", "Mix chickpea flour with spices and enough water to make a thick batter.", "Season batter with salt.", "Heat oil to 175°C.", "Dip potato slices in batter, fry 3–4 minutes until golden and crispy.", "Serve with tamarind chutney and garnish."],
                "substitutions": ["Use cassava or sweet potato", "Add grated ginger to batter for extra warmth"],
                "difficulty": "easy", "cuisine_type": "kenyan", "cost_estimate": 2.80, "is_public": true,
                "tags": ["snack", "kenyan", "street-food", "vegan", "Mombasa"]
            ],
            [
                "title": "Samaki wa Nazi (Coastal Fish in Coconut)",
                "cook_time": "30 min", "prep_time": 15, "servings": 4, "calories": 400,
                "image_url": "https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["4 whole tilapia or red snapper fillets", "400ml coconut milk", "3 large tomatoes diced", "1 onion diced", "4 garlic cloves minced", "1 tbsp fresh ginger grated", "1 tsp turmeric", "1 tsp cumin", "1 green chilli", "Juice of 1 lime", "Fresh coriander", "Salt"],
                "steps": ["Score fish and season with salt and turmeric.", "Fry fish 2 minutes per side in hot oil, set aside.", "In same pan, fry onion, garlic and ginger until golden.", "Add tomatoes, cumin and chilli, cook 8 minutes until saucy.", "Pour in coconut milk, bring to gentle simmer.", "Add fish, cook 12–15 minutes. Finish with lime juice and coriander."],
                "substitutions": ["Use king prawns instead of fish", "Add okra for a thicker sauce"],
                "difficulty": "medium", "cuisine_type": "kenyan", "cost_estimate": 9.50, "is_public": true,
                "tags": ["dinner", "kenyan", "coastal", "seafood", "gluten-free"]
            ],
            // MARK: West African
            [
                "title": "Jollof Rice with Fried Plantain",
                "cook_time": "50 min", "prep_time": 15, "servings": 6, "calories": 510,
                "image_url": "https://images.unsplash.com/photo-1536304993881-ff86d57456de?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["3 cups long-grain parboiled rice", "400g can crushed tomatoes", "2 red bell peppers blended", "1 scotch bonnet pepper", "1 large onion blended", "3 tbsp tomato purée", "4 cups chicken stock", "1 tsp curry powder", "1 tsp thyme", "Salt and seasoning", "3 ripe plantains", "Oil"],
                "steps": ["Blend tomatoes, peppers and onion into a sauce.", "Fry blended sauce in oil 20 minutes until reduced and deep red.", "Add tomato purée, curry powder, thyme and stock.", "Rinse rice, add to sauce, stir well.", "Cook covered on medium-low for 25 minutes, check and stir halfway.", "Slice plantains, fry in oil until golden. Serve alongside."],
                "substitutions": ["Use jasmine rice for a different texture", "Add chicken pieces to cook in the rice"],
                "difficulty": "medium", "cuisine_type": "west-african", "cost_estimate": 7.00, "is_public": true,
                "tags": ["dinner", "west-african", "rice", "comfort", "vegan"]
            ],
            // MARK: More Global Variety
            [
                "title": "Chicken Shawarma Platter",
                "cook_time": "25 min", "prep_time": 20, "servings": 4, "calories": 510,
                "image_url": "https://images.unsplash.com/photo-1529006557810-274b9b2fc783?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["700g chicken thighs boneless", "3 tbsp yogurt", "2 tsp cumin", "2 tsp coriander", "1 tsp turmeric", "1 tsp smoked paprika", "½ tsp cinnamon", "4 garlic cloves", "Juice of 1 lemon", "Pitta bread", "Garlic sauce", "Pickled turnips", "Parsley"],
                "steps": ["Mix yogurt, spices, garlic and lemon, marinate chicken 2 hours or overnight.", "Cook chicken on a hot grill or oven at 220°C for 20–25 minutes.", "Rest and slice thinly.", "Serve in warm pitta with garlic sauce, pickled turnips and parsley."],
                "substitutions": ["Use lamb for a more traditional version", "Serve as a wrap for street-food style"],
                "difficulty": "easy", "cuisine_type": "middle-eastern", "cost_estimate": 11.00, "is_public": true,
                "tags": ["dinner", "middle-eastern", "high-protein", "gluten-free-option"]
            ],
            [
                "title": "Teriyaki Salmon Bowl",
                "cook_time": "15 min", "prep_time": 10, "servings": 2, "calories": 520,
                "image_url": "https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 salmon fillets", "3 tbsp soy sauce", "2 tbsp mirin", "1 tbsp sake", "1 tbsp brown sugar", "2 cups cooked Japanese rice", "1 avocado sliced", "100g edamame", "1 cucumber sliced", "Sesame seeds", "Spring onions", "Pickled ginger"],
                "steps": ["Mix soy sauce, mirin, sake and sugar into teriyaki sauce.", "Marinate salmon 15 minutes.", "Grill or pan-fry salmon 3–4 minutes per side, glazing with extra sauce.", "Assemble bowls with rice, avocado, edamame and cucumber.", "Place salmon on top, drizzle remaining sauce.", "Garnish with sesame seeds, spring onions and pickled ginger."],
                "substitutions": ["Use tofu for vegetarian version", "Replace rice with cauliflower rice (low-carb)"],
                "difficulty": "easy", "cuisine_type": "japanese", "cost_estimate": 14.50, "is_public": true,
                "tags": ["dinner", "japanese", "healthy", "high-protein", "gluten-free"]
            ],
            [
                "title": "Beef Tacos with Pico de Gallo",
                "cook_time": "20 min", "prep_time": 15, "servings": 4, "calories": 490,
                "image_url": "https://images.unsplash.com/photo-1565299585323-38d6b0865b47?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["500g beef mince", "1 tsp cumin", "1 tsp chilli powder", "½ tsp smoked paprika", "½ tsp garlic powder", "8 corn tortillas", "3 tomatoes finely diced", "1 red onion finely diced", "1 jalapeño minced", "Fresh coriander", "Juice of 2 limes", "Soured cream and guacamole"],
                "steps": ["Brown beef, drain fat, add all spices and a splash of water.", "Cook 5 minutes until sauce coats the meat.", "For pico: combine tomatoes, red onion, jalapeño, coriander and lime.", "Warm tortillas in a dry pan.", "Fill with beef, top with pico, soured cream and guacamole."],
                "substitutions": ["Use chicken or pork", "Double the jalapeño for extra heat"],
                "difficulty": "easy", "cuisine_type": "mexican", "cost_estimate": 10.50, "is_public": true,
                "tags": ["dinner", "mexican", "family", "quick", "gluten-free"]
            ],
            [
                "title": "Miso-Glazed Aubergine",
                "cook_time": "25 min", "prep_time": 10, "servings": 4, "calories": 280,
                "image_url": "https://images.unsplash.com/photo-1481304453051-c5f7a1a6c0b0?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2 large aubergines halved", "3 tbsp white miso paste", "2 tbsp mirin", "1 tbsp sake", "1 tbsp sesame oil", "1 tsp sugar", "Sesame seeds", "Spring onions", "Steamed rice to serve"],
                "steps": ["Score aubergine flesh in a cross-hatch pattern.", "Brush with sesame oil and grill flesh-side down 5 minutes.", "Mix miso, mirin, sake and sugar into a glaze.", "Spread glaze over scored flesh.", "Grill under high heat 8–10 minutes until caramelised.", "Scatter sesame seeds and spring onions."],
                "substitutions": ["Use red miso for stronger flavour", "Add a drizzle of chilli oil"],
                "difficulty": "easy", "cuisine_type": "japanese", "cost_estimate": 6.50, "is_public": true,
                "tags": ["dinner", "japanese", "vegan", "healthy", "umami"]
            ],
            [
                "title": "Creamy Tuscan Garlic Chicken",
                "cook_time": "30 min", "prep_time": 10, "servings": 4, "calories": 530,
                "image_url": "https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["4 chicken breasts", "6 garlic cloves minced", "1 cup sun-dried tomatoes", "2 cups baby spinach", "1 cup double cream", "½ cup chicken stock", "50g parmesan grated", "1 tsp Italian seasoning", "2 tbsp olive oil", "Salt and pepper"],
                "steps": ["Season chicken, sear in hot oil 5 minutes per side until golden, set aside.", "In same pan, fry garlic 1 minute.", "Add sun-dried tomatoes, cook 2 minutes.", "Pour in stock and cream, bring to simmer.", "Add parmesan and Italian seasoning, stir.", "Return chicken to pan, add spinach, cook 5–7 minutes until sauce thickens."],
                "substitutions": ["Use half-fat cream for lighter version", "Add mushrooms for extra depth"],
                "difficulty": "easy", "cuisine_type": "italian", "cost_estimate": 14.00, "is_public": true,
                "tags": ["dinner", "italian", "creamy", "high-protein", "gluten-free"]
            ],
            [
                "title": "Pho Bo (Vietnamese Beef Noodle Soup)",
                "cook_time": "180 min", "prep_time": 20, "servings": 6, "calories": 420,
                "image_url": "https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["2kg beef bones", "500g beef brisket", "1 large onion charred", "5cm ginger charred", "3 star anise", "3 cloves", "1 cinnamon stick", "1 tbsp fish sauce", "400g rice noodles", "200g ribeye thinly sliced raw", "Bean sprouts", "Thai basil", "Lime wedges", "Sliced chillies"],
                "steps": ["Blanch bones, rinse well.", "Char onion and ginger directly on flame.", "Simmer bones and brisket with charred veg and spices 3 hours.", "Strain broth, season with fish sauce and salt.", "Cook rice noodles separately, drain.", "Divide noodles into bowls, top with broth, brisket slices and raw beef.", "Serve immediately with bean sprouts, basil, lime and chilli."],
                "substitutions": ["Use chicken for pho ga", "Shortcut: use good-quality beef stock with spices"],
                "difficulty": "hard", "cuisine_type": "vietnamese", "cost_estimate": 18.00, "is_public": true,
                "tags": ["dinner", "vietnamese", "soup", "gluten-free", "weekend"]
            ],
            [
                "title": "Shakshuka Verde",
                "cook_time": "20 min", "prep_time": 10, "servings": 4, "calories": 260,
                "image_url": "https://images.unsplash.com/photo-1525351484163-7529414344d8?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["6 large eggs", "400g tomatillos", "2 jalapeños", "1 green pepper", "1 onion diced", "3 garlic cloves", "100g baby spinach", "50g feta", "1 tsp cumin", "Fresh coriander", "Sourdough to serve"],
                "steps": ["Blend tomatillos, jalapeños and green pepper.", "Sauté onion and garlic.", "Add blended sauce and cumin, simmer 8 minutes.", "Add spinach and stir in.", "Make 6 wells, crack in eggs.", "Cover and cook 6–8 minutes. Top with feta and coriander."],
                "substitutions": ["Use canned green salsa instead of tomatillos", "Add avocado slices on top"],
                "difficulty": "easy", "cuisine_type": "mexican", "cost_estimate": 7.50, "is_public": true,
                "tags": ["breakfast", "mexican", "vegetarian", "one-pan"]
            ],
            [
                "title": "Lamb Biryani",
                "cook_time": "90 min", "prep_time": 30, "servings": 6, "calories": 620,
                "image_url": "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=800&q=80",
                "ingredients": ["700g lamb shoulder cubed", "3 cups basmati rice", "2 cups yogurt", "2 large onions sliced", "4 garlic cloves", "1 tbsp ginger", "1 tsp saffron soaked in warm milk", "2 tsp biryani spice", "4 cardamom pods", "Fried onion (birista)", "Fresh mint and coriander"],
                "steps": ["Marinate lamb in yogurt and spices 2 hours.", "Fry onion until crispy golden (birista).", "Cook marinated lamb 30 minutes.", "Parboil rice until 70% cooked, drain.", "Layer rice over lamb, drizzle saffron milk.", "Top with birista, mint and coriander.", "Cook covered on very low heat 30 minutes (dum cooking)."],
                "substitutions": ["Use chicken for quicker cooking", "Add boiled eggs for extra protein"],
                "difficulty": "hard", "cuisine_type": "indian", "cost_estimate": 18.00, "is_public": true,
                "tags": ["dinner", "indian", "rice", "weekend", "celebration"]
            ],
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
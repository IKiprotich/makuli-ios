//
//  MockPlans.swift
//  Makuli
//
//  Created by Ian on 2025-06-13.
//

#if DEBUG
import Foundation

enum MockPlans {

    static let mockUserId = "mock-user-preview-000"

    // MARK: - Date Helpers

    private static var calendar: Calendar { Calendar.current }
    private static var thisMonday: Date {
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysFromMonday = (weekday == 1) ? 6 : weekday - 2
        return calendar.startOfDay(for: calendar.date(byAdding: .day, value: -daysFromMonday, to: today)!)
    }

    private static func date(daysFrom monday: Date, offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: monday)!
    }

    // MARK: - Current Week Plan
    static var currentWeekPlan: Plan {
        let monday = thisMonday
        return Plan(
            id: "mock-plan-current-week",
            userId: mockUserId,
            title: "Mediterranean Week",
            weekStart: monday,
            weekEnd: date(daysFrom: monday, offset: 6),
            totalCost: 87.50,
            isCompleted: false,
            createdAt: calendar.date(byAdding: .day, value: -2, to: monday)!,
            updatedAt: Date(),
            templateId: nil,
            generationMethod: "template",
            isFavorite: true,
            completionPercentage: 38.0
        )
    }

    static var currentWeekRecipes: [PlanRecipe] {
        let planId = "mock-plan-current-week"
        let monday = thisMonday
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let dayOffsets = [0, 1, 2, 3, 4, 5, 6]
        let dayOfWeeks = [1, 2, 3, 4, 5, 6, 0]

        var meals: [PlanRecipe] = []
        var position = 0

        let mealPlan: [(String, String, String?, Int?)] = [
            ("breakfast", "Avocado Toast with Poached Eggs",     "mock-recipe-001", 10),
            ("lunch",     "Roasted Vegetable Quinoa Bowl",        "mock-recipe-008", 30),
            ("dinner",    "Mediterranean Herb-Crusted Salmon",    "mock-recipe-015", 20),
            ("breakfast", "Spinach & Feta Omelette",             "mock-recipe-006",  8),
            ("lunch",     "Classic Caesar Salad",                 "mock-recipe-007", 10),
            ("dinner",    "Wild Mushroom Risotto",                "mock-recipe-020", 35),
            ("breakfast", "Greek Yogurt Parfait with Granola",   "mock-recipe-002",  0),
            ("lunch",     "Tuna Niçoise Salad",                  "mock-recipe-014", 15),
            ("dinner",    "Chicken Tikka Masala",                "mock-recipe-016", 40),
            ("breakfast", "Overnight Oats with Chia & Berries",  "mock-recipe-005",  0),
            ("lunch",     "Spiced Red Lentil Soup",              "mock-recipe-009", 35),
            ("dinner",    "Classic Spaghetti Bolognese",         "mock-recipe-017", 60),
            ("breakfast", "Banana Protein Pancakes",             "mock-recipe-004", 15),
            ("lunch",     "Turkey & Avocado Club Wrap",          "mock-recipe-012",  5),
            ("dinner",    "Herb Butter Roast Chicken",           "mock-recipe-022", 90),
            ("breakfast", "Shakshuka with Feta",                 "mock-recipe-003", 25),
            ("lunch",     "Korean Bibimbap Bowl",                "mock-recipe-013", 30),
            ("dinner",    "Korean Beef Bulgogi",                 "mock-recipe-018", 15),
            ("breakfast", "Avocado Toast with Poached Eggs",     "mock-recipe-001", 10),
            ("lunch",     "Fresh Vietnamese Spring Rolls",       "mock-recipe-010", 15),
            ("dinner",    "Thai Green Curry with Tofu",          "mock-recipe-023", 25),
        ]

        for (index, (mealType, name, recipeId, cookTime)) in mealPlan.enumerated() {
            let dayIndex = index / 3
            let isCompleted = index < 6
            let completedAt: Date? = isCompleted
                ? calendar.date(byAdding: .day, value: dayIndex, to: monday)
                : nil

            meals.append(PlanRecipe(
                id: "mock-planrecipe-current-\(String(format: "%02d", index))",
                planId: planId,
                recipeId: recipeId,
                dayOfWeek: dayOfWeeks[dayIndex],
                mealType: mealType,
                position: position,
                day: days[dayIndex],
                isCompleted: isCompleted,
                completedAt: completedAt,
                customMealName: name,
                customIngredients: nil,
                customInstructions: nil,
                customCookTime: cookTime,
                notes: nil
            ))
            position += 1
        }

        return meals
    }

    // MARK: - Past Plan 1 (last week — completed)

    static var lastWeekPlan: Plan {
        let monday = calendar.date(byAdding: .day, value: -7, to: thisMonday)!
        return Plan(
            id: "mock-plan-last-week",
            userId: mockUserId,
            title: "Asian Fusion Week",
            weekStart: monday,
            weekEnd: date(daysFrom: monday, offset: 6),
            totalCost: 76.00,
            isCompleted: true,
            createdAt: calendar.date(byAdding: .day, value: -9, to: monday)!,
            updatedAt: calendar.date(byAdding: .day, value: 6, to: monday)!,
            templateId: nil,
            generationMethod: "template",
            isFavorite: false,
            completionPercentage: 100.0
        )
    }

    static var lastWeekRecipes: [PlanRecipe] {
        let planId = "mock-plan-last-week"
        let monday = calendar.date(byAdding: .day, value: -7, to: thisMonday)!
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let dayOfWeeks = [1, 2, 3, 4, 5, 6, 0]

        let mealPlan: [(String, String, String?, Int?)] = [
            ("breakfast", "Overnight Oats with Chia & Berries",  "mock-recipe-005",  0),
            ("lunch",     "Thai Peanut Noodles",                 "mock-recipe-011", 15),
            ("dinner",    "Korean Beef Bulgogi",                 "mock-recipe-018", 15),
            ("breakfast", "Greek Yogurt Parfait with Granola",   "mock-recipe-002",  0),
            ("lunch",     "Korean Bibimbap Bowl",                "mock-recipe-013", 30),
            ("dinner",    "Pad Thai with Prawns",                "mock-recipe-021", 20),
            ("breakfast", "Banana Protein Pancakes",             "mock-recipe-004", 15),
            ("lunch",     "Fresh Vietnamese Spring Rolls",       "mock-recipe-010", 15),
            ("dinner",    "Thai Green Curry with Tofu",          "mock-recipe-023", 25),
            ("breakfast", "Spinach & Feta Omelette",             "mock-recipe-006",  8),
            ("lunch",     "Thai Peanut Noodles",                 "mock-recipe-011", 15),
            ("dinner",    "Chicken Tikka Masala",                "mock-recipe-016", 40),
            ("breakfast", "Overnight Oats with Chia & Berries",  "mock-recipe-005",  0),
            ("lunch",     "Korean Bibimbap Bowl",                "mock-recipe-013", 30),
            ("dinner",    "Korean Beef Bulgogi",                 "mock-recipe-018", 15),
            ("breakfast", "Avocado Toast with Poached Eggs",     "mock-recipe-001", 10),
            ("lunch",     "Fresh Vietnamese Spring Rolls",       "mock-recipe-010", 15),
            ("dinner",    "Pad Thai with Prawns",                "mock-recipe-021", 20),
            ("breakfast", "Shakshuka with Feta",                 "mock-recipe-003", 25),
            ("lunch",     "Thai Peanut Noodles",                 "mock-recipe-011", 15),
            ("dinner",    "Thai Green Curry with Tofu",          "mock-recipe-023", 25),
        ]

        return mealPlan.enumerated().map { (index, tuple) in
            let (mealType, name, recipeId, cookTime) = tuple
            let dayIndex = index / 3
            let completedAt = calendar.date(byAdding: .day, value: dayIndex, to: monday)!
            return PlanRecipe(
                id: "mock-planrecipe-last-\(String(format: "%02d", index))",
                planId: planId,
                recipeId: recipeId,
                dayOfWeek: dayOfWeeks[dayIndex],
                mealType: mealType,
                position: index,
                day: days[dayIndex],
                isCompleted: true,
                completedAt: completedAt,
                customMealName: name,
                customIngredients: nil,
                customInstructions: nil,
                customCookTime: cookTime,
                notes: nil
            )
        }
    }

    // MARK: - Past Plan 2 (two weeks ago — completed, favourited)

    static var twoWeeksAgoPlan: Plan {
        let monday = calendar.date(byAdding: .day, value: -14, to: thisMonday)!
        return Plan(
            id: "mock-plan-two-weeks",
            userId: mockUserId,
            title: "Budget-Friendly Week",
            weekStart: monday,
            weekEnd: date(daysFrom: monday, offset: 6),
            totalCost: 42.00,
            isCompleted: true,
            createdAt: calendar.date(byAdding: .day, value: -16, to: monday)!,
            updatedAt: calendar.date(byAdding: .day, value: 6, to: monday)!,
            templateId: nil,
            generationMethod: "template",
            isFavorite: true,
            completionPercentage: 100.0
        )
    }

    static var twoWeeksAgoRecipes: [PlanRecipe] {
        let planId = "mock-plan-two-weeks"
        let monday = calendar.date(byAdding: .day, value: -14, to: thisMonday)!
        let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let dayOfWeeks = [1, 2, 3, 4, 5, 6, 0]

        let mealPlan: [(String, String, String?, Int?)] = [
            ("breakfast", "Overnight Oats with Chia & Berries",  "mock-recipe-005",  0),
            ("lunch",     "Spiced Red Lentil Soup",              "mock-recipe-009", 35),
            ("dinner",    "Classic Spaghetti Bolognese",         "mock-recipe-017", 60),
            ("breakfast", "Banana Protein Pancakes",             "mock-recipe-004", 15),
            ("lunch",     "Turkey & Avocado Club Wrap",          "mock-recipe-012",  5),
            ("dinner",    "Chicken & Black Bean Enchiladas",     "mock-recipe-019", 35),
            ("breakfast", "Greek Yogurt Parfait with Granola",   "mock-recipe-002",  0),
            ("lunch",     "Spiced Red Lentil Soup",              "mock-recipe-009", 35),
            ("dinner",    "Classic Spaghetti Bolognese",         "mock-recipe-017", 60),
            ("breakfast", "Overnight Oats with Chia & Berries",  "mock-recipe-005",  0),
            ("lunch",     "Turkey & Avocado Club Wrap",          "mock-recipe-012",  5),
            ("dinner",    "Herb Butter Roast Chicken",           "mock-recipe-022", 90),
            ("breakfast", "Banana Protein Pancakes",             "mock-recipe-004", 15),
            ("lunch",     "Spiced Red Lentil Soup",              "mock-recipe-009", 35),
            ("dinner",    "Chicken & Black Bean Enchiladas",     "mock-recipe-019", 35),
            ("breakfast", "Spinach & Feta Omelette",             "mock-recipe-006",  8),
            ("lunch",     "Classic Caesar Salad",                "mock-recipe-007", 10),
            ("dinner",    "Classic Spaghetti Bolognese",         "mock-recipe-017", 60),
            ("breakfast", "Shakshuka with Feta",                 "mock-recipe-003", 25),
            ("lunch",     "Roasted Vegetable Quinoa Bowl",       "mock-recipe-008", 30),
            ("dinner",    "Herb Butter Roast Chicken",           "mock-recipe-022", 90),
        ]

        return mealPlan.enumerated().map { (index, tuple) in
            let (mealType, name, recipeId, cookTime) = tuple
            let dayIndex = index / 3
            let completedAt = calendar.date(byAdding: .day, value: dayIndex, to: monday)!
            return PlanRecipe(
                id: "mock-planrecipe-two-\(String(format: "%02d", index))",
                planId: planId,
                recipeId: recipeId,
                dayOfWeek: dayOfWeeks[dayIndex],
                mealType: mealType,
                position: index,
                day: days[dayIndex],
                isCompleted: true,
                completedAt: completedAt,
                customMealName: name,
                customIngredients: nil,
                customInstructions: nil,
                customCookTime: cookTime,
                notes: nil
            )
        }
    }

    // MARK: - Convenience Accessors

    static var allPlans: [Plan] {
        [currentWeekPlan, lastWeekPlan, twoWeeksAgoPlan]
    }

    static var allPlanRecipes: [String: [PlanRecipe]] {
        [
            currentWeekPlan.id: currentWeekRecipes,
            lastWeekPlan.id: lastWeekRecipes,
            twoWeeksAgoPlan.id: twoWeeksAgoRecipes,
        ]
    }

    static var todaysMeals: [PlanRecipe] {
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let targetDayOfWeek = weekday - 1
        return currentWeekRecipes.filter { $0.dayOfWeek == targetDayOfWeek }
    }

    static var upcomingMeals: [PlanRecipe] {
        let today = Date()
        let weekday = Calendar.current.component(.weekday, from: today)
        let todayDayOfWeek = weekday - 1
        return currentWeekRecipes
            .filter { $0.dayOfWeek > todayDayOfWeek }
            .prefix(6)
            .map { $0 }
    }
}
#endif

//
//  MealPlanModels.swift
//  Makuli
//
//  Created by Ian   on 20/06/2025.
//

import Foundation

struct WeekPlan: Identifiable, Hashable {
    let id = UUID()
    let weekNumber: Int
    let startDate: Date
    let endDate: Date
    let totalCost: Double
    let mealsCompleted: Int
    let totalMeals: Int
    let planName: String
    let featuredImageName: String
    let isActive: Bool
    let meals: [Meal]
    
    var progressPercentage: Double {
        guard totalMeals > 0 else { return 0 }
        return Double(mealsCompleted) / Double(totalMeals)
    }
    
    var costFormatted: String {
        return "Ksh \(Int(totalCost).formatted())"
    }
    
    var weekTitle: String {
        return "Wk \(weekNumber)"
    }
    
    var dateRangeFormatted: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let startString = formatter.string(from: startDate)
        let endString = formatter.string(from: endDate)
        return "\(startString) - \(endString)"
    }
}

struct DayPlan: Identifiable {
    let id = UUID()
    let date: Date
    let meals: [Meal]
    let isCompleted: Bool
}

struct Meal: Identifiable, Equatable, Hashable {
    let id = UUID()
    let name: String
    let category: MealCategory
    let cookingTime: Int // minutes
    let difficulty: DifficultyLevel
    let imageURL: String?
    let isCompleted: Bool
    let recipe: Recipe?
    
    init(name: String, category: MealCategory, cookingTime: Int, difficulty: DifficultyLevel, imageURL: String? = nil, isCompleted: Bool = false, recipe: Recipe? = nil) {
        self.name = name
        self.category = category
        self.cookingTime = cookingTime
        self.difficulty = difficulty
        self.imageURL = imageURL
        self.isCompleted = isCompleted
        self.recipe = recipe
    }
    
    // MARK: - Equatable
    static func == (lhs: Meal, rhs: Meal) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    enum MealCategory: String, CaseIterable, Codable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        
        var icon: String {
            switch self {
            case .breakfast: return "sun.max.fill"
            case .lunch: return "sun.haze.fill"
            case .dinner: return "moon.stars.fill"
            }
        }
    }
    
    enum DifficultyLevel: String, CaseIterable, Codable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
    }
}

// MARK: - Mock Data Extensions
extension WeekPlan {
    static let mockData: [WeekPlan] = [
        WeekPlan(
            weekNumber: 26,
            startDate: Calendar.current.date(byAdding: .day, value: 0, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: 6, to: Date()) ?? Date(),
            totalCost: 1800,
            mealsCompleted: 3,
            totalMeals: 7,
            planName: "Coastal Favorites",
            featuredImageName: "meal_coastal",
            isActive: false,
            meals: []
        ),
        WeekPlan(
            weekNumber: 25,
            startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(),
            totalCost: 1500,
            mealsCompleted: 6,
            totalMeals: 7,
            planName: "Traditional Mix",
            featuredImageName: "meal_traditional",
            isActive: false,
            meals: []
        ),
        WeekPlan(
            weekNumber: 24,
            startDate: Calendar.current.date(byAdding: .day, value: -14, to: Date()) ?? Date(),
            endDate: Calendar.current.date(byAdding: .day, value: -8, to: Date()) ?? Date(),
            totalCost: 1200,
            mealsCompleted: 4,
            totalMeals: 7,
            planName: "Kenyan Stew",
            featuredImageName: "meal_stew",
            isActive: true,
            meals: []
        )
    ]
}

extension DayPlan {
    static func mockData() -> [DayPlan] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: Int(dayOffset), to: today) ?? today
            return DayPlan(
                date: date,
                meals: generateMockMealsForDay(dayOffset: dayOffset),
                isCompleted: dayOffset < 3 // First 3 days completed
            )
        }
    }
    
    var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: date)
    }
    
    var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
}

// MARK: - Mock meal data with authentic Kenyan dishes
func generateMockMealsForDay(dayOffset: Int) -> [Meal] {
    let kenyanMeals: [(String, Meal.MealCategory, Int, Recipe?)] = [
        // Breakfast options
        ("Mandazi", .breakfast, 30, nil),
        ("Chai na Mahamri", .breakfast, 20, nil),
        ("Githeri", .breakfast, 45, nil),
        
        // Lunch options - some with recipes
        ("Nyama Choma", .lunch, 60, Recipe.nyamaChomaRecipe),
        ("Ugali na Sukuma", .lunch, 40, nil),
        ("Pilau", .lunch, 75, Recipe.pilauRecipe),
        ("Matoke with Beans", .lunch, 45, Recipe.sampleRecipe),
        ("Samaki wa Nazi", .lunch, 50, nil),
        
        // Dinner options
        ("Mukimo", .dinner, 55, Recipe.mukimoRecipe),
        ("Matoke Stew", .dinner, 45, nil),
        ("Chapati na Beans", .dinner, 35, Recipe.chapatiRecipe),
        ("Chicken Curry", .dinner, 60, nil)
    ]
    
    // Get 3 meals for the day (breakfast, lunch, dinner)
    let categories: [Meal.MealCategory] = [.breakfast, .lunch, .dinner]
    
    return categories.map { category in
        let mealsForCategory = kenyanMeals.filter { $0.1 == category }
        let selectedMeal = mealsForCategory.randomElement() ?? kenyanMeals.first!
        
        return Meal(
            name: selectedMeal.0,
            category: category,
            cookingTime: selectedMeal.2,
            difficulty: .medium,
            imageURL: nil,
            isCompleted: dayOffset < 3, // First 3 days completed
            recipe: selectedMeal.3
        )
    }
}

// MARK: - WeekPlan Extensions for Mock Data
extension WeekPlan {
    static var sampleWeekPlan: WeekPlan {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        return WeekPlan(
            weekNumber: calendar.component(.weekOfYear, from: startOfWeek),
            startDate: startOfWeek,
            endDate: calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? startOfWeek,
            totalCost: 0,
            mealsCompleted: 0,
            totalMeals: 5,
            planName: "Sample Plan",
            featuredImageName: "sample",
            isActive: true,
            meals: [
                // Monday Breakfast - Chapati na Beans
                Meal(
                    name: "Chapati na Beans",
                    category: .breakfast,
                    cookingTime: 35,
                    difficulty: .medium,
                    imageURL: nil,
                    isCompleted: false,
                    recipe: Recipe(
                        id: UUID(),
                        title: "Chapati na Beans",
                        cookTime: "35 mins",
                        servings: 4,
                        imageName: "🫓",
                        ingredients: [
                            Ingredient(name: "All-purpose flour", quantity: "2 cups", category: "Grains", emoji: "🌾"),
                            Ingredient(name: "Water", quantity: "3/4 cup", category: "Liquids", emoji: "💧"),
                            Ingredient(name: "Salt", quantity: "1/2 tsp", category: "Spices", emoji: "🧂"),
                            Ingredient(name: "Cooking oil", quantity: "2 tbsp", category: "Oils", emoji: "🫒"),
                            Ingredient(name: "Red beans", quantity: "2 cups", category: "Legumes", emoji: "🫘"),
                            Ingredient(name: "Onion", quantity: "1 medium", category: "Vegetables", emoji: "🧅"),
                            Ingredient(name: "Tomatoes", quantity: "2 medium", category: "Vegetables", emoji: "🍅"),
                            Ingredient(name: "Garlic", quantity: "2 cloves", category: "Spices", emoji: "🧄")
                        ],
                        steps: ["Make chapati dough", "Prepare beans", "Cook chapati", "Serve together"],
                        substitutions: ["Use whole wheat flour"],
                        tags: ["Budget", "High-Protein"]
                    )
                ),
                // Monday Lunch - Nyama Choma
                Meal(
                    name: "Nyama Choma",
                    category: .lunch,
                    cookingTime: 60,
                    difficulty: .medium,
                    imageURL: nil,
                    isCompleted: false,
                    recipe: Recipe(
                        id: UUID(),
                        title: "Nyama Choma",
                        cookTime: "60 mins",
                        servings: 4,
                        imageName: "🥩",
                        ingredients: [
                            Ingredient(name: "Beef chunks", quantity: "1 kg", category: "Meat", emoji: "🥩"),
                            Ingredient(name: "Salt", quantity: "To taste", category: "Spices", emoji: "🧂"),
                            Ingredient(name: "Black pepper", quantity: "1 tsp", category: "Spices", emoji: "🌶️"),
                            Ingredient(name: "Garlic", quantity: "3 cloves", category: "Spices", emoji: "🧄"),
                            Ingredient(name: "Ginger", quantity: "1 inch piece", category: "Spices", emoji: "🫚"),
                            Ingredient(name: "Cooking oil", quantity: "2 tbsp", category: "Oils", emoji: "🫒")
                        ],
                        steps: ["Season meat", "Marinate", "Grill", "Serve hot"],
                        substitutions: ["Can use goat meat"],
                        tags: ["Traditional", "High-Protein"]
                    )
                ),
                // Tuesday Breakfast - Mukimo
                Meal(
                    name: "Mukimo",
                    category: .breakfast,
                    cookingTime: 55,
                    difficulty: .medium,
                    imageURL: nil,
                    isCompleted: false,
                    recipe: Recipe(
                        id: UUID(),
                        title: "Mukimo",
                        cookTime: "55 mins",
                        servings: 4,
                        imageName: "🥔",
                        ingredients: [
                            Ingredient(name: "Potatoes", quantity: "4 large", category: "Vegetables", emoji: "🥔"),
                            Ingredient(name: "Green maize", quantity: "2 cups", category: "Vegetables", emoji: "🌽"),
                            Ingredient(name: "Spinach", quantity: "2 cups", category: "Vegetables", emoji: "🥬"),
                            Ingredient(name: "Green peas", quantity: "1 cup", category: "Vegetables", emoji: "🟢"),
                            Ingredient(name: "Onion", quantity: "1 large", category: "Vegetables", emoji: "🧅"),
                            Ingredient(name: "Cooking oil", quantity: "3 tbsp", category: "Oils", emoji: "🫒"),
                            Ingredient(name: "Salt", quantity: "To taste", category: "Spices", emoji: "🧂")
                        ],
                        steps: ["Boil vegetables", "Mash together", "Fry onions", "Mix and serve"],
                        substitutions: ["Use sweet potatoes", "Kale instead of spinach"],
                        tags: ["Traditional", "Healthy", "Budget"]
                    )
                ),
                // Tuesday Dinner - Sukuma Wiki
                Meal(
                    name: "Sukuma Wiki with Ugali",
                    category: .dinner,
                    cookingTime: 35,
                    difficulty: .medium,
                    imageURL: nil,
                    isCompleted: false,
                    recipe: Recipe(
                        id: UUID(),
                        title: "Sukuma Wiki with Ugali",
                        cookTime: "35 mins",
                        servings: 3,
                        imageName: "🥬",
                        ingredients: [
                            Ingredient(name: "Sukuma wiki", quantity: "1 bunch", category: "Vegetables", emoji: "🥬"),
                            Ingredient(name: "Onion", quantity: "1 medium", category: "Vegetables", emoji: "🧅"),
                            Ingredient(name: "Tomatoes", quantity: "2 medium", category: "Vegetables", emoji: "🍅"),
                            Ingredient(name: "Garlic", quantity: "3 cloves", category: "Spices", emoji: "🧄"),
                            Ingredient(name: "Cooking oil", quantity: "2 tbsp", category: "Oils", emoji: "🫒"),
                            Ingredient(name: "Maize flour", quantity: "2 cups", category: "Grains", emoji: "🌽"),
                            Ingredient(name: "Water", quantity: "3 cups", category: "Liquids", emoji: "💧"),
                            Ingredient(name: "Salt", quantity: "1/2 tsp", category: "Spices", emoji: "🧂")
                        ],
                        steps: ["Prepare sukuma wiki", "Make ugali", "Serve together"],
                        substitutions: ["Use spinach instead"],
                        tags: ["Quick", "Healthy", "Budget"]
                    )
                ),
                // Wednesday Lunch - Pilau
                Meal(
                    name: "Pilau",
                    category: .lunch,
                    cookingTime: 75,
                    difficulty: .medium,
                    imageURL: nil,
                    isCompleted: false,
                    recipe: Recipe(
                        id: UUID(),
                        title: "Pilau",
                        cookTime: "75 mins",
                        servings: 6,
                        imageName: "🍚",
                        ingredients: [
                            Ingredient(name: "Basmati rice", quantity: "2 cups", category: "Grains", emoji: "🍚"),
                            Ingredient(name: "Beef", quantity: "500g", category: "Meat", emoji: "🥩"),
                            Ingredient(name: "Onions", quantity: "2 large", category: "Vegetables", emoji: "🧅"),
                            Ingredient(name: "Tomatoes", quantity: "2 medium", category: "Vegetables", emoji: "🍅"),
                            Ingredient(name: "Pilau masala", quantity: "2 tbsp", category: "Spices", emoji: "🌶️"),
                            Ingredient(name: "Garlic", quantity: "4 cloves", category: "Spices", emoji: "🧄"),
                            Ingredient(name: "Ginger", quantity: "1 inch piece", category: "Spices", emoji: "🫚"),
                            Ingredient(name: "Beef stock", quantity: "4 cups", category: "Liquids", emoji: "🍲"),
                            Ingredient(name: "Cooking oil", quantity: "3 tbsp", category: "Oils", emoji: "🫒")
                        ],
                        steps: ["Brown meat", "Cook aromatics", "Add rice and stock", "Simmer"],
                        substitutions: ["Use chicken instead of beef"],
                        tags: ["Traditional", "High-Protein"]
                    )
                )
            ]
        )
    }
}

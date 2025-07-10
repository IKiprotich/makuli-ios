//
//  Plan.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready models for meal plans stored in Supabase database.
//

import Foundation

// MARK: - Core Plan Models

/// Represents a meal plan stored in Supabase 'plans' table
struct Plan: Codable, Identifiable {
    let id: String
    let userId: String
    let title: String
    let weekStart: Date
    let weekEnd: Date
    let totalCost: Double?
    let isCompleted: Bool
    let createdAt: Date
    let updatedAt: Date
    
    // Plan metadata from production schema
    let templateId: String?
    let generationMethod: String // "template", "ai", "manual"
    let isFavorite: Bool
    let completionPercentage: Double
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case weekStart = "week_start"
        case weekEnd = "week_end"
        case totalCost = "total_cost"
        case isCompleted = "is_completed"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case templateId = "template_id"
        case generationMethod = "generation_method"
        case isFavorite = "is_favorite"
        case completionPercentage = "completion_percentage"
    }
    
    // MARK: - Custom Decoding
    
    init(
        id: String,
        userId: String,
        title: String,
        weekStart: Date,
        weekEnd: Date,
        totalCost: Double? = nil,
        isCompleted: Bool = false,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        templateId: String? = nil,
        generationMethod: String = "manual",
        isFavorite: Bool = false,
        completionPercentage: Double = 0.0
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.weekStart = weekStart
        self.weekEnd = weekEnd
        self.totalCost = totalCost
        self.isCompleted = isCompleted
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.templateId = templateId
        self.generationMethod = generationMethod
        self.isFavorite = isFavorite
        self.completionPercentage = completionPercentage
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode simple fields
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        totalCost = try container.decodeIfPresent(Double.self, forKey: .totalCost)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        templateId = try container.decodeIfPresent(String.self, forKey: .templateId)
        generationMethod = try container.decode(String.self, forKey: .generationMethod)
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
        completionPercentage = try container.decodeIfPresent(Double.self, forKey: .completionPercentage) ?? 0.0
        
        // Custom decoding for dates - handle both string and timestamp formats
        let dateFormatter = DateFormatter()
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withFullDate]
        
        // Decode weekStart (DATE field from PostgreSQL comes as string)
        if let weekStartString = try? container.decode(String.self, forKey: .weekStart) {
            if let date = isoFormatter.date(from: weekStartString) {
                weekStart = date
            } else {
                // Fallback to other date formats if needed
                dateFormatter.dateFormat = "yyyy-MM-dd"
                weekStart = dateFormatter.date(from: weekStartString) ?? Date()
            }
        } else {
            // Handle case where it might be a timestamp
            weekStart = try container.decodeIfPresent(Date.self, forKey: .weekStart) ?? Date()
        }
        
        // Decode weekEnd (DATE field from PostgreSQL comes as string)
        if let weekEndString = try? container.decode(String.self, forKey: .weekEnd) {
            if let date = isoFormatter.date(from: weekEndString) {
                weekEnd = date
            } else {
                // Fallback to other date formats if needed
                dateFormatter.dateFormat = "yyyy-MM-dd"
                weekEnd = dateFormatter.date(from: weekEndString) ?? Date()
            }
        } else {
            // Handle case where it might be a timestamp
            weekEnd = try container.decodeIfPresent(Date.self, forKey: .weekEnd) ?? Date()
        }
        
        // Decode createdAt (TIMESTAMP field comes as ISO8601 string)
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            let timestampFormatter = ISO8601DateFormatter()
            timestampFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            createdAt = timestampFormatter.date(from: createdAtString) ?? 
                        ISO8601DateFormatter().date(from: createdAtString) ?? Date()
        } else {
            createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? Date()
        }
        
        // Decode updatedAt (TIMESTAMP field comes as ISO8601 string)
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            let timestampFormatter = ISO8601DateFormatter()
            timestampFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            updatedAt = timestampFormatter.date(from: updatedAtString) ?? 
                        ISO8601DateFormatter().date(from: updatedAtString) ?? Date()
        } else {
            updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt) ?? Date()
        }
    }
}

/// Represents plan recipes stored in Supabase 'plan_recipes' table
struct PlanRecipe: Codable, Identifiable {
    let id: String
    let planId: String
    let recipeId: String?
    let dayOfWeek: Int // 0-6 (Sunday-Saturday)
    let mealType: String // "breakfast", "lunch", "dinner", "snack"
    let position: Int
    let day: String // "Monday", "Tuesday", etc.
    let isCompleted: Bool
    let completedAt: Date?
    
    // Recipe override data for customized meals
    let customMealName: String?
    let customIngredients: [String]?
    let customInstructions: [String]?
    let customCookTime: Int?
    let notes: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case planId = "plan_id"
        case recipeId = "recipe_id"
        case dayOfWeek = "day_of_week"
        case mealType = "meal_type"
        case position
        case day
        case isCompleted = "is_completed"
        case completedAt = "completed_at"
        case customMealName = "custom_meal_name"
        case customIngredients = "custom_ingredients"
        case customInstructions = "custom_instructions"
        case customCookTime = "custom_cook_time"
        case notes
    }
}

// MARK: - Request Models

/// Request model for creating a new plan
struct CreatePlanRequest: Codable {
    let userId: String
    let title: String
    let weekStart: String // ISO date string
    let weekEnd: String // ISO date string
    let totalCost: Double?
    let templateId: String?
    let generationMethod: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case title
        case weekStart = "week_start"
        case weekEnd = "week_end"
        case totalCost = "total_cost"
        case templateId = "template_id"
        case generationMethod = "generation_method"
    }
}

/// Request model for adding recipes to a plan
struct CreatePlanRecipeRequest: Codable {
    let planId: String
    let recipeId: String?
    let dayOfWeek: Int
    let mealType: String
    let position: Int
    let day: String
    let customMealName: String?
    let customIngredients: [String]?
    let customInstructions: [String]?
    let customCookTime: Int?
    
    enum CodingKeys: String, CodingKey {
        case planId = "plan_id"
        case recipeId = "recipe_id"
        case dayOfWeek = "day_of_week"
        case mealType = "meal_type"
        case position
        case day
        case customMealName = "custom_meal_name"
        case customIngredients = "custom_ingredients"
        case customInstructions = "custom_instructions"
        case customCookTime = "custom_cook_time"
    }
}

// MARK: - UI Helper Models

/// Aggregated plan data for UI display
struct PlanWithRecipes: Identifiable {
    let id: String
    let plan: Plan
    let recipes: [PlanRecipe]
    
    /// Groups recipes by day for easier UI consumption
    var recipesByDay: [String: [PlanRecipe]] {
        Dictionary(grouping: recipes) { $0.day }
    }
    
    /// Gets recipes for a specific day and meal type
    func recipes(for day: String, type: String) -> [PlanRecipe] {
        return recipes.filter { $0.day == day && $0.mealType == type }
    }
    
    /// Calculate completion percentage
    var calculatedCompletionPercentage: Double {
        guard !recipes.isEmpty else { return 0.0 }
        let completedCount = recipes.filter { $0.isCompleted }.count
        return Double(completedCount) / Double(recipes.count) * 100.0
    }
    
    /// Total estimated cost based on recipes
    var estimatedTotalCost: Double {
        return plan.totalCost ?? 0.0
    }
    
    /// Check if plan is from current week
    var isCurrentWeek: Bool {
        let calendar = Calendar.current
        let now = Date()
        return calendar.isDate(plan.weekStart, equalTo: now, toGranularity: .weekOfYear)
    }
    
    /// Days remaining in the plan
    var daysRemaining: Int {
        let calendar = Calendar.current
        let today = Date()
        
        if today > plan.weekEnd {
            return 0
        } else if today < plan.weekStart {
            return calendar.dateComponents([.day], from: today, to: plan.weekEnd).day ?? 7
        } else {
            return calendar.dateComponents([.day], from: today, to: plan.weekEnd).day ?? 0
        }
    }
}

/// Day meal structure for UI
struct DayMeals: Identifiable {
    let id = UUID()
    let day: String
    let dayOfWeek: Int
    let breakfast: [PlanRecipe]
    let lunch: [PlanRecipe]
    let dinner: [PlanRecipe]
    let snacks: [PlanRecipe]
    
    var allMeals: [PlanRecipe] {
        return breakfast + lunch + dinner + snacks
    }
    
    var completedMealsCount: Int {
        return allMeals.filter { $0.isCompleted }.count
    }
    
    var totalMealsCount: Int {
        return allMeals.count
    }
    
    var completionPercentage: Double {
        guard totalMealsCount > 0 else { return 0.0 }
        return Double(completedMealsCount) / Double(totalMealsCount) * 100.0
    }
}

// MARK: - Enums

enum MealType: String, CaseIterable {
    case breakfast = "breakfast"
    case lunch = "lunch"
    case dinner = "dinner"
    case snack = "snack"
    
    var displayName: String {
        switch self {
        case .breakfast: return "Breakfast"
        case .lunch: return "Lunch"
        case .dinner: return "Dinner"
        case .snack: return "Snack"
        }
    }
    
    var icon: String {
        switch self {
        case .breakfast: return "☀️"
        case .lunch: return "🌤️"
        case .dinner: return "🌙"
        case .snack: return "🍎"
        }
    }
}

enum GenerationMethod: String, CaseIterable {
    case template = "template"
    case ai = "ai"
    case manual = "manual"
    
    var displayName: String {
        switch self {
        case .template: return "From Template"
        case .ai: return "AI Generated"
        case .manual: return "Manual Creation"
        }
    }
}

// MARK: - Extensions

extension Plan {
    /// Legacy property for UI compatibility
    var planName: String {
        return title
    }
    
    /// Number of completed meals (calculated from associated recipes)
    var completedMealsCount: Int {
        // This will be calculated when PlanWithRecipes is available
        return Int(completionPercentage / 100.0 * 21) // Assuming 21 total meals per week
    }
    
    /// Total number of meals in the plan
    var totalMealsCount: Int {
        return 21 // 3 meals × 7 days
    }
    
    /// Progress as a decimal (0.0 to 1.0)
    var progress: Double {
        return completionPercentage / 100.0
    }
    
    /// Check if the plan is active (current week)
    var isActive: Bool {
        let now = Date()
        return now >= weekStart && now <= weekEnd
    }
    
    /// Format the week range for display
    var weekRangeDescription: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        
        let startString = formatter.string(from: weekStart)
        let endString = formatter.string(from: weekEnd)
        
        return "\(startString) - \(endString)"
    }
    
    /// Check if plan is completed
    var isFullyCompleted: Bool {
        return completionPercentage >= 100.0
    }
}

extension PlanRecipe {
    /// Get the display name for the meal (custom or recipe name)
    var displayName: String {
        return customMealName ?? "Meal"
    }
    
    /// Get cooking time (custom or default)
    var cookingTime: Int {
        return customCookTime ?? 30
    }
    
    /// Get ingredients list (custom or default)
    var ingredients: [String] {
        return customIngredients ?? []
    }
    
    /// Get instructions list (custom or default)
    var instructions: [String] {
        return customInstructions ?? []
    }
}

// MARK: - Legacy Type Aliases for UI Compatibility
typealias WeekPlan = PlanWithRecipes

// MARK: - WeekPlan Extensions for UI Compatibility
extension PlanWithRecipes {
    /// Title for week carousel display
    var weekTitle: String {
        return plan.title
    }
    
    /// Formatted total cost for display
    var formattedTotalCost: String {
        return "$\(String(format: "%.0f", plan.totalCost ?? 0.0))"
    }
    

    
    /// Legacy property for UI compatibility
    var planName: String {
        return plan.title
    }
    
    /// Week number for display
    var weekNumber: String {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: plan.weekStart)
        return "Week \(weekOfYear)"
    }
    
    /// Mock data for previews and testing
    static var mockData: [PlanWithRecipes] {
        return [Plan.mockWeeklyPlan()]
    }
}

// MARK: - Mock Data for UI Development
extension Plan {
    static func mockWeeklyPlan() -> PlanWithRecipes {
        let calendar = Calendar.current
        let now = Date()
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: now)?.start ?? now
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? now
        
        let plan = Plan(
            id: "mock-plan-1",
            userId: "mock-user",
            title: "Mediterranean Week",
            weekStart: startOfWeek,
            weekEnd: endOfWeek,
            totalCost: 85.50,
            isCompleted: false,
            createdAt: now,
            updatedAt: now,
            templateId: nil,
            generationMethod: "manual",
            isFavorite: false,
            completionPercentage: 35.0
        )
        
        let mockRecipes: [PlanRecipe] = [
            // Monday
            PlanRecipe(
                id: "recipe-1",
                planId: plan.id,
                recipeId: nil,
                dayOfWeek: 1,
                mealType: "breakfast",
                position: 0,
                day: "Monday",
                isCompleted: true,
                completedAt: nil,
                customMealName: "Avocado Toast with Eggs",
                customIngredients: ["bread", "avocado", "eggs", "salt"],
                customInstructions: ["Toast bread", "Mash avocado", "Fry eggs", "Assemble"],
                customCookTime: 10,
                notes: nil
            ),
            PlanRecipe(
                id: "recipe-2",
                planId: plan.id,
                recipeId: nil,
                dayOfWeek: 1,
                mealType: "lunch",
                position: 0,
                day: "Monday",
                isCompleted: true,
                completedAt: nil,
                customMealName: "Mediterranean Quinoa Bowl",
                customIngredients: ["quinoa", "tomatoes", "cucumbers", "olives", "feta"],
                customInstructions: ["Cook quinoa", "Chop vegetables", "Mix together", "Top with feta"],
                customCookTime: 25,
                notes: nil
            ),
            PlanRecipe(
                id: "recipe-3",
                planId: plan.id,
                recipeId: nil,
                dayOfWeek: 1,
                mealType: "dinner",
                position: 0,
                day: "Monday",
                isCompleted: false,
                completedAt: nil,
                customMealName: "Grilled Salmon with Asparagus",
                customIngredients: ["salmon", "asparagus", "olive oil", "lemon"],
                customInstructions: ["Season salmon", "Grill salmon", "Roast asparagus", "Serve with lemon"],
                customCookTime: 20,
                notes: nil
            )
        ]
        
        return PlanWithRecipes(id: plan.id, plan: plan, recipes: mockRecipes)
    }
} 
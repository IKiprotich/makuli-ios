//
//  Plan.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready models for meal plans stored in Supabase database.
//
//  This file contains the core data models for meal planning functionality in the
//  Makuli app. It includes the Plan struct for representing user meal plans and
//  the PlanRecipe struct for individual meals within those plans.
//
//  Key Features:
//  - Custom Codable implementation for Supabase timestamp handling
//  - Support for different plan generation methods (template, AI, manual)
//  - Integration with user profiles and recipe database
//  - Progress tracking and completion status
//  - Week-based planning with start/end dates
//

import Foundation

// MARK: - Core Plan Models

/// Represents a meal plan stored in the Supabase 'plans' table.
/// 
/// A Plan represents a user's meal plan for a specific time period (typically
/// a week). It contains metadata about the plan, including creation method,
/// completion status, and cost estimates. Individual meals within the plan
/// are stored separately in the 'plan_recipes' table and linked via plan_id.
/// 
/// The model includes custom decoding logic to handle Supabase's ISO8601
/// timestamp format and optional fields that may be null in the database.
/// 
/// Example usage:
/// ```swift
/// let plan = Plan(
///     id: "uuid",
///     userId: "user-uuid",
///     title: "Healthy Week Plan",
///     weekStart: Date(),
///     weekEnd: Calendar.current.date(byAdding: .day, value: 6, to: Date())!,
///     generationMethod: "template"
/// )
/// ```
struct Plan: Codable, Identifiable {
    // MARK: - Core Properties
    
    /// Unique identifier for the plan (UUID from Supabase)
    let id: String
    
    /// ID of the user who owns this plan
    let userId: String
    
    /// Human-readable title for the plan
    let title: String
    
    /// Start date of the plan period (typically Monday)
    let weekStart: Date
    
    /// End date of the plan period (typically Sunday)
    let weekEnd: Date
    
    /// Estimated total cost for all meals in the plan
    let totalCost: Double?
    
    /// Whether the plan has been completed
    let isCompleted: Bool
    
    /// When the plan was created
    let createdAt: Date
    
    /// When the plan was last updated
    let updatedAt: Date
    
    // MARK: - Plan Metadata
    
    /// ID of the template used to create this plan (if applicable)
    let templateId: String?
    
    /// Method used to generate the plan: "template", "ai", or "manual"
    let generationMethod: String
    
    /// Whether the user has marked this plan as a favorite
    let isFavorite: Bool
    
    /// Percentage of meals completed (0.0 to 100.0)
    let completionPercentage: Double
    
    // MARK: - Coding Keys
    
    /// Maps Swift property names to Supabase column names
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
    
    // MARK: - Initializers
    
    /// Creates a new Plan instance with all required and optional properties.
    /// 
    /// This initializer is used for creating Plan objects programmatically,
    /// such as when generating plans from templates or AI.
    /// 
    /// - Parameters:
    ///   - id: Unique identifier (usually UUID string)
    ///   - userId: ID of the user who owns this plan
    ///   - title: Human-readable plan title
    ///   - weekStart: Start date of the plan period
    ///   - weekEnd: End date of the plan period
    ///   - totalCost: Estimated total cost (optional)
    ///   - isCompleted: Whether plan is completed
    ///   - createdAt: Creation timestamp
    ///   - updatedAt: Last update timestamp
    ///   - templateId: ID of template used (optional)
    ///   - generationMethod: How plan was created
    ///   - isFavorite: Whether user favorited this plan
    ///   - completionPercentage: Percentage of meals completed
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
    
    // MARK: - Custom Decoding
    
    /// Custom decoder that handles Supabase's specific data format.
    /// 
    /// This decoder is necessary because Supabase returns timestamps as
    /// ISO8601 strings rather than Date objects. The decoder includes
    /// fallback logic to handle various timestamp formats and ensure
    /// the app doesn't crash on malformed data.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode simple fields that don't require special handling
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        totalCost = try container.decodeIfPresent(Double.self, forKey: .totalCost)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        templateId = try container.decodeIfPresent(String.self, forKey: .templateId)
        generationMethod = try container.decode(String.self, forKey: .generationMethod)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        completionPercentage = try container.decode(Double.self, forKey: .completionPercentage)
        
        // Custom decoding for timestamps (Supabase returns ISO8601 strings)
        do {
            weekStart = try container.decode(Date.self, forKey: .weekStart)
        } catch {
            if let weekStartString = try? container.decode(String.self, forKey: .weekStart) {
                let timestampFormatter = ISO8601DateFormatter()
                timestampFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                weekStart = timestampFormatter.date(from: weekStartString) ??
                            ISO8601DateFormatter().date(from: weekStartString) ?? Date()
            } else {
                weekStart = Date()
            }
        }
        
        do {
            weekEnd = try container.decode(Date.self, forKey: .weekEnd)
        } catch {
            if let weekEndString = try? container.decode(String.self, forKey: .weekEnd) {
                let timestampFormatter = ISO8601DateFormatter()
                timestampFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                weekEnd = timestampFormatter.date(from: weekEndString) ??
                          ISO8601DateFormatter().date(from: weekEndString) ?? Date()
            } else {
                weekEnd = Date()
            }
        }
        
        do {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        } catch {
            if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
                let timestampFormatter = ISO8601DateFormatter()
                timestampFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                createdAt = timestampFormatter.date(from: createdAtString) ??
                            ISO8601DateFormatter().date(from: createdAtString) ?? Date()
            } else {
                createdAt = Date()
            }
        }
        
        do {
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        } catch {
            if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
                let timestampFormatter = ISO8601DateFormatter()
                timestampFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                updatedAt = timestampFormatter.date(from: updatedAtString) ??
                            ISO8601DateFormatter().date(from: updatedAtString) ?? Date()
            } else {
                updatedAt = Date()
            }
        }
    }
}

/// Represents an individual meal within a plan, stored in the Supabase 'plan_recipes' table.
/// 
/// A PlanRecipe links a specific recipe to a plan for a particular day and meal type.
/// It can either reference an existing recipe from the 'recipes' table or contain
/// custom meal data (for meals created without a specific recipe).
/// 
/// The model supports both recipe-based meals (with recipe_id) and custom meals
/// (with custom_meal_name, custom_ingredients, etc.) for maximum flexibility.
/// 
/// Example usage:
/// ```swift
/// let planRecipe = PlanRecipe(
///     id: "uuid",
///     planId: "plan-uuid",
///     recipeId: "recipe-uuid",
///     dayOfWeek: 0, // Monday
///     mealType: "breakfast",
///     day: "Monday"
/// )
/// ```
struct PlanRecipe: Codable, Identifiable {
    // MARK: - Core Properties
    
    /// Unique identifier for this plan recipe (UUID from Supabase)
    let id: String
    
    /// ID of the plan this meal belongs to
    let planId: String
    
    /// ID of the recipe this meal is based on (optional for custom meals)
    let recipeId: String?
    
    /// Day of the week (0=Sunday, 1=Monday, ..., 6=Saturday)
    let dayOfWeek: Int
    
    /// Type of meal: "breakfast", "lunch", "dinner", or "snack"
    let mealType: String
    
    /// Position/order of this meal within the day
    let position: Int
    
    /// Human-readable day name (e.g., "Monday", "Tuesday")
    let day: String
    
    /// Whether this meal has been completed
    let isCompleted: Bool
    
    /// When this meal was completed (if applicable)
    let completedAt: Date?
    
    // MARK: - Custom Meal Data
    
    /// Custom meal name (used when recipe_id is nil)
    let customMealName: String?
    
    /// Custom ingredients list (used when recipe_id is nil)
    let customIngredients: [String]?
    
    /// Custom cooking instructions (used when recipe_id is nil)
    let customInstructions: [String]?
    
    /// Custom cooking time in minutes (used when recipe_id is nil)
    let customCookTime: Int?
    
    /// Additional notes for this meal
    let notes: String?
    
    // MARK: - Coding Keys
    
    /// Maps Swift property names to Supabase column names
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

/// Request model for creating a new plan in the database.
/// 
/// This struct is used when creating new plans via the API or when
/// generating plans from templates or AI. It includes all the fields
/// needed to create a plan, with proper coding keys for Supabase mapping.
struct CreatePlanRequest: Codable {
    let userId: String
    let title: String
    let weekStart: String // ISO8601 date string
    let weekEnd: String // ISO8601 date string
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

/// Request model for creating a new plan recipe in the database.
/// 
/// This struct is used when adding meals to plans, either by linking
/// existing recipes or creating custom meals.
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
    let notes: String?
    
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
        case notes
    }
}

// MARK: - Helper Models

/// Represents a plan with its associated recipes/meals.
/// 
/// This is a convenience model used in ViewModels to combine a Plan
/// with its PlanRecipe objects for easier UI rendering and data management.
struct PlanWithRecipes: Identifiable {
    let id: String
    let plan: Plan
    let recipes: [PlanRecipe]
    
    /// Whether this plan covers the current week
    var isCurrentWeek: Bool {
        let now = Date()
        return plan.weekStart <= now && plan.weekEnd >= now
    }
    
    /// Number of meals in this plan
    var mealCount: Int {
        return recipes.count
    }
    
    /// Number of completed meals
    var completedMealCount: Int {
        return recipes.filter { $0.isCompleted }.count
    }
    
    /// Completion percentage (0.0 to 100.0)
    var completionPercentage: Double {
        guard mealCount > 0 else { return 0.0 }
        return Double(completedMealCount) / Double(mealCount) * 100.0
    }
}

// MARK: - Extensions

extension Plan {
    /// Returns a formatted date range string for display.
    var dateRangeDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
    
    /// Returns the generation method as a human-readable string.
    var generationMethodDisplay: String {
        switch generationMethod.lowercased() {
        case "template": return "Template"
        case "ai": return "AI Generated"
        case "manual": return "Manual"
        default: return generationMethod.capitalized
        }
    }
    
    /// Returns the total cost as a formatted string.
    var totalCostDisplay: String {
        guard let cost = totalCost else { return "N/A" }
        return String(format: "$%.2f", cost)
    }
}

extension PlanRecipe {
    /// Returns the meal type as a human-readable string.
    var mealTypeDisplay: String {
        return mealType.capitalized
    }
    
    /// Returns the day of week as a human-readable string.
    var dayOfWeekDisplay: String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[dayOfWeek]
    }
    
    /// Returns the meal name (either custom name or recipe title).
    var mealName: String {
        return customMealName ?? "Meal"
    }
    
    /// Returns the cooking time (either custom time or recipe time).
    var cookingTime: Int? {
        return customCookTime
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
//    static var mockData: [PlanWithRecipes] {
//        return [Plan.mockWeeklyPlan()]
//    }
}

// MARK: - Mock Data (Removed for Supabase integration)
// extension Plan { static func mockWeeklyPlan() -> PlanWithRecipes { ... } }

// Deprecated: Use Supabase fetching instead 

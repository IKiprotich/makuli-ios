//
//  Plan.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import Foundation

// MARK: - Core Plan Models


struct Plan: Codable, Identifiable {
    // MARK: - Core Properties
    
    let id: String
    
    let userId: String
    
    let title: String
    
    let weekStart: Date
    
    let weekEnd: Date
    
    let totalCost: Double?
    
    let isCompleted: Bool
    
    let createdAt: Date
    
    let updatedAt: Date
    
    // MARK: - Plan Metadata
    
    let templateId: String?
    
    let generationMethod: String
    
    let isFavorite: Bool
    
    let completionPercentage: Double
    
    // MARK: - Coding Keys
    
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
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        totalCost = try container.decodeIfPresent(Double.self, forKey: .totalCost)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        templateId = try container.decodeIfPresent(String.self, forKey: .templateId)
        generationMethod = try container.decode(String.self, forKey: .generationMethod)
        isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        completionPercentage = try container.decode(Double.self, forKey: .completionPercentage)
        
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
    
    // MARK: - Computed Properties
    
    var totalMealsCount: Int {
        return 21
    }
    
    var completedMealsCount: Int {
        return Int(completionPercentage / 100.0 * Double(totalMealsCount))
    }
    
    var progress: Double {
        return completionPercentage / 100.0
    }
}

struct PlanRecipe: Codable, Identifiable {
    // MARK: - Core Properties
    
    let id: String
    
    let planId: String
    
    let recipeId: String?
    
    let dayOfWeek: Int
    
    let mealType: String
    
    let position: Int
    
    let day: String
    
    let isCompleted: Bool
    
    let completedAt: Date?
    
    // MARK: - Custom Meal Data
    
    let customMealName: String?
    
    let customIngredients: [String]?
    
    let customInstructions: [String]?
    
    let customCookTime: Int?
    
    let notes: String?

    let imageUrl: String?

    // MARK: - Coding Keys

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
        case imageUrl = "custom_image_url"
    }

    // MARK: - Memberwise Init (used by mock data and manual construction)

    init(
        id: String,
        planId: String,
        recipeId: String? = nil,
        dayOfWeek: Int,
        mealType: String,
        position: Int = 0,
        day: String = "",
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        customMealName: String? = nil,
        customIngredients: [String]? = nil,
        customInstructions: [String]? = nil,
        customCookTime: Int? = nil,
        notes: String? = nil,
        imageUrl: String? = nil
    ) {
        self.id                 = id
        self.planId             = planId
        self.recipeId           = recipeId
        self.dayOfWeek          = dayOfWeek
        self.mealType           = mealType
        self.position           = position
        self.day                = day
        self.isCompleted        = isCompleted
        self.completedAt        = completedAt
        self.customMealName     = customMealName
        self.customIngredients  = customIngredients
        self.customInstructions = customInstructions
        self.customCookTime     = customCookTime
        self.notes              = notes
        self.imageUrl           = imageUrl
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id                 = try c.decode(String.self,    forKey: .id)
        planId             = try c.decode(String.self,    forKey: .planId)
        recipeId           = try c.decodeIfPresent(String.self,  forKey: .recipeId)
        dayOfWeek          = try c.decode(Int.self,       forKey: .dayOfWeek)
        mealType           = try c.decode(String.self,    forKey: .mealType)
        position           = (try? c.decode(Int.self,     forKey: .position)) ?? 0
        day                = (try? c.decode(String.self,  forKey: .day)) ?? ""
        isCompleted        = (try? c.decode(Bool.self,    forKey: .isCompleted)) ?? false
        completedAt        = try c.decodeIfPresent(Date.self,    forKey: .completedAt)
        customMealName     = try c.decodeIfPresent(String.self,  forKey: .customMealName)
        customIngredients  = try c.decodeIfPresent([String].self, forKey: .customIngredients)
        customInstructions = try c.decodeIfPresent([String].self, forKey: .customInstructions)
        customCookTime     = try c.decodeIfPresent(Int.self,     forKey: .customCookTime)
        notes              = try c.decodeIfPresent(String.self,  forKey: .notes)
        imageUrl           = try c.decodeIfPresent(String.self,  forKey: .imageUrl)
    }
}

// MARK: - Request Models

struct CreatePlanRequest: Codable {
    let userId: String
    let title: String
    let weekStart: String
    let weekEnd: String
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

struct PlanWithRecipes: Identifiable {
    let id: String
    let plan: Plan
    let recipes: [PlanRecipe]
    
    var isCurrentWeek: Bool {
        let now = Date()
        return plan.weekStart <= now && plan.weekEnd >= now
    }
    
    var mealCount: Int {
        return recipes.count
    }
    
    var completedMealCount: Int {
        return recipes.filter { $0.isCompleted }.count
    }
    
    var completionPercentage: Double {
        guard mealCount > 0 else { return 0.0 }
        return Double(completedMealCount) / Double(mealCount) * 100.0
    }
}

// MARK: - Extensions

extension Plan {
    var dateRangeDisplay: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return "\(formatter.string(from: weekStart)) - \(formatter.string(from: weekEnd))"
    }
    
    var generationMethodDisplay: String {
        switch generationMethod.lowercased() {
        case "template": return "Template"
        case "ai": return "AI Generated"
        case "manual": return "Manual"
        case "spoonacular": return "Spoonacular"
        default: return generationMethod.capitalized
        }
    }
    
    var totalCostDisplay: String {
        guard let cost = totalCost else { return "N/A" }
        return String(format: "$%.2f", cost)
    }
}

extension PlanRecipe {
    var mealTypeDisplay: String {
        return mealType.capitalized
    }
    
    var dayOfWeekDisplay: String {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return days[dayOfWeek]
    }
    
    var mealName: String {
        return customMealName ?? "Meal"
    }
    
    var cookingTime: Int? {
        return customCookTime
    }
}

// MARK: - Legacy Type Aliases for UI Compatibility
typealias WeekPlan = PlanWithRecipes

// MARK: - WeekPlan Extensions for UI Compatibility
extension PlanWithRecipes {
    var weekTitle: String {
        return plan.title
    }
    
    var formattedTotalCost: String {
        return "$\(String(format: "%.0f", plan.totalCost ?? 0.0))"
    }
    

    
    var planName: String {
        return plan.title
    }
    
    var weekNumber: String {
        let calendar = Calendar.current
        let weekOfYear = calendar.component(.weekOfYear, from: plan.weekStart)
        return "Week \(weekOfYear)"
    }
    
}

// MARK: - Mock Data (Removed for Supabase integration)


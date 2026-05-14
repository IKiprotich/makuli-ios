//
//  Recipe.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready recipe model for Supabase database.
//  
//  This file contains the core Recipe data model and related types used throughout
//  the Makuli app. The Recipe struct represents a complete recipe with all its
//  metadata, ingredients, steps, and nutritional information. It includes custom
//  decoding logic to handle Supabase's timestamp format and JSONB arrays.
//
//  Key Features:
//  - Custom Codable implementation for Supabase compatibility
//  - Computed properties for UI display and filtering
//  - Support for recipe ratings, difficulty levels, and cuisine types
//  - Image URL validation to prevent loading errors
//  - Integration with meal planning and grocery list features
//

import Foundation

// MARK: - Core Recipe Model

struct Recipe: Identifiable, Codable {
    // MARK: - Core Properties
    
    let id: String
    
    let title: String
    
    let cookTime: String?
    
    let prepTime: Int?
    
    let servings: Int?
    
    let calories: Int?
    
    let imageUrl: String?
    
    let ingredients: [String]
    
    let steps: [String]
    
    let substitutions: [String]?
    
    let tags: [String]
    
    let difficulty: String?
    
    let cuisineType: String?
    
    let costEstimate: Double?
    
    let createdAt: Date
    
    let updatedAt: Date
    
    let createdBy: String?
    
    let spoonacularId: String?
    
    let isPublic: Bool
    
    let rating: Double
    
    let ratingCount: Int
    
    // MARK: - Coding Keys
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case cookTime = "cook_time"
        case prepTime = "prep_time"
        case servings
        case calories
        case imageUrl = "image_url"
        case ingredients
        case steps
        case substitutions
        case tags
        case difficulty
        case cuisineType = "cuisine_type"
        case costEstimate = "cost_estimate"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case createdBy = "created_by"
        case spoonacularId = "spoonacular_id"
        case isPublic = "is_public"
        case rating
        case ratingCount = "rating_count"
    }
    
    // MARK: - Initializers
    
    init(
        id: String,
        title: String,
        cookTime: String? = nil,
        prepTime: Int? = nil,
        servings: Int? = nil,
        calories: Int? = nil,
        imageUrl: String? = nil,
        ingredients: [String],
        steps: [String],
        substitutions: [String]? = nil,
        tags: [String],
        difficulty: String? = nil,
        cuisineType: String? = nil,
        costEstimate: Double? = nil,
        createdAt: Date,
        updatedAt: Date,
        createdBy: String? = nil,
        spoonacularId: String? = nil,
        isPublic: Bool,
        rating: Double,
        ratingCount: Int
    ) {
        self.id = id
        self.title = title
        self.cookTime = cookTime
        self.prepTime = prepTime
        self.servings = servings
        self.calories = calories
        self.imageUrl = imageUrl
        self.ingredients = ingredients
        self.steps = steps
        self.substitutions = substitutions
        self.tags = tags
        self.difficulty = difficulty
        self.cuisineType = cuisineType
        self.costEstimate = costEstimate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.createdBy = createdBy
        self.spoonacularId = spoonacularId
        self.isPublic = isPublic
        self.rating = rating
        self.ratingCount = ratingCount
    }
    
    // MARK: - Custom Decoding
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        cookTime = try container.decodeIfPresent(String.self, forKey: .cookTime)
        prepTime = try container.decodeIfPresent(Int.self, forKey: .prepTime)
        servings = try container.decodeIfPresent(Int.self, forKey: .servings)
        calories = try container.decodeIfPresent(Int.self, forKey: .calories)
        imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        difficulty = try container.decodeIfPresent(String.self, forKey: .difficulty)
        cuisineType = try container.decodeIfPresent(String.self, forKey: .cuisineType)
        costEstimate = try container.decodeIfPresent(Double.self, forKey: .costEstimate)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        spoonacularId = try container.decodeIfPresent(String.self, forKey: .spoonacularId)
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        rating = try container.decodeIfPresent(Double.self, forKey: .rating) ?? 0.0
        ratingCount = try container.decodeIfPresent(Int.self, forKey: .ratingCount) ?? 0
        
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
        
        do {
            ingredients = try container.decode([String].self, forKey: .ingredients)
        } catch {
            if let ingredientsString = try? container.decodeIfPresent(String.self, forKey: .ingredients) {
                if ingredientsString.isEmpty {
                    ingredients = []
                } else {
                    ingredients = ingredientsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                }
            } else {
                ingredients = []
            }
        }
        
        do {
            steps = try container.decode([String].self, forKey: .steps)
        } catch {
            if let stepsString = try? container.decodeIfPresent(String.self, forKey: .steps) {
                if stepsString.isEmpty {
                    steps = []
                } else {
                    steps = stepsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                }
            } else {
                steps = []
            }
        }
        
        do {
            substitutions = try container.decodeIfPresent([String].self, forKey: .substitutions)
        } catch {
            if let substitutionsString = try? container.decodeIfPresent(String.self, forKey: .substitutions) {
                if substitutionsString.isEmpty {
                    substitutions = []
                } else {
                    substitutions = substitutionsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                }
            } else {
                substitutions = nil
            }
        }
        
        do {
            tags = try container.decode([String].self, forKey: .tags)
        } catch {
            if let tagsString = try? container.decodeIfPresent(String.self, forKey: .tags) {
                if tagsString.isEmpty {
                    tags = []
                } else {
                    tags = tagsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                }
            } else {
                tags = []
            }
        }
    }
    
    // MARK: - Computed Properties
    
    var validImageURL: URL? {
        guard let urlString = imageUrl,
              urlString != "meal_placeholder",
              !urlString.isEmpty,
              let url = URL(string: urlString),
              let scheme = url.scheme,
              !scheme.isEmpty else {
            return nil
        }
        return url
    }
    
    var cookTimeInMinutes: Int {
        guard let cookTime = cookTime else { return 30 }
        
        let components = cookTime.components(separatedBy: .whitespaces)
        if let firstNumber = components.first, let minutes = Int(firstNumber) {
            if cookTime.lowercased().contains("hour") {
                return minutes * 60
            }
            return minutes
        }
        return 30
    }
    
    var totalTimeInMinutes: Int {
        return (prepTime ?? 0) + cookTimeInMinutes
    }
    
    var formattedTime: String {
        if totalTimeInMinutes < 60 {
            return "\(totalTimeInMinutes) mins"
        } else {
            let hours = totalTimeInMinutes / 60
            let minutes = totalTimeInMinutes % 60
            if minutes == 0 {
                return "\(hours) hour\(hours > 1 ? "s" : "")"
            } else {
                return "\(hours)h \(minutes)m"
            }
        }
    }
    
    var isQuick: Bool {
        return totalTimeInMinutes <= 30
    }
    
    var isHealthy: Bool {
        let healthyTags = ["healthy", "low-fat", "high-protein", "vegetarian", "vegan"]
        let hasHealthyTags = tags.contains { tag in
            healthyTags.contains(tag.lowercased())
        }
        
        let isLowCalorie = (calories ?? 600) <= 500
        
        return hasHealthyTags || isLowCalorie
    }
    
    var difficultyDisplay: String {
        switch difficulty?.lowercased() {
        case "easy": return "Easy"
        case "medium": return "Medium"
        case "hard": return "Hard"
        default: return "Medium"
        }
    }
    
    var ratingDisplay: String {
        let fullStars = Int(rating)
        let hasHalfStar = rating - Double(fullStars) >= 0.5
        
        var stars = String(repeating: "★", count: fullStars)
        if hasHalfStar {
            stars += "☆"
        }
        
        return "\(stars) (\(ratingCount))"
    }
}

// MARK: - Request Models

struct CreateRecipeRequest: Codable {
    let title: String
    let cookTime: String?
    let prepTime: Int?
    let servings: Int?
    let calories: Int?
    let imageUrl: String?
    let ingredients: [String]
    let steps: [String]
    let substitutions: [String]?
    let tags: [String]
    let difficulty: String?
    let cuisineType: String?
    let costEstimate: Double?
    let isPublic: Bool
    let createdBy: String?
    
    enum CodingKeys: String, CodingKey {
        case title
        case cookTime = "cook_time"
        case prepTime = "prep_time"
        case servings
        case calories
        case imageUrl = "image_url"
        case ingredients
        case steps
        case substitutions
        case tags
        case difficulty
        case cuisineType = "cuisine_type"
        case costEstimate = "cost_estimate"
        case isPublic = "is_public"
        case createdBy = "created_by"
    }
    
    // MARK: - Initializers
    
    init(
        title: String,
        cookTime: String? = nil,
        prepTime: Int? = nil,
        servings: Int? = nil,
        calories: Int? = nil,
        imageUrl: String? = nil,
        ingredients: [String],
        steps: [String],
        substitutions: [String]? = nil,
        tags: [String],
        difficulty: String? = nil,
        cuisineType: String? = nil,
        costEstimate: Double? = nil,
        isPublic: Bool = true,
        createdBy: String? = nil
    ) {
        self.title = title
        self.cookTime = cookTime
        self.prepTime = prepTime
        self.servings = servings
        self.calories = calories
        self.imageUrl = imageUrl
        self.ingredients = ingredients
        self.steps = steps
        self.substitutions = substitutions
        self.tags = tags
        self.difficulty = difficulty
        self.cuisineType = cuisineType
        self.costEstimate = costEstimate
        self.isPublic = isPublic
        self.createdBy = createdBy
    }
}

// MARK: - Enums

enum RecipeDifficulty: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    var icon: String {
        switch self {
        case .easy: return "🟢"
        case .medium: return "🟡"
        case .hard: return "🔴"
        }
    }
}

enum CuisineType: String, CaseIterable {
    case american = "american"
    case italian = "italian"
    case mexican = "mexican"
    case asian = "asian"
    case mediterranean = "mediterranean"
    case indian = "indian"
    case french = "french"
    case thai = "thai"
    case chinese = "chinese"
    case japanese = "japanese"
    case middle_eastern = "middle_eastern"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .american: return "American"
        case .italian: return "Italian"
        case .mexican: return "Mexican"
        case .asian: return "Asian"
        case .mediterranean: return "Mediterranean"
        case .indian: return "Indian"
        case .french: return "French"
        case .thai: return "Thai"
        case .chinese: return "Chinese"
        case .japanese: return "Japanese"
        case .middle_eastern: return "Middle Eastern"
        case .other: return "Other"
        }
    }
    
    var flag: String {
        switch self {
        case .american: return "🇺🇸"
        case .italian: return "🇮🇹"
        case .mexican: return "🇲🇽"
        case .asian: return "🌏"
        case .mediterranean: return "🇬🇷"
        case .indian: return "🇮🇳"
        case .french: return "🇫🇷"
        case .thai: return "🇹🇭"
        case .chinese: return "🇨🇳"
        case .japanese: return "🇯🇵"
        case .middle_eastern: return "🏛️"
        case .other: return "🌍"
        }
    }
}

// MARK: - Recipe Categories

enum RecipeTag: String, CaseIterable {
    case healthy = "healthy"
    case quick = "quick"
    case vegetarian = "vegetarian"
    case vegan = "vegan"
    case glutenFree = "gluten-free"
    case lowCarb = "low-carb"
    case highProtein = "high-protein"
    case keto = "keto"
    case paleo = "paleo"
    case mediterranean = "mediterranean"
    case comfort = "comfort"
    case spicy = "spicy"
    case sweet = "sweet"
    case familyFriendly = "family-friendly"
    case budgetFriendly = "budget-friendly"
    case mealPrep = "meal-prep"
    
    var displayName: String {
        switch self {
        case .healthy: return "Healthy"
        case .quick: return "Quick"
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .glutenFree: return "Gluten Free"
        case .lowCarb: return "Low Carb"
        case .highProtein: return "High Protein"
        case .keto: return "Keto"
        case .paleo: return "Paleo"
        case .mediterranean: return "Mediterranean"
        case .comfort: return "Comfort Food"
        case .spicy: return "Spicy"
        case .sweet: return "Sweet"
        case .familyFriendly: return "Family Friendly"
        case .budgetFriendly: return "Budget Friendly"
        case .mealPrep: return "Meal Prep"
        }
    }
    
    var color: String {
        switch self {
        case .healthy: return "green"
        case .quick: return "orange"
        case .vegetarian, .vegan: return "green"
        case .glutenFree, .lowCarb, .keto, .paleo: return "blue"
        case .highProtein: return "red"
        case .mediterranean: return "blue"
        case .comfort: return "brown"
        case .spicy: return "red"
        case .sweet: return "pink"
        case .familyFriendly: return "purple"
        case .budgetFriendly: return "green"
        case .mealPrep: return "gray"
        }
    }
}

// MARK: - Extensions

extension Recipe {
    func matches(searchText: String) -> Bool {
        let lowercasedSearch = searchText.lowercased()
        
        return title.lowercased().contains(lowercasedSearch) ||
               ingredients.contains { $0.lowercased().contains(lowercasedSearch) } ||
               tags.contains { $0.lowercased().contains(lowercasedSearch) } ||
               (cuisineType?.lowercased().contains(lowercasedSearch) ?? false)
    }
    
    func hasTag(_ tag: RecipeTag) -> Bool {
        return tags.contains(tag.rawValue)
    }
    
    func suitableFor(diet: String) -> Bool {
        switch diet.lowercased() {
        case "vegetarian":
            return hasTag(.vegetarian) || hasTag(.vegan)
        case "vegan":
            return hasTag(.vegan)
        case "keto":
            return hasTag(.keto) || hasTag(.lowCarb)
        case "paleo":
            return hasTag(.paleo)
        case "mediterranean":
            return hasTag(.mediterranean)
        case "gluten_free":
            return hasTag(.glutenFree)
        default:
            return true
        }
    }
    
    var costDisplay: String {
        guard let cost = costEstimate else { return "N/A" }
        return String(format: "$%.2f", cost)
    }
    
    var caloriesDisplay: String {
        guard let calories = calories else { return "N/A" }
        return "\(calories) cal"
    }
    
    var servingsDisplay: String {
        guard let servings = servings else { return "N/A" }
        return "\(servings) serving\(servings > 1 ? "s" : "")"
    }
    
    // MARK: - Mock Data (Removed for Supabase integration)
}

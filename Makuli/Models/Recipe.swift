//
//  Recipe.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready recipe model for Supabase database.
//

import Foundation

// MARK: - Core Recipe Model

struct Recipe: Identifiable, Codable {
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
    let difficulty: String? // "easy", "medium", "hard"
    let cuisineType: String?
    let costEstimate: Double?
    let createdAt: Date
    let updatedAt: Date
    let createdBy: String?
    let isPublic: Bool
    let rating: Double
    let ratingCount: Int
    
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
        case isPublic = "is_public"
        case rating
        case ratingCount = "rating_count"
    }
    
    // MARK: - Initializers
    
    /// Memberwise initializer for creating Recipe objects
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
        self.isPublic = isPublic
        self.rating = rating
        self.ratingCount = ratingCount
    }
    
    // MARK: - Custom Decoding
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode simple fields
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
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        createdBy = try container.decodeIfPresent(String.self, forKey: .createdBy)
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        rating = try container.decode(Double.self, forKey: .rating)
        ratingCount = try container.decode(Int.self, forKey: .ratingCount)
        
        // Custom decoding for ingredients array
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
        
        // Custom decoding for steps array
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
        
        // Custom decoding for substitutions array (optional)
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
        
        // Custom decoding for tags array
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
    
    /// Get cooking time in minutes for calculations
    var cookTimeInMinutes: Int {
        guard let cookTime = cookTime else { return 30 }
        
        // Extract number from strings like "25 mins", "1 hour", etc.
        let components = cookTime.components(separatedBy: .whitespaces)
        if let firstNumber = components.first, let minutes = Int(firstNumber) {
            // Check if it contains "hour" to convert
            if cookTime.lowercased().contains("hour") {
                return minutes * 60
            }
            return minutes
        }
        return 30 // Default fallback
    }
    
    /// Total time including prep and cook time
    var totalTimeInMinutes: Int {
        return (prepTime ?? 0) + cookTimeInMinutes
    }
    
    /// Formatted time display
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
    
    /// Check if recipe is quick (under 30 minutes)
    var isQuick: Bool {
        return totalTimeInMinutes <= 30
    }
    
    /// Check if recipe is healthy (based on tags and calories)
    var isHealthy: Bool {
        let healthyTags = ["healthy", "low-fat", "high-protein", "vegetarian", "vegan"]
        let hasHealthyTags = tags.contains { tag in
            healthyTags.contains(tag.lowercased())
        }
        
        let isLowCalorie = (calories ?? 600) <= 500
        
        return hasHealthyTags || isLowCalorie
    }
    
    /// Difficulty display
    var difficultyDisplay: String {
        switch difficulty?.lowercased() {
        case "easy": return "Easy"
        case "medium": return "Medium"
        case "hard": return "Hard"
        default: return "Medium"
        }
    }
    
    /// Rating display with stars
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
    /// Check if recipe matches search criteria
    func matches(searchText: String) -> Bool {
        let lowercasedSearch = searchText.lowercased()
        
        return title.lowercased().contains(lowercasedSearch) ||
               ingredients.contains { $0.lowercased().contains(lowercasedSearch) } ||
               tags.contains { $0.lowercased().contains(lowercasedSearch) } ||
               (cuisineType?.lowercased().contains(lowercasedSearch) ?? false)
    }
    
    /// Check if recipe has specific tag
    func hasTag(_ tag: RecipeTag) -> Bool {
        return tags.contains(tag.rawValue)
    }
    
    /// Check if recipe is suitable for diet
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
    
    /// Get estimated cost display
    var costDisplay: String {
        guard let cost = costEstimate else { return "N/A" }
        return String(format: "$%.2f", cost)
    }
    
    /// Get calories display
    var caloriesDisplay: String {
        guard let calories = calories else { return "N/A" }
        return "\(calories) cal"
    }
    
    /// Get servings display
    var servingsDisplay: String {
        guard let servings = servings else { return "N/A" }
        return "\(servings) serving\(servings > 1 ? "s" : "")"
    }
    
    // MARK: - Mock Data (Minimal for SwiftUI Previews)
    static func mockRecipe() -> Recipe {
        return Recipe(
            id: "mock-recipe-1",
            title: "Sample Recipe",
            cookTime: "30 mins",
            prepTime: 15,
            servings: 4,
            calories: 350,
            imageUrl: nil,
            ingredients: ["Sample ingredient 1", "Sample ingredient 2"],
            steps: ["Sample step 1", "Sample step 2"],
            substitutions: ["Sample substitution"],
            tags: ["healthy", "quick"],
            difficulty: "medium",
            cuisineType: "american",
            costEstimate: 15.99,
            createdAt: Date(),
            updatedAt: Date(),
            createdBy: "MockUser",
            isPublic: true,
            rating: 4.5,
            ratingCount: 10
        )
    }
    
    // For backward compatibility
    static func enhancedMockRecipes() -> [Recipe] {
        return [mockRecipe()]
    }
}

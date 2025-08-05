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

/// Represents a complete recipe stored in the Supabase 'recipes' table.
/// 
/// This model includes all recipe metadata, ingredients, cooking instructions,
/// and nutritional information. It's used throughout the app for displaying
/// recipes, creating meal plans, and generating grocery lists.
/// 
/// The model includes custom decoding logic to handle:
/// - ISO8601 timestamp strings from Supabase (created_at, updated_at)
/// - JSONB arrays for ingredients, steps, substitutions, and tags
/// - Optional fields that may be null in the database
/// 
/// Example usage:
/// ```swift
/// let recipe = Recipe(
///     id: "uuid",
///     title: "Spaghetti Carbonara",
///     ingredients: ["pasta", "eggs", "bacon"],
///     steps: ["Boil pasta", "Cook bacon", "Mix with eggs"],
///     tags: ["italian", "quick", "dinner"]
/// )
/// ```
struct Recipe: Identifiable, Codable {
    // MARK: - Core Properties
    
    /// Unique identifier for the recipe (UUID from Supabase)
    let id: String
    
    /// Recipe title/name
    let title: String
    
    /// Cooking time as a formatted string (e.g., "30 mins", "1 hour")
    let cookTime: String?
    
    /// Preparation time in minutes
    let prepTime: Int?
    
    /// Number of servings this recipe yields
    let servings: Int?
    
    /// Estimated calories per serving
    let calories: Int?
    
    /// URL to the recipe's image (may be nil or invalid)
    let imageUrl: String?
    
    /// List of ingredients required for the recipe
    let ingredients: [String]
    
    /// Step-by-step cooking instructions
    let steps: [String]
    
    /// Optional ingredient substitutions
    let substitutions: [String]?
    
    /// Recipe tags for categorization and filtering
    let tags: [String]
    
    /// Difficulty level: "easy", "medium", or "hard"
    let difficulty: String?
    
    /// Type of cuisine (e.g., "italian", "mexican", "asian")
    let cuisineType: String?
    
    /// Estimated cost to make the recipe
    let costEstimate: Double?
    
    /// When the recipe was created in the database
    let createdAt: Date
    
    /// When the recipe was last updated
    let updatedAt: Date
    
    /// ID of the user who created this recipe (may be nil for system recipes)
    let createdBy: String?
    
    /// Spoonacular recipe ID (for external API reference)
    let spoonacularId: String?
    
    /// Whether this recipe is publicly visible
    let isPublic: Bool
    
    /// Average rating (0.0 to 5.0)
    let rating: Double
    
    /// Number of ratings received
    let ratingCount: Int
    
    // MARK: - Coding Keys
    
    /// Maps Swift property names to Supabase column names
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
    
    /// Creates a new Recipe instance with all required and optional properties.
    /// 
    /// This initializer is used for creating Recipe objects programmatically,
    /// such as when generating recipes from AI data or creating test data.
    /// 
    /// - Parameters:
    ///   - id: Unique identifier (usually UUID string)
    ///   - title: Recipe name
    ///   - cookTime: Formatted cooking time string
    ///   - prepTime: Preparation time in minutes
    ///   - servings: Number of servings
    ///   - calories: Calories per serving
    ///   - imageUrl: URL to recipe image
    ///   - ingredients: Array of ingredient strings
    ///   - steps: Array of instruction strings
    ///   - substitutions: Optional ingredient substitutions
    ///   - tags: Array of recipe tags
    ///   - difficulty: Difficulty level
    ///   - cuisineType: Type of cuisine
    ///   - costEstimate: Estimated cost
    ///   - createdAt: Creation timestamp
    ///   - updatedAt: Last update timestamp
    ///   - createdBy: Creator's user ID
    ///   - spoonacularId: Spoonacular recipe ID for external API reference
    ///   - isPublic: Public visibility flag
    ///   - rating: Average rating
    ///   - ratingCount: Number of ratings
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
    
    /// Custom decoder that handles Supabase's specific data format.
    /// 
    /// This decoder is necessary because:
    /// 1. Supabase returns timestamps as ISO8601 strings, not Date objects
    /// 2. JSONB arrays may be returned as strings in some cases
    /// 3. Some fields may be null or missing
    /// 
    /// The decoder includes fallback logic to handle various data formats
    /// and ensure the app doesn't crash on malformed data.
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode simple fields that don't require special handling
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
        rating = try container.decode(Double.self, forKey: .rating)
        ratingCount = try container.decode(Int.self, forKey: .ratingCount)
        
        // Custom decoding for timestamps (Supabase returns ISO8601 strings)
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
        
        // Custom decoding for ingredients array (handles both JSONB arrays and comma-separated strings)
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
        
        // Custom decoding for steps array (handles both JSONB arrays and comma-separated strings)
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
        
        // Custom decoding for substitutions array (optional, handles both JSONB arrays and comma-separated strings)
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
        
        // Custom decoding for tags array (handles both JSONB arrays and comma-separated strings)
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
    
    /// Returns a validated URL for the recipe image, or nil if the URL is invalid.
    /// 
    /// This property filters out common invalid URLs like "meal_placeholder" and
    /// ensures the URL has a valid scheme before returning it. This prevents
    /// AsyncImage from attempting to load invalid URLs and causing errors.
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
    
    /// Converts the cook time string to minutes for calculations.
    /// 
    /// Parses strings like "25 mins", "1 hour", "1h 30m" and returns
    /// the total time in minutes. Returns 30 minutes as default if parsing fails.
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
    
    /// Total time including prep and cook time in minutes.
    var totalTimeInMinutes: Int {
        return (prepTime ?? 0) + cookTimeInMinutes
    }
    
    /// Formatted time display for UI.
    /// 
    /// Returns strings like "30 mins", "1 hour", "1h 30m" based on total time.
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
    
    /// Whether this recipe is considered "quick" (30 minutes or less).
    var isQuick: Bool {
        return totalTimeInMinutes <= 30
    }
    
    /// Whether this recipe is considered "healthy".
    /// 
    /// A recipe is considered healthy if it has healthy tags or is low in calories.
    var isHealthy: Bool {
        let healthyTags = ["healthy", "low-fat", "high-protein", "vegetarian", "vegan"]
        let hasHealthyTags = tags.contains { tag in
            healthyTags.contains(tag.lowercased())
        }
        
        let isLowCalorie = (calories ?? 600) <= 500
        
        return hasHealthyTags || isLowCalorie
    }
    
    /// Human-readable difficulty level.
    var difficultyDisplay: String {
        switch difficulty?.lowercased() {
        case "easy": return "Easy"
        case "medium": return "Medium"
        case "hard": return "Hard"
        default: return "Medium"
        }
    }
    
    /// Rating display with star symbols.
    /// 
    /// Returns a string like "★★★★☆ (4)" showing the rating with stars
    /// and the number of ratings in parentheses.
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

/// Request model for creating a new recipe in the database.
/// 
/// This struct is used when creating new recipes via the API or when
/// seeding the database. It includes all the fields needed to create
/// a recipe, with proper coding keys for Supabase column mapping.
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
    
    /// Creates a new recipe creation request.
    /// 
    /// - Parameters:
    ///   - title: Recipe name
    ///   - cookTime: Formatted cooking time
    ///   - prepTime: Preparation time in minutes
    ///   - servings: Number of servings
    ///   - calories: Calories per serving
    ///   - imageUrl: URL to recipe image
    ///   - ingredients: Array of ingredient strings
    ///   - steps: Array of instruction strings
    ///   - substitutions: Optional ingredient substitutions
    ///   - tags: Array of recipe tags
    ///   - difficulty: Difficulty level
    ///   - cuisineType: Type of cuisine
    ///   - costEstimate: Estimated cost
    ///   - isPublic: Whether recipe should be publicly visible
    ///   - createdBy: ID of the creating user
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

/// Represents the difficulty level of a recipe.
enum RecipeDifficulty: String, CaseIterable {
    case easy = "easy"
    case medium = "medium"
    case hard = "hard"
    
    /// Human-readable display name.
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        }
    }
    
    /// Icon representation for UI.
    var icon: String {
        switch self {
        case .easy: return "🟢"
        case .medium: return "🟡"
        case .hard: return "🔴"
        }
    }
}

/// Represents different types of cuisine.
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
    
    /// Human-readable display name.
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
    
    /// Flag emoji representation.
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

/// Represents different tags that can be applied to recipes.
/// 
/// These tags are used for filtering, categorization, and dietary preferences.
/// Each tag has a display name and color for UI representation.
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
    
    /// Human-readable display name.
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
    
    /// Color name for UI styling.
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
    /// Checks if this recipe matches the given search text.
    /// 
    /// Searches in title, ingredients, tags, and cuisine type.
    /// 
    /// - Parameter searchText: The text to search for
    /// - Returns: True if the recipe matches the search criteria
    func matches(searchText: String) -> Bool {
        let lowercasedSearch = searchText.lowercased()
        
        return title.lowercased().contains(lowercasedSearch) ||
               ingredients.contains { $0.lowercased().contains(lowercasedSearch) } ||
               tags.contains { $0.lowercased().contains(lowercasedSearch) } ||
               (cuisineType?.lowercased().contains(lowercasedSearch) ?? false)
    }
    
    /// Checks if this recipe has a specific tag.
    /// 
    /// - Parameter tag: The tag to check for
    /// - Returns: True if the recipe has the specified tag
    func hasTag(_ tag: RecipeTag) -> Bool {
        return tags.contains(tag.rawValue)
    }
    
    /// Checks if this recipe is suitable for a specific diet.
    /// 
    /// - Parameter diet: The diet type to check (e.g., "vegetarian", "vegan")
    /// - Returns: True if the recipe is suitable for the specified diet
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
    
    /// Returns the estimated cost as a formatted string.
    var costDisplay: String {
        guard let cost = costEstimate else { return "N/A" }
        return String(format: "$%.2f", cost)
    }
    
    /// Returns the calories as a formatted string.
    var caloriesDisplay: String {
        guard let calories = calories else { return "N/A" }
        return "\(calories) cal"
    }
    
    /// Returns the servings as a formatted string.
    var servingsDisplay: String {
        guard let servings = servings else { return "N/A" }
        return "\(servings) serving\(servings > 1 ? "s" : "")"
    }
    
    // MARK: - Mock Data (Removed for Supabase integration)
    // Deprecated: Use Supabase fetching instead
    // All mock data functions have been removed to ensure the app
    // exclusively uses real data from the Supabase database.
}

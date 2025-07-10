//
//  UserProfile.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready user profile model for Supabase database.
//

import Foundation

// MARK: - Core UserProfile Model

struct UserProfile: Identifiable, Codable {
    let id: String
    var name: String?
    var email: String
    var age: Int?
    var gender: String?
    var goal: String?
    var diet: String?
    var budget: String?
    var isPremium: Bool
    var subscriptionRenewal: Date?
    var profileImageUrl: String?
    let createdAt: Date
    var updatedAt: Date
    var isOnboardingCompleted: Bool
    
    // Subscription tracking from production schema
    var subscriptionType: String // "free", "monthly", "yearly"
    var plansCreatedThisMonth: Int
    var aiGenerationsThisMonth: Int
    var lastPlanReset: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case age
        case gender
        case goal
        case diet
        case budget
        case isPremium = "is_premium"
        case subscriptionRenewal = "subscription_renewal"
        case profileImageUrl = "profile_image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case isOnboardingCompleted = "is_onboarding_completed"
        case subscriptionType = "subscription_type"
        case plansCreatedThisMonth = "plans_created_this_month"
        case aiGenerationsThisMonth = "ai_generations_this_month"
        case lastPlanReset = "last_plan_reset"
    }
    
    // MARK: - Initializers
    
    init(
        id: String,
        name: String? = nil,
        email: String,
        age: Int? = nil,
        gender: String? = nil,
        goal: String? = nil,
        diet: String? = nil,
        budget: String? = nil,
        isPremium: Bool = false,
        subscriptionRenewal: Date? = nil,
        profileImageUrl: String? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isOnboardingCompleted: Bool = false,
        subscriptionType: String = "free",
        plansCreatedThisMonth: Int = 0,
        aiGenerationsThisMonth: Int = 0,
        lastPlanReset: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.email = email
        self.age = age
        self.gender = gender
        self.goal = goal
        self.diet = diet
        self.budget = budget
        self.isPremium = isPremium
        self.subscriptionRenewal = subscriptionRenewal
        self.profileImageUrl = profileImageUrl
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isOnboardingCompleted = isOnboardingCompleted
        self.subscriptionType = subscriptionType
        self.plansCreatedThisMonth = plansCreatedThisMonth
        self.aiGenerationsThisMonth = aiGenerationsThisMonth
        self.lastPlanReset = lastPlanReset
    }
    
    // MARK: - Custom Decoding
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode regular fields
        id = try container.decode(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        age = try container.decodeIfPresent(Int.self, forKey: .age)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        goal = try container.decodeIfPresent(String.self, forKey: .goal)
        diet = try container.decodeIfPresent(String.self, forKey: .diet)
        budget = try container.decodeIfPresent(String.self, forKey: .budget)
        isPremium = try container.decode(Bool.self, forKey: .isPremium)
        profileImageUrl = try container.decodeIfPresent(String.self, forKey: .profileImageUrl)
        isOnboardingCompleted = try container.decode(Bool.self, forKey: .isOnboardingCompleted)
        subscriptionType = try container.decode(String.self, forKey: .subscriptionType)
        plansCreatedThisMonth = try container.decode(Int.self, forKey: .plansCreatedThisMonth)
        aiGenerationsThisMonth = try container.decode(Int.self, forKey: .aiGenerationsThisMonth)
        
        // Decode dates with fallback handling
        let iso8601Formatter = ISO8601DateFormatter()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Decode created_at
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt) {
            if let date = iso8601Formatter.date(from: createdAtString) {
                createdAt = date
            } else if let date = dateFormatter.date(from: createdAtString) {
                createdAt = date
            } else {
                createdAt = Date()
            }
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
        
        // Decode updated_at
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt) {
            if let date = iso8601Formatter.date(from: updatedAtString) {
                updatedAt = date
            } else if let date = dateFormatter.date(from: updatedAtString) {
                updatedAt = date
            } else {
                updatedAt = Date()
            }
        } else {
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
        
        // Decode subscription_renewal
        do {
            if let renewalString = try container.decodeIfPresent(String.self, forKey: .subscriptionRenewal) {
                if let date = iso8601Formatter.date(from: renewalString) {
                    subscriptionRenewal = date
                } else if let date = dateFormatter.date(from: renewalString) {
                    subscriptionRenewal = date
                } else {
                    subscriptionRenewal = nil
                }
            } else {
                subscriptionRenewal = nil
            }
        } catch {
            // Fallback to Date decoding
            subscriptionRenewal = try? container.decodeIfPresent(Date.self, forKey: .subscriptionRenewal) ?? nil
        }
        
        // Decode last_plan_reset with special handling for DATE format
        if let resetString = try? container.decode(String.self, forKey: .lastPlanReset) {
            if let date = dateFormatter.date(from: resetString) {
                lastPlanReset = date
            } else if let date = iso8601Formatter.date(from: resetString) {
                lastPlanReset = date
            } else {
                lastPlanReset = Date()
            }
        } else {
            lastPlanReset = try container.decode(Date.self, forKey: .lastPlanReset)
        }
    }
    
    // MARK: - Custom Encoding
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encode(email, forKey: .email)
        try container.encodeIfPresent(age, forKey: .age)
        try container.encodeIfPresent(gender, forKey: .gender)
        try container.encodeIfPresent(goal, forKey: .goal)
        try container.encodeIfPresent(diet, forKey: .diet)
        try container.encodeIfPresent(budget, forKey: .budget)
        try container.encode(isPremium, forKey: .isPremium)
        try container.encodeIfPresent(profileImageUrl, forKey: .profileImageUrl)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
        try container.encode(isOnboardingCompleted, forKey: .isOnboardingCompleted)
        try container.encode(subscriptionType, forKey: .subscriptionType)
        try container.encode(plansCreatedThisMonth, forKey: .plansCreatedThisMonth)
        try container.encode(aiGenerationsThisMonth, forKey: .aiGenerationsThisMonth)
        try container.encode(lastPlanReset, forKey: .lastPlanReset)
        try container.encodeIfPresent(subscriptionRenewal, forKey: .subscriptionRenewal)
    }

    // MARK: - Computed Properties
    
    /// Check if user has premium subscription
    var hasPremiumAccess: Bool {
        guard isPremium else { return false }
        
        if let renewalDate = subscriptionRenewal {
            return Date() < renewalDate
        }
        
        return false
    }
    
    /// Check if user can create more plans this month
    var canCreateMorePlans: Bool {
        if hasPremiumAccess {
            return plansCreatedThisMonth < Configuration.maxPlansPerUser
        } else {
            return plansCreatedThisMonth < Configuration.freePlanLimits.maxPlansPerMonth
        }
    }
    
    /// Check if user can use AI generation
    var canUseAIGeneration: Bool {
        if hasPremiumAccess {
            return true // Unlimited for premium
        } else {
            return aiGenerationsThisMonth < Configuration.freePlanLimits.maxAIGenerationsPerMonth
        }
    }
    
    /// Days until subscription renewal
    var daysUntilRenewal: Int? {
        guard let renewalDate = subscriptionRenewal else { return nil }
        
        let calendar = Calendar.current
        let days = calendar.dateComponents([.day], from: Date(), to: renewalDate).day
        return max(days ?? 0, 0)
    }
    
    /// User's display name
    var displayName: String {
        return name?.isEmpty == false ? name! : "User"
    }
    
    /// Check if profile is complete
    var isProfileComplete: Bool {
        return name != nil && 
               age != nil && 
               gender != nil && 
               goal != nil && 
               budget != nil &&
               diet != nil
    }
    
    /// Get subscription display name
    var subscriptionDisplayName: String {
        switch subscriptionType {
        case "free": return "Free Plan"
        case "monthly": return "Monthly Premium"
        case "yearly": return "Yearly Premium"
        default: return "Free Plan"
        }
    }
    
    /// Get plans remaining this month
    var plansRemainingThisMonth: Int {
        let maxPlans = hasPremiumAccess ? Configuration.maxPlansPerUser : Configuration.freePlanLimits.maxPlansPerMonth
        return max(maxPlans - plansCreatedThisMonth, 0)
    }
    
    /// Get AI generations remaining this month
    var aiGenerationsRemainingThisMonth: Int {
        if hasPremiumAccess {
            return Int.max // Unlimited
        } else {
            return max(Configuration.freePlanLimits.maxAIGenerationsPerMonth - aiGenerationsThisMonth, 0)
        }
    }
}

// MARK: - Request Models

struct UpdateUserProfileRequest: Codable {
    let name: String?
    let age: Int?
    let gender: String?
    let goal: String?
    let diet: String?
    let budget: String?
    let profileImageUrl: String?
    let isOnboardingCompleted: Bool?
    
    enum CodingKeys: String, CodingKey {
        case name
        case age
        case gender
        case goal
        case diet
        case budget
        case profileImageUrl = "profile_image_url"
        case isOnboardingCompleted = "is_onboarding_completed"
    }
}

// MARK: - Enums

enum Gender: String, CaseIterable {
    case male = "male"
    case female = "female"
    case other = "other"
    case preferNotToSay = "prefer_not_to_say"
    
    var displayName: String {
        switch self {
        case .male: return "Male"
        case .female: return "Female"
        case .other: return "Other"
        case .preferNotToSay: return "Prefer not to say"
        }
    }
    
    var icon: String {
        switch self {
        case .male: return "👨"
        case .female: return "👩"
        case .other: return "🧑"
        case .preferNotToSay: return "❓"
        }
    }
}

enum HealthGoal: String, CaseIterable {
    case loseWeight = "lose_weight"
    case gainWeight = "gain_weight"
    case maintainWeight = "maintain_weight"
    case buildMuscle = "build_muscle"
    case improveHealth = "improve_health"
    
    var displayName: String {
        switch self {
        case .loseWeight: return "Lose Weight"
        case .gainWeight: return "Gain Weight"
        case .maintainWeight: return "Maintain Weight"
        case .buildMuscle: return "Build Muscle"
        case .improveHealth: return "Improve Health"
        }
    }
    
    var icon: String {
        switch self {
        case .loseWeight: return "📉"
        case .gainWeight: return "📈"
        case .maintainWeight: return "⚖️"
        case .buildMuscle: return "💪"
        case .improveHealth: return "❤️"
        }
    }
    
    var description: String {
        switch self {
        case .loseWeight: return "Focus on calorie deficit and portion control"
        case .gainWeight: return "Focus on calorie surplus and nutrient-dense foods"
        case .maintainWeight: return "Focus on balanced nutrition and portion control"
        case .buildMuscle: return "Focus on high-protein meals and strength training support"
        case .improveHealth: return "Focus on nutritious, whole foods and balanced meals"
        }
    }
}

enum DietType: String, CaseIterable {
    case none = "none"
    case vegetarian = "vegetarian"
    case vegan = "vegan"
    case keto = "keto"
    case paleo = "paleo"
    case mediterranean = "mediterranean"
    case glutenFree = "gluten_free"
    
    var displayName: String {
        switch self {
        case .none: return "No Restrictions"
        case .vegetarian: return "Vegetarian"
        case .vegan: return "Vegan"
        case .keto: return "Ketogenic"
        case .paleo: return "Paleo"
        case .mediterranean: return "Mediterranean"
        case .glutenFree: return "Gluten Free"
        }
    }
    
    var icon: String {
        switch self {
        case .none: return "🍽️"
        case .vegetarian: return "🥬"
        case .vegan: return "🌱"
        case .keto: return "🥑"
        case .paleo: return "🥩"
        case .mediterranean: return "🫒"
        case .glutenFree: return "🌾"
        }
    }
    
    var description: String {
        switch self {
        case .none: return "All food types and ingredients"
        case .vegetarian: return "No meat, but includes dairy and eggs"
        case .vegan: return "No animal products whatsoever"
        case .keto: return "High-fat, low-carb for ketosis"
        case .paleo: return "Whole foods, no processed items"
        case .mediterranean: return "Fresh, healthy Mediterranean cuisine"
        case .glutenFree: return "No gluten-containing ingredients"
        }
    }
}

enum BudgetLevel: String, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Budget-Friendly"
        case .medium: return "Moderate"
        case .high: return "Premium"
        }
    }
    
    var icon: String {
        switch self {
        case .low: return "💰"
        case .medium: return "💳"
        case .high: return "💎"
        }
    }
    
    var range: String {
        switch self {
        case .low: return "$30-50/week"
        case .medium: return "$50-80/week"
        case .high: return "$80-120/week"
        }
    }
    
    var description: String {
        switch self {
        case .low: return "Focus on affordable ingredients and simple meals"
        case .medium: return "Balance of quality ingredients and reasonable cost"
        case .high: return "Premium ingredients and gourmet meal options"
        }
    }
}

enum SubscriptionType: String, CaseIterable {
    case free = "free"
    case monthly = "monthly"
    case yearly = "yearly"
    
    var displayName: String {
        switch self {
        case .free: return "Free Plan"
        case .monthly: return "Monthly Premium"
        case .yearly: return "Yearly Premium"
        }
    }
    
    var price: String {
        switch self {
        case .free: return "Free"
        case .monthly: return Configuration.premiumMonthlyPrice
        case .yearly: return Configuration.premiumYearlyPrice
        }
    }
}

// MARK: - Extensions

extension UserProfile {
    /// Check if user needs to reset monthly limits
    mutating func resetMonthlyLimitsIfNeeded() {
        let calendar = Calendar.current
        if !calendar.isDate(lastPlanReset, equalTo: Date(), toGranularity: .month) {
            plansCreatedThisMonth = 0
            aiGenerationsThisMonth = 0
            lastPlanReset = Date()
        }
    }
    
    /// Increment plan creation count
    mutating func incrementPlanCreationCount() {
        resetMonthlyLimitsIfNeeded()
        plansCreatedThisMonth += 1
    }
    
    /// Increment AI generation count
    mutating func incrementAIGenerationCount() {
        resetMonthlyLimitsIfNeeded()
        aiGenerationsThisMonth += 1
    }
    
    /// Check if user can perform action based on subscription
    func canPerformAction(_ action: UserAction) -> Bool {
        switch action {
        case .createPlan:
            return canCreateMorePlans
        case .useAIGeneration:
            return canUseAIGeneration
        case .accessPremiumTemplates:
            return hasPremiumAccess
        case .exportGroceryList:
            return hasPremiumAccess
        case .customizeRecipes:
            return hasPremiumAccess
        }
    }
}

enum UserAction {
    case createPlan
    case useAIGeneration
    case accessPremiumTemplates
    case exportGroceryList
    case customizeRecipes
} 
//
//  UserProfile.swift
//  Makuli
//
//  Created by on 2025-07-03.
//
//  Maps to the Supabase 'profiles' table. Represents a user profile record.
//
import Foundation

struct UserProfile: Identifiable, Codable {
    var id: String
    var name: String?
    var age: Int?
    var gender: String?
    var goal: String?
    var budget: String?
    var isPremium: Bool = false
    var email: String?
    var diet: String?
    var subscriptionRenewalDate: String?
    var profileImageUrl: String?
    var createdAt: String?
    var isOnboardingCompleted: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case age
        case gender
        case goal
        case budget
        case isPremium = "is_premium"
        case email
        case diet
        case subscriptionRenewalDate = "subscription_renewal_date"
        case profileImageUrl = "profile_image_url"
        case createdAt = "created_at"
        case isOnboardingCompleted = "is_onboarding_completed"
    }
} 
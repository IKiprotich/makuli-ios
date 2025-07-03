//
//  UserProfile.swift
//  Makuli
//
//  Created by on 2025-07-03.
//
//  Maps to the Supabase 'profiles' table. Represents a user profile record.
//
import Foundation

struct UserProfile: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let age: Int?
    let gender: String?
    let diet: String?
    let budget: String?
    let is_premium: Bool?
    let subscription_renewal: String?
    let profile_image_url: String?
    let created_at: String?
    let is_onboarding_complete: Bool?
    let goal: String?
} 
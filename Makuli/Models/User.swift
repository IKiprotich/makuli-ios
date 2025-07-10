//
//  User.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import Foundation

// MARK: - User Model
struct User {
    var id: String // Supabase UUID
    var name: String
    var email: String
    var age: Int
    var gender: String
    var goal: String
    var diet: String
    var budget: String
    var isPremium: Bool
    var subscriptionRenewalDate: String?
    var profileImageURL: String?
    var isOnboardingCompleted: Bool
}

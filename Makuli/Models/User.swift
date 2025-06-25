//
//  User.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import Foundation

// MARK: - User Model
struct User {
    var name: String
    var email: String
    var age: Int
    var gender: String
    var diet: String
    var budget: String
    var isPremium: Bool
    var subscriptionRenewalDate: String?
    var profileImageURL: String?
}

// MARK: - Mock Data
let mockUser = User(
    name: "Ian Kiprotich",
    email: "ian.kiprotich@email.com",
    age: 24,
    gender: "Male",
    diet: "Vegetarian",
    budget: "Ksh 5,000 - Ksh 10,000",
    isPremium: true,
    subscriptionRenewalDate: "2024-08-15",
    profileImageURL: nil
)

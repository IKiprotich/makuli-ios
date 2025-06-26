//
//  OnboardingData.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import Foundation

class OnboardingData: ObservableObject {
    @Published var age: Int = 0
    @Published var gender: String = ""
    @Published var goal: String = ""
    @Published var budget: String = ""
    @Published var dietPreferences: [String] = []
    
    // Helper methods
    func reset() {
        age = 0
        gender = ""
        goal = ""
        budget = ""
        dietPreferences = []
    }
    
    func isValid() -> Bool {
        return age > 0 &&
               !gender.isEmpty &&
               !goal.isEmpty &&
               !budget.isEmpty
    }
}

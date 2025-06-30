//
//  RecipesViewModel.swift
//  Makuli
//
//  Created by Ian   on 30/06/2025.
//

import Foundation

@MainActor
class RecipesViewModel: ObservableObject {
    @Published var selectedFilter = "All"
    
    let filterOptions = ["All", "Quick", "High-Protein", "Budget"]
    let recipes = Recipe.enhancedMockRecipes()
    
    // Computed property to filter recipes based on selected filter
    var filteredRecipes: [Recipe] {
        switch selectedFilter {
        case "Quick":
            return recipes.filter { $0.cookTimeInMinutes <= 25 }
        case "High-Protein":
            return recipes.filter { $0.tags.contains("High-Protein") }
        case "Budget":
            return recipes.filter { $0.tags.contains("Budget") }
        default:
            return recipes
        }
    }
    
    // Actions
    func selectFilter(_ filter: String) {
        selectedFilter = filter
    }
} 
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
    @Published var recipes: [Recipe] = []
    
    let filterOptions = ["All", "Quick", "High-Protein", "Budget"]
    
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

    // Supabase fetch
    func fetchRecipes() async {
        do {
            let response = try await SupabaseManager.shared.client
                .from("recipes")
                .select()
                .execute()
            let recipes = try JSONDecoder().decode([Recipe].self, from: response.data)
            self.recipes = recipes
        } catch {
            print("Error fetching recipes: \(error.localizedDescription)")
            self.recipes = []
        }
    }
} 
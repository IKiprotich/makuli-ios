//
//  RecipesViewModel.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready recipes view model for Supabase database operations.
//

import Foundation

@MainActor
class RecipesViewModel: ObservableObject {
    @Published var recipes: [Recipe] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var searchText = ""
    @Published var selectedFilter = RecipeFilter.all
    @Published var selectedCuisine: CuisineType?
    @Published var selectedDifficulty: RecipeDifficulty?
    
    private let supabaseManager = SupabaseManager.shared
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    
    /// Filtered recipes based on current filters and search
    var filteredRecipes: [Recipe] {
        var filtered = recipes
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { $0.matches(searchText: searchText) }
        }
        
        // Apply category filter
        switch selectedFilter {
        case .all:
            break
        case .quick:
            filtered = filtered.filter { $0.isQuick }
        case .healthy:
            filtered = filtered.filter { $0.isHealthy }
        case .highProtein:
            filtered = filtered.filter { $0.hasTag(.highProtein) }
        case .vegetarian:
            filtered = filtered.filter { $0.hasTag(.vegetarian) }
        case .budgetFriendly:
            filtered = filtered.filter { $0.hasTag(.budgetFriendly) }
        case .mealPrep:
            filtered = filtered.filter { $0.hasTag(.mealPrep) }
        }
        
        // Apply cuisine filter
        if let cuisine = selectedCuisine {
            filtered = filtered.filter { $0.cuisineType?.lowercased() == cuisine.rawValue }
        }
        
        // Apply difficulty filter
        if let difficulty = selectedDifficulty {
            filtered = filtered.filter { $0.difficulty?.lowercased() == difficulty.rawValue }
        }
        
        return filtered.sorted { $0.rating > $1.rating }
    }
    
    /// Popular recipes (high rating and rating count)
    var popularRecipes: [Recipe] {
        return recipes
            .filter { $0.isPublic && $0.ratingCount >= 5 }
            .sorted { $0.rating > $1.rating }
            .prefix(10)
            .compactMap { $0 as Recipe }
    }
    
    /// Recent recipes (by creation date)
    var recentRecipes: [Recipe] {
        return recipes
            .filter { $0.isPublic }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(10)
            .compactMap { $0 as Recipe }
    }
    
    /// Quick recipes (under 30 minutes)
    var quickRecipes: [Recipe] {
        return recipes
            .filter { $0.isQuick && $0.isPublic }
            .sorted { $0.rating > $1.rating }
            .prefix(8)
            .compactMap { $0 as Recipe }
    }
    
    /// Available filter options
    var filterOptions: [RecipeFilter] {
        return RecipeFilter.allCases
    }
    
    /// Available cuisine options from current recipes
    var availableCuisines: [CuisineType] {
        let cuisineTypes: [CuisineType] = recipes.compactMap { recipe in
            guard let cuisineString = recipe.cuisineType else { return nil }
            return CuisineType(rawValue: cuisineString)
        }
        let uniqueCuisines = Set(cuisineTypes)
        return Array(uniqueCuisines).sorted { $0.displayName < $1.displayName }
    }
    
    // MARK: - Public Methods
    
    /// Fetches recipes from the database
    func fetchRecipes() async {
        // Don't fetch if we already have recipes and no error
        if !recipes.isEmpty && errorMessage == nil {
            Logger.debug("Recipes already loaded, skipping fetch")
            return
        }
        
        // Cancel any existing fetch task
        fetchTask?.cancel()
        
        fetchTask = Task {
            await performFetch()
        }
        
        await fetchTask?.value
    }
    
    /// Forces a refresh of recipes
    func refreshRecipes() async {
        recipes = []
        errorMessage = nil
        await performFetch()
    }
    
    /// Searches recipes with a specific query
    func searchRecipes(query: String) async {
        // Use regular fetchRecipes for now, since searchRecipes is not implemented
        await fetchRecipes()
        // Apply local filtering
        updateSearchText(query)
    }
    
    /// Gets a specific recipe by ID
    func getRecipe(id: String) -> Recipe? {
        return recipes.first { $0.id == id }
    }
    
    /// Rates a recipe
    func rateRecipe(id: String, rating: Double) async -> Bool {
        // TODO: Implement recipe rating in SupabaseManager
        Logger.info("Rating recipe \(id) with \(rating) stars - not yet implemented")
        self.errorMessage = "Recipe rating feature coming soon"
        return false
    }
    
    /// Creates a new recipe
    func createRecipe(_ request: CreateRecipeRequest) async -> Bool {
        // TODO: Implement recipe creation in SupabaseManager
        Logger.info("Creating new recipe: \(request.title) - not yet implemented")
        self.errorMessage = "Recipe creation feature coming soon"
        return false
    }
    
    /// Favorites a recipe (if user has premium)
    func favoriteRecipe(id: String) async -> Bool {
        // TODO: Implement recipe favoriting in SupabaseManager
        Logger.info("Favoriting recipe: \(id) - not yet implemented")
        self.errorMessage = "Recipe favoriting feature coming soon"
        return false
    }
    
    // MARK: - Filter Actions
    
    /// Selects a filter category
    func selectFilter(_ filter: RecipeFilter) {
        selectedFilter = filter
    }
    
    /// Selects a cuisine type
    func selectCuisine(_ cuisine: CuisineType?) {
        selectedCuisine = cuisine
    }
    
    /// Selects a difficulty level
    func selectDifficulty(_ difficulty: RecipeDifficulty?) {
        selectedDifficulty = difficulty
    }
    
    /// Clears all filters
    func clearFilters() {
        selectedFilter = .all
        selectedCuisine = nil
        selectedDifficulty = nil
        searchText = ""
    }
    
    /// Updates search text
    func updateSearchText(_ text: String) {
        searchText = text
    }
    
    // MARK: - Helper Methods
    
    /// Clears error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Gets recipes suitable for a specific diet
    func getRecipesForDiet(_ diet: String) -> [Recipe] {
        return recipes.filter { $0.suitableFor(diet: diet) }
    }
    
    /// Gets recipes within a time limit
    func getRecipesWithTimeLimit(_ maxMinutes: Int) -> [Recipe] {
        return recipes.filter { $0.totalTimeInMinutes <= maxMinutes }
    }
    
    /// Gets recipes within a budget
    func getRecipesWithBudget(_ maxCost: Double) -> [Recipe] {
        return recipes.filter { ($0.costEstimate ?? 0) <= maxCost }
    }
    
    // MARK: - Private Methods
    
    private func performFetch() async {
        isLoading = true
        errorMessage = nil
        do {
            Logger.info("Fetching recipes from database")
            let fetchedRecipes = try await supabaseManager.fetchRecipes()
            self.recipes = fetchedRecipes
            Logger.info("Successfully loaded \(fetchedRecipes.count) recipes")
        } catch is CancellationError {
            // Task was cancelled (e.g., user navigated away)
            Logger.debug("Recipe fetch cancelled")
            // Do not set errorMessage for cancellations
        } catch {
            Logger.error("Failed to fetch recipes: \(error)")
            self.errorMessage = "Failed to load recipes. Please check your connection and try again."
            self.recipes = []
        }
        isLoading = false
    }
    
    deinit {
        fetchTask?.cancel()
    }
}

// MARK: - Recipe Filter Enum

enum RecipeFilter: String, CaseIterable {
    case all = "all"
    case quick = "quick"
    case healthy = "healthy"
    case highProtein = "high_protein"
    case vegetarian = "vegetarian"
    case budgetFriendly = "budget_friendly"
    case mealPrep = "meal_prep"
    
    var displayName: String {
        switch self {
        case .all: return "All Recipes"
        case .quick: return "Quick & Easy"
        case .healthy: return "Healthy"
        case .highProtein: return "High Protein"
        case .vegetarian: return "Vegetarian"
        case .budgetFriendly: return "Budget Friendly"
        case .mealPrep: return "Meal Prep"
        }
    }
    
    var icon: String {
        switch self {
        case .all: return "🍽️"
        case .quick: return "⚡"
        case .healthy: return "🥗"
        case .highProtein: return "💪"
        case .vegetarian: return "🥬"
        case .budgetFriendly: return "💰"
        case .mealPrep: return "��"
        }
    }
} 
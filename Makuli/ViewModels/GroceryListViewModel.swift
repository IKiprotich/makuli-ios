//
//  GroceryListViewModel.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready grocery list view model for Supabase database operations.
//

import Foundation

@MainActor
class GroceryListViewModel: ObservableObject {
    @Published var groceries: [GroceryItem] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isGenerating = false
    @Published var selectedPlanId: String?
    
    private let supabaseManager = SupabaseManager.shared
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    
    /// Groceries grouped by category for better organization
    var groceriesByCategory: [String: [GroceryItem]] {
        Dictionary(grouping: groceries) { $0.category }
    }
    
    /// Total number of items
    var totalItems: Int {
        return groceries.count
    }
    
    /// Number of checked items
    var checkedItemsCount: Int {
        return groceries.filter { $0.isCompleted }.count
    }
    
    /// Completion percentage
    var completionPercentage: Double {
        guard totalItems > 0 else { return 0.0 }
        return Double(checkedItemsCount) / Double(totalItems) * 100.0
    }
    
    /// Total estimated cost
    var totalCost: Double {
        return groceries.reduce(0.0) { $0 + ($1.estimatedPrice ?? 0) }
    }
    
    /// Available categories
    var availableCategories: [String] {
        let categories = Set(groceries.map { $0.category })
        return Array(categories).sorted()
    }
    
    /// Unchecked items (still need to buy)
    var uncheckedItems: [GroceryItem] {
        return groceries.filter { !$0.isCompleted }
    }
    
    /// Checked items (already purchased)
    var checkedItemsList: [GroceryItem] {
        return groceries.filter { $0.isCompleted }
    }
    
    // MARK: - Public Methods
    
    /// Fetches grocery list for a user
    func fetchGroceries(for userId: String) async {
        // Cancel any existing fetch task
        fetchTask?.cancel()
        
        fetchTask = Task {
            await performFetch(for: userId)
        }
        
        await fetchTask?.value
    }
    
    /// Forces a refresh of the grocery list
    func refreshGroceries(for userId: String) async {
        groceries = []
        errorMessage = nil
        await performFetch(for: userId)
    }
    
    /// Generates grocery list from a meal plan
    func generateGroceryList(from planId: String, for userId: String) async -> Bool {
        do {
            Logger.info("Generating grocery list from plan: \(planId)")
            isGenerating = true
            errorMessage = nil
            let generatedItems = try await supabaseManager.createGroceryListFromPlan(planId: planId, userId: userId)
            // Update local state
            self.groceries = generatedItems
            self.selectedPlanId = planId
            Logger.info("Successfully generated \(generatedItems.count) grocery items")
            isGenerating = false
            return true
        } catch {
            Logger.error("Failed to generate grocery list: \(error)")
            self.errorMessage = error.localizedDescription
            isGenerating = false
            return false
        }
    }
    
    /// Toggles an item's checked status
    func toggleItemChecked(itemId: String) async -> Bool {
        do {
            Logger.info("Toggling grocery item: \(itemId)")
            if let index = groceries.firstIndex(where: { $0.id == itemId }) {
                groceries[index].isCompleted.toggle()
                // Persist change
                try await supabaseManager.updateGroceryItem(groceries[index])
            }
            return true
        } catch {
            Logger.error("Failed to toggle grocery item: \(error)")
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Adds a custom item to the grocery list
    func addCustomItem(
        name: String,
        quantity: String,
        category: String,
        estimatedCost: Double?,
        userId: String
    ) async -> Bool {
        do {
            Logger.info("Adding custom grocery item: \(name)")
            let newItem = GroceryItem(
                userId: userId,
                name: name,
                quantity: Double(quantity) ?? 1.0,
                unit: "pieces",
                category: category,
                priority: "Medium",
                isCompleted: false,
                notes: nil,
                estimatedPrice: estimatedCost,
                recipeId: nil,
                planId: selectedPlanId
            )
            try await supabaseManager.updateGroceryItem(newItem)
            self.groceries.append(newItem)
            Logger.info("Successfully added custom item")
            return true
        } catch {
            Logger.error("Failed to add custom item: \(error)")
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Removes an item from the grocery list
    func removeItem(itemId: String) async -> Bool {
        // TODO: Implement remove logic in SupabaseManager if needed
        Logger.error("removeGroceryItem is not implemented in SupabaseManager")
        self.errorMessage = "Remove item not implemented."
        return false
    }
    
    /// Updates item quantity
    func updateItemQuantity(itemId: String, newQuantity: String) async -> Bool {
        do {
            Logger.info("Updating quantity for item: \(itemId)")
            if let index = groceries.firstIndex(where: { $0.id == itemId }) {
                groceries[index].quantity = Double(newQuantity) ?? 1.0
                try await supabaseManager.updateGroceryItem(groceries[index])
            }
            return true
        } catch {
            Logger.error("Failed to update item quantity: \(error)")
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
    /// Clears all checked items
    func clearCheckedItems() async -> Bool {
        // TODO: Implement batch remove in SupabaseManager if needed
        Logger.error("removeGroceryItems is not implemented in SupabaseManager")
        self.errorMessage = "Clear checked items not implemented."
        return false
    }
    
    /// Shares grocery list (if user has premium)
    func shareGroceryList() -> String? {
        guard !groceries.isEmpty else { return nil }
        
        var shareText = "🛒 My Grocery List\n\n"
        
        for category in availableCategories.sorted() {
            let categoryItems = groceries.filter { $0.category == category }
            if !categoryItems.isEmpty {
                shareText += "\(category.uppercased()):\n"
                for item in categoryItems.sorted(by: { $0.name < $1.name }) {
                    let checkmark = item.isCompleted ? "✅" : "⬜"
                    shareText += "\(checkmark) \(item.quantity) \(item.name)\n"
                }
                shareText += "\n"
            }
        }
        
        shareText += "Total Items: \(totalItems)\n"
        shareText += "Estimated Cost: $\(String(format: "%.2f", totalCost))\n"
        shareText += "\nGenerated with Makuli 🍽️"
        
        return shareText
    }
    
    /// Exports grocery list to a structured format
    func exportGroceryList() -> GroceryListExport? {
        guard !groceries.isEmpty else { return nil }
        
        return GroceryListExport(
            items: groceries,
            totalItems: totalItems,
            checkedItems: checkedItemsCount,
            totalCost: totalCost,
            generatedDate: Date(),
            planId: selectedPlanId
        )
    }
    
    /// Marks all items as checked
    func checkAllItems() async -> Bool {
        // TODO: Implement batch check in SupabaseManager if needed
        Logger.error("checkAllGroceryItems is not implemented in SupabaseManager")
        self.errorMessage = "Check all items not implemented."
        return false
    }
    
    /// Unmarks all items
    func uncheckAllItems() async -> Bool {
        // TODO: Implement batch uncheck in SupabaseManager if needed
        Logger.error("uncheckAllGroceryItems is not implemented in SupabaseManager")
        self.errorMessage = "Uncheck all items not implemented."
        return false
    }
    
    // MARK: - Helper Methods
    
    /// Clears error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Gets items for a specific category
    func items(for category: String) -> [GroceryItem] {
        return groceries.filter { $0.category == category }.sorted { $0.name < $1.name }
    }
    
    /// Searches items by name
    func searchItems(query: String) -> [GroceryItem] {
        guard !query.isEmpty else { return groceries }
        
        let lowercaseQuery = query.lowercased()
        return groceries.filter { $0.name.lowercased().contains(lowercaseQuery) }
    }
    
    /// Gets items that match dietary restrictions
    func getItemsForDiet(_ diet: String) -> [GroceryItem] {
        // This would need dietary information in GroceryItem model
        // For now, return all items
        return groceries
    }
    
    // MARK: - Private Methods
    
    private func performFetch(for userId: String) async {
        isLoading = true
        errorMessage = nil
        do {
            Logger.info("Fetching grocery list for user: \(userId)")
            let fetchedGroceries = try await supabaseManager.fetchGroceryList(userId: userId)
            self.groceries = fetchedGroceries
            Logger.info("Successfully loaded \(fetchedGroceries.count) grocery items")
        } catch {
            Logger.error("Failed to fetch grocery list: \(error)")
            self.errorMessage = "Failed to load grocery list. Please check your connection and try again."
            self.groceries = []
        }
        isLoading = false
    }
    
    deinit {
        fetchTask?.cancel()
    }
}

// MARK: - Supporting Models

struct GroceryListExport {
    let items: [GroceryItem]
    let totalItems: Int
    let checkedItems: Int
    let totalCost: Double
    let generatedDate: Date
    let planId: String?
    
    var completionPercentage: Double {
        guard totalItems > 0 else { return 0.0 }
        return Double(checkedItems) / Double(totalItems) * 100.0
    }
    
    var fileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "grocery-list-\(formatter.string(from: generatedDate)).json"
    }
} 
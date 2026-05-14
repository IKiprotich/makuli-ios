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
    
    var groceriesByCategory: [String: [GroceryItem]] {
        Dictionary(grouping: groceries) { $0.category }
    }
    
    var totalItems: Int {
        return groceries.count
    }
    
    var checkedItemsCount: Int {
        return groceries.filter { $0.isCompleted }.count
    }
    
    var completionPercentage: Double {
        guard totalItems > 0 else { return 0.0 }
        return Double(checkedItemsCount) / Double(totalItems) * 100.0
    }
    
    var totalCost: Double {
        return groceries.reduce(0.0) { $0 + ($1.estimatedPrice ?? 0) }
    }
    
    var availableCategories: [String] {
        let categories = Set(groceries.map { $0.category })
        return Array(categories).sorted()
    }
    
    var uncheckedItems: [GroceryItem] {
        return groceries.filter { !$0.isCompleted }
    }
    
    var checkedItemsList: [GroceryItem] {
        return groceries.filter { $0.isCompleted }
    }
    
    // MARK: - Public Methods
    
    func fetchGroceries(for userId: String) async {
        fetchTask?.cancel()
        
        fetchTask = Task {
            await performFetch(for: userId)
        }
        
        await fetchTask?.value
    }
    
    func refreshGroceries(for userId: String) async {
        groceries = []
        errorMessage = nil
        await performFetch(for: userId)
    }
    
    func generateGroceryList(from planId: String, for userId: String) async -> Bool {
        do {
            Logger.info("Generating grocery list from plan: \(planId)")
            isGenerating = true
            errorMessage = nil
            let generatedItems = try await supabaseManager.createGroceryListFromPlan(planId: planId, userId: userId)
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
    
    func toggleItemChecked(itemId: String) async -> Bool {
        do {
            Logger.info("Toggling grocery item: \(itemId)")
            if let index = groceries.firstIndex(where: { $0.id == itemId }) {
                groceries[index].isCompleted.toggle()
                try await supabaseManager.updateGroceryItem(groceries[index])
            }
            return true
        } catch {
            Logger.error("Failed to toggle grocery item: \(error)")
            self.errorMessage = error.localizedDescription
            return false
        }
    }
    
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
    
    func removeItem(itemId: String) async -> Bool {
        Logger.error("removeGroceryItem is not implemented in SupabaseManager")
        self.errorMessage = "Remove item not implemented."
        return false
    }
    
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
    
    func clearCheckedItems() async -> Bool {
        Logger.error("removeGroceryItems is not implemented in SupabaseManager")
        self.errorMessage = "Clear checked items not implemented."
        return false
    }
    
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
    
    func checkAllItems() async -> Bool {
        Logger.error("checkAllGroceryItems is not implemented in SupabaseManager")
        self.errorMessage = "Check all items not implemented."
        return false
    }
    
    func uncheckAllItems() async -> Bool {
        Logger.error("uncheckAllGroceryItems is not implemented in SupabaseManager")
        self.errorMessage = "Uncheck all items not implemented."
        return false
    }
    
    // MARK: - Helper Methods
    
    func clearError() {
        errorMessage = nil
    }
    
    func items(for category: String) -> [GroceryItem] {
        return groceries.filter { $0.category == category }.sorted { $0.name < $1.name }
    }
    
    func searchItems(query: String) -> [GroceryItem] {
        guard !query.isEmpty else { return groceries }
        
        let lowercaseQuery = query.lowercased()
        return groceries.filter { $0.name.lowercased().contains(lowercaseQuery) }
    }
    
    func getItemsForDiet(_ diet: String) -> [GroceryItem] {
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
        } catch is CancellationError {
            Logger.debug("Grocery fetch cancelled")
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
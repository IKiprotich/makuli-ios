//
//  GroceryListView.swift
//  Makuli
//
//  Created by Ian   on 24/06/2025.
//

import SwiftUI

struct GroceryListView: View {
    
    let weekPlan: WeekPlan
    let groceryItems: [GroceryItem]?
        
    @State private var checkedItems: Set<String> = []
    @State private var aggregatedIngredients: [GroceryItem]
    
    init(weekPlan: WeekPlan, groceryItems: [GroceryItem]? = nil) {
        self.weekPlan = weekPlan
        self.groceryItems = groceryItems
        if let groceryItems = groceryItems {
            _aggregatedIngredients = State(initialValue: groceryItems)
        } else {
            // fallback to aggregation logic
            var ingredientMap: [String: GroceryItem] = [:]
            for meal in weekPlan.meals {
                if let recipe = meal.recipe {
                    for ingredient in recipe.ingredients {
                        let key = ingredient.name.lowercased()
                        if let existing = ingredientMap[key] {
                            ingredientMap[key] = GroceryItem(
                                id: existing.id,
                                name: ingredient.name,
                                quantity: existing.quantity,
                                category: ingredient.category,
                                emoji: ingredient.emoji
                            )
                        } else {
                            ingredientMap[key] = GroceryItem(
                                id: UUID().uuidString,
                                name: ingredient.name,
                                quantity: ingredient.quantity,
                                category: ingredient.category,
                                emoji: ingredient.emoji
                            )
                        }
                    }
                }
            }
            let items = Array(ingredientMap.values).sorted { $0.name < $1.name }
            _aggregatedIngredients = State(initialValue: items)
        }
    }
    
    var body: some View {
        ZStack {
            AppColors.bgCream
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Main content
                ScrollView {
                    ingredientSections
                }
                
                Spacer()
            }
        }
        .navigationTitle("Grocery List")
        .navigationBarTitleDisplayMode(.large)
        .safeAreaInset(edge: .bottom) {
            bottomToolbar
        }
    }
    
    // MARK: - Computed Properties
    private var sortedCategories: [String] {
        groupedIngredients.keys.sorted()
    }
    
    private var groupedIngredients: [String: [GroceryItem]] {
        Dictionary(grouping: aggregatedIngredients) { item in
            item.category.isEmpty ? "Other" : item.category
        }
    }
    
    private func itemsForCategory(_ category: String) -> [GroceryItem] {
        groupedIngredients[category] ?? []
    }
    
    // MARK: - Ingredient Sections
    private var ingredientSections: some View {
        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
            ForEach(sortedCategories, id: \.self) { category in
                Section {
                    ForEach(itemsForCategory(category), id: \.id) { item in
                        GroceryItemRowView(
                            item: item,
                            isChecked: checkedItems.contains(item.id),
                            onToggle: { toggleItem(item.id) }
                        )
                        .padding(.horizontal, 16)
                    }
                } header: {
                    sectionHeader(for: category)
                }
            }
        }
        .padding(.bottom, 100) // Space for bottom toolbar
    }
    
    // MARK: - Bottom Toolbar
    private var bottomToolbar: some View {
        HStack(spacing: 16) {
            Button("Clear All") {
                checkedItems.removeAll()
            }
            .foregroundColor(AppColors.textCharcoal)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            Spacer()
            
            Button("Mark All as Done") {
                checkedItems = Set(aggregatedIngredients.map { $0.id })
            }
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(AppColors.primaryOrange)
            .cornerRadius(25)
            .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 4, x: 0, y: 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppColors.bgCream)
    }
    
    @ViewBuilder
    private func sectionHeader(for category: String) -> some View {
        if !category.isEmpty {
            HStack {
                Text(category)
                    .font(.headline)
                    .foregroundColor(AppColors.textCharcoal)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                Spacer()
            }
            .background(AppColors.bgCream.opacity(0.9))
        }
    }
}

extension GroceryListView {
    
    private func toggleItem(_ id: String) {
        if checkedItems.contains(id) {
            checkedItems.remove(id)
        } else {
            checkedItems.insert(id)
        }
    }
    
    private func aggregateIngredients() {
        var ingredientMap: [String: GroceryItem] = [:]
        
        // collect all ingredients from all meals in the week
        for meal in weekPlan.meals {
            if let recipe = meal.recipe {
                for ingredient in recipe.ingredients {
                    let key = ingredient.name.lowercased()
                    
                    if let existing = ingredientMap[key] {
                        // aggregate quantities (simplified - assumes same unit)
                        let combinedQuantity = parseQuantity(existing.quantity) + parseQuantity(ingredient.quantity)
                        ingredientMap[key] = GroceryItem(
                            id: existing.id,
                            name: ingredient.name,
                            quantity: formatQuantity(combinedQuantity, unit: extractUnit(ingredient.quantity)),
                            category: ingredient.category,
                            emoji: ingredient.emoji
                        )
                    } else {
                        ingredientMap[key] = GroceryItem(
                            id: UUID().uuidString,
                            name: ingredient.name,
                            quantity: ingredient.quantity,
                            category: ingredient.category,
                            emoji: ingredient.emoji
                        )
                    }
                }
            }
        }
        
        aggregatedIngredients = Array(ingredientMap.values).sorted { $0.name < $1.name }
    }
    
    //MARK:  Helper functions for quantity parsing and formatting
    private func parseQuantity(_ quantity: String) -> Double {
        let numbers = quantity.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return Double(numbers) ?? 1.0
    }
    
    private func extractUnit(_ quantity: String) -> String {
        let components = quantity.components(separatedBy: " ")
        return components.count > 1 ? components.dropFirst().joined(separator: " ") : ""
    }
    
    private func formatQuantity(_ amount: Double, unit: String) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        
        let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return unit.isEmpty ? formattedAmount : "\(formattedAmount) \(unit)"
    }
}

#Preview {
    NavigationView {
        GroceryListView(
            weekPlan: WeekPlan.sampleWeekPlan,
            groceryItems: nil
        )
    }
}

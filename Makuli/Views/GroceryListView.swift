//
//  GroceryListView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready grocery list view.
//

import SwiftUI

struct GroceryListView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = GroceryListViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var showingAddItem = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppColors.bgCream
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if viewModel.isLoading {
                        loadingView
                    } else if viewModel.groceries.isEmpty {
                        emptyStateView
                    } else {
                        groceryListContent
                    }
                }
            }
            .navigationTitle("Grocery List")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Add Item", systemImage: "plus") {
                            showingAddItem = true
                        }
                        
                        Button("Clear Checked", systemImage: "trash") {
                            Task {
                                await viewModel.clearCheckedItems()
                            }
                        }
                        .disabled(viewModel.checkedItems == 0)
                        
                        Button("Share List", systemImage: "square.and.arrow.up") {
                            shareGroceryList()
                        }
                        .disabled(viewModel.groceries.isEmpty)
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search groceries")
            .task {
                if let user = authViewModel.user {
                    await viewModel.fetchGroceries(for: user.id)
                }
            }
            .refreshable {
                if let user = authViewModel.user {
                    await viewModel.refreshGroceries(for: user.id)
                }
            }
            .sheet(isPresented: $showingAddItem) {
                AddGroceryItemView(viewModel: viewModel)
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") {
                    viewModel.clearError()
                }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}

extension GroceryListView {
    private var loadingView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Loading grocery list...")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "cart.badge.plus")
                .font(.system(size: 60))
                .foregroundColor(AppColors.primaryOrange)
            
            Text("No Grocery Items")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Add items manually or generate a list from your meal plan")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: 12) {
                Button("Add Item") {
                    showingAddItem = true
                }
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.primaryOrange)
                .cornerRadius(12)
                
                Button("Generate from Meal Plan") {
                    generateFromMealPlan()
                }
                .foregroundColor(AppColors.primaryOrange)
                .padding()
                .frame(maxWidth: .infinity)
                .background(AppColors.primaryOrange.opacity(0.1))
                .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    private var groceryListContent: some View {
        VStack(spacing: 0) {
            // Progress header
            progressHeader
            
            // Grocery list
            List {
                ForEach(groupedGroceries.keys.sorted(), id: \.self) { category in
                    Section(category.uppercased()) {
                        ForEach(groupedGroceries[category] ?? [], id: \.id) { item in
                            GroceryItemRow(
                                item: item,
                                onToggle: {
                                    Task {
                                        await viewModel.toggleItemChecked(itemId: item.id)
                                    }
                                },
                                onRemove: {
                                    Task {
                                        await viewModel.removeItem(itemId: item.id)
                                    }
                                }
                            )
                        }
                    }
                }
            }
            .listStyle(.insetGrouped)
            .background(AppColors.bgCream)
        }
    }
    
    private var progressHeader: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Shopping Progress")
                        .font(.headline)
                    
                    Text("\(viewModel.checkedItems) of \(viewModel.totalItems) items")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(Int(viewModel.completionPercentage))%")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(AppColors.primaryOrange)
                    
                    Text("Complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            ProgressView(value: viewModel.completionPercentage / 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.primaryOrange))
            
            HStack {
                Text("Total: $\(String(format: "%.2f", viewModel.totalCost))")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                if viewModel.totalItems > 0 {
                    Button(viewModel.checkedItems == viewModel.totalItems ? "Uncheck All" : "Check All") {
                        Task {
                            if viewModel.checkedItems == viewModel.totalItems {
                                await viewModel.uncheckAllItems()
                            } else {
                                await viewModel.checkAllItems()
                            }
                        }
                    }
                    .font(.caption)
                    .foregroundColor(AppColors.primaryOrange)
                }
            }
        }
        .padding()
        .background(Color.white)
    }
    
    private var groupedGroceries: [String: [GroceryItem]] {
        let filteredItems = searchText.isEmpty ? 
            viewModel.groceries : 
            viewModel.searchItems(query: searchText)
        
        return Dictionary(grouping: filteredItems) { $0.category }
    }
    
    private func generateFromMealPlan() {
        // This would typically show a plan selector
        // For now, just show an alert
        // TODO: Implement meal plan selection
    }
    
    private func shareGroceryList() {
        guard let shareText = viewModel.shareGroceryList() else { return }
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}

struct GroceryItemRow: View {
    let item: GroceryItem
    let onToggle: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Button(action: onToggle) {
                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(item.isChecked ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.body)
                    .foregroundColor(.primary)
                    .strikethrough(item.isChecked)
                
                HStack {
                    Text(item.quantity)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let cost = item.estimatedCost, cost > 0 {
                        Text("• $\(String(format: "%.2f", cost))")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
            }
            
            Spacer()
        }
        .opacity(item.isChecked ? 0.6 : 1.0)
        .swipeActions(edge: .trailing) {
            Button("Delete", role: .destructive) {
                onRemove()
            }
        }
    }
}

struct AddGroceryItemView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: GroceryListViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var itemName = ""
    @State private var quantity = ""
    @State private var selectedCategory = "Produce"
    @State private var estimatedCost = ""
    @State private var isAdding = false
    
    let categories = ["Produce", "Dairy", "Meat", "Pantry", "Frozen", "Bakery", "Other"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Item Details") {
                    TextField("Item name", text: $itemName)
                    TextField("Quantity (e.g., 2 lbs, 1 bottle)", text: $quantity)
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(categories, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    
                    HStack {
                        Text("Estimated Cost")
                        Spacer()
                        TextField("0.00", text: $estimatedCost)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add") {
                        addItem()
                    }
                    .disabled(!canAddItem || isAdding)
                }
            }
        }
    }
    
    private var canAddItem: Bool {
        !itemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !quantity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func addItem() {
        guard let user = authViewModel.user else { return }
        
        isAdding = true
        
        Task {
            let cost = Double(estimatedCost.isEmpty ? "0" : estimatedCost) ?? 0
            
            let success = await viewModel.addCustomItem(
                name: itemName.trimmingCharacters(in: .whitespacesAndNewlines),
                quantity: quantity.trimmingCharacters(in: .whitespacesAndNewlines),
                category: selectedCategory,
                estimatedCost: cost > 0 ? cost : nil,
                userId: user.id
            )
            
            isAdding = false
            
            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    GroceryListView()
        .environmentObject(AuthViewModel())
} 
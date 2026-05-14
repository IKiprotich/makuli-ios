//
//  BudgetView.swift
//  Makuli
//
//  Created by Ian on 2025-08-04.
//

import SwiftUI

struct BudgetView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBudget: String
    let onSave: (String) -> Void
    
    private let budgetOptions = [
        ("Budget-Friendly", "$30-50/week", "Focus on affordable ingredients and simple meals"),
        ("Moderate", "$50-80/week", "Balance of quality ingredients and reasonable cost"),
        ("Premium", "$80-120/week", "Premium ingredients and gourmet meal options")
    ]
    
    init(currentBudget: String, onSave: @escaping (String) -> Void) {
        self._selectedBudget = State(initialValue: currentBudget)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Budget Preference")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.text)
                    
                    Text("Choose your weekly grocery budget")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    ForEach(budgetOptions, id: \.0) { option in
                        let isSelected = selectedBudget == option.0
                        Button(action: {
                            selectedBudget = option.0
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text(option.0)
                                        .font(.headline)
                                        .foregroundColor(isSelected ? .white : AppColors.text)
                                    
                                    Spacer()
                                    
                                    Text(option.1)
                                        .font(.subheadline)
                                        .foregroundColor(isSelected ? .white.opacity(0.8) : AppColors.textSecondary)
                                }
                                
                                Text(option.2)
                                    .font(.caption)
                                    .foregroundColor(isSelected ? .white.opacity(0.7) : AppColors.textSecondary)
                                    .multilineTextAlignment(.leading)
                                
                                if isSelected {
                                    HStack {
                                        Spacer()
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.white)
                                    }
                                }
                            }
                            .padding()
                            .background(isSelected ? AppColors.primaryOrange : Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(isSelected ? AppColors.primaryOrange : Color.gray.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button("Save Changes") {
                    onSave(selectedBudget)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(AppColors.primaryOrange)
                .foregroundColor(.white)
                .cornerRadius(12)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(AppColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(AppColors.primaryOrange)
                }
            }
        }
    }
}

#Preview {
    BudgetView(currentBudget: "Moderate") { newBudget in
        print("New budget: \(newBudget)")
    }
} 
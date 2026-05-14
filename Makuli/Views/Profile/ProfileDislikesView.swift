//
//  ProfileDislikesView.swift
//  Makuli
//
//  Created by Ian on 2025-08-04.
//

import SwiftUI

struct ProfileDislikesView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedDislikes: [String]
    let onSave: ([String]) -> Void
    
    private let dislikeOptions = [
        "Almonds", "Asparagus", "Avocado", "Banana", "Beans", "Beets", "Bell peppers", "Blue cheese", "Broccoli", "Brussels sprouts", "Cabbage", "Carrots", "Cauliflower", "Celery", "Cheese", "Cucumber", "Eggplant", "Fennel", "Garlic", "Ginger", "Kale", "Lamb", "Leek", "Lettuce", "Mushrooms", "Olives", "Onion", "Peas", "Pineapple", "Radish", "Spinach", "Squash", "Sweet potato", "Tomato", "Tofu", "Zucchini"
    ]
    
    init(currentDislikes: [String], onSave: @escaping ([String]) -> Void) {
        self._selectedDislikes = State(initialValue: currentDislikes)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Dislikes")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.text)
                    
                    Text("Select ingredients you don't like")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 20)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(dislikeOptions, id: \.self) { item in
                            let isSelected = selectedDislikes.contains(item)
                            Button(action: {
                                if isSelected {
                                    selectedDislikes.removeAll { $0 == item }
                                } else {
                                    selectedDislikes.append(item)
                                }
                            }) {
                                Text(item)
                                    .font(.headline)
                                    .foregroundColor(isSelected ? .white : AppColors.text)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(isSelected ? AppColors.warnRed : Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(isSelected ? AppColors.warnRed : Color.gray.opacity(0.3), lineWidth: 1)
                                    )
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                
                Button("Save Changes") {
                    onSave(selectedDislikes)
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
    ProfileDislikesView(currentDislikes: ["Mushrooms", "Olives"]) { newDislikes in
        print("New dislikes: \(newDislikes)")
    }
} 
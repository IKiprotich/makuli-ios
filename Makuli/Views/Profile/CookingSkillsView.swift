//
//  CookingSkillsView.swift
//  Makuli
//
//  Created by Ian on 2025-07-23.
//

import SwiftUI

struct CookingSkillsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSkill: String
    let onSave: (String) -> Void
    
    private let skillOptions = [
        ("Novice", "I think I know where the microwave is"),
        ("Beginner", "Comfortable with simple recipes"),
        ("Intermediate", "Comfortable with most recipes"),
        ("Advanced", "I should be on MasterChef")
    ]
    
    init(currentSkill: String, onSave: @escaping (String) -> Void) {
        self._selectedSkill = State(initialValue: currentSkill)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Cooking Skills")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.text)
                    
                    Text("How would you rate your cooking skills?")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    ForEach(skillOptions, id: \.0) { option in
                        let isSelected = selectedSkill == option.0
                        Button(action: {
                            selectedSkill = option.0
                        }) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(option.0)
                                    .font(.headline)
                                    .foregroundColor(isSelected ? .white : AppColors.text)
                                Text(option.1)
                                    .font(.caption)
                                    .foregroundColor(isSelected ? .white.opacity(0.8) : AppColors.textSecondary)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
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
                    onSave(selectedSkill)
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
    CookingSkillsView(currentSkill: "Beginner") { newSkill in
        print("New cooking skill: \(newSkill)")
    }
} 
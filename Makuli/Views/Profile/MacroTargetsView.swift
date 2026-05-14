//
//  MacroTargetsView.swift
//  Makuli
//
//  Created by Ian on 2025-08-04.
//

import SwiftUI

struct MacroTargetsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var proteinPercentage: Int
    @State private var carbsPercentage: Int
    @State private var fatPercentage: Int
    let onSave: (Int, Int, Int) -> Void
    
    init(currentProtein: Int, currentCarbs: Int, currentFat: Int, onSave: @escaping (Int, Int, Int) -> Void) {
        self._proteinPercentage = State(initialValue: currentProtein)
        self._carbsPercentage = State(initialValue: currentCarbs)
        self._fatPercentage = State(initialValue: currentFat)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Macro Targets")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.text)
                    
                    Text("Set your macronutrient percentages")
                        .font(.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding(.top, 20)
                
                VStack(spacing: 16) {
                    HStack(spacing: 20) {
                        MacroCard(title: "Protein", percentage: proteinPercentage, color: AppColors.primaryOrange)
                        MacroCard(title: "Carbs", percentage: carbsPercentage, color: AppColors.successGreen)
                        MacroCard(title: "Fat", percentage: fatPercentage, color: AppColors.warnRed)
                    }
                    
                    Text("Total: \(proteinPercentage + carbsPercentage + fatPercentage)%")
                        .font(.headline)
                        .foregroundColor(proteinPercentage + carbsPercentage + fatPercentage == 100 ? AppColors.successGreen : AppColors.warnRed)
                }
                
                VStack(spacing: 24) {
                    MacroSlider(
                        title: "Protein",
                        percentage: $proteinPercentage,
                        color: AppColors.primaryOrange
                    )
                    
                    MacroSlider(
                        title: "Carbohydrates",
                        percentage: $carbsPercentage,
                        color: AppColors.successGreen
                    )
                    
                    MacroSlider(
                        title: "Fat",
                        percentage: $fatPercentage,
                        color: AppColors.warnRed
                    )
                }
                .padding(.horizontal, 20)
                
                Spacer()
                
                Button("Save Changes") {
                    onSave(proteinPercentage, carbsPercentage, fatPercentage)
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
                .disabled(proteinPercentage + carbsPercentage + fatPercentage != 100)
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

struct MacroCard: View {
    let title: String
    let percentage: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(percentage)%")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}

struct MacroSlider: View {
    let title: String
    @Binding var percentage: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(AppColors.text)
                Spacer()
                Text("\(percentage)%")
                    .font(.headline)
                    .foregroundColor(color)
            }
            
            Slider(value: Binding(
                get: { Double(percentage) },
                set: { percentage = Int($0) }
            ), in: 10...50, step: 5)
            .accentColor(color)
        }
    }
}

#Preview {
    MacroTargetsView(currentProtein: 25, currentCarbs: 55, currentFat: 20) { protein, carbs, fat in
        print("New macro targets: \(protein)%, \(carbs)%, \(fat)%")
    }
} 
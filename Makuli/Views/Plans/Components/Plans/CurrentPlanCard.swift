//
//  CurrentPlanCard.swift
//  Makuli
//
//  Created by Ian   on 20/06/2025.
//

import SwiftUI

struct CurrentPlanCard: View {
    
    let plan: Plan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active Plan")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(plan.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Text("\(plan.completedMealsCount)/\(plan.totalMealsCount)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                let validImageURL: URL? = nil // No real image URL for now
                if let url = validImageURL {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray5))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.secondary)
                            )
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .background(Color(.systemGray5))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
            
            // Progress bar
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(plan.progress * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.successGreen)
                }
                
                // Resume button with NavigationLink
                NavigationLink(destination: WeekDetailView(plan: PlanWithRecipes(id: plan.id, plan: plan, recipes: []))) {
                    HStack {
                        Text("Resume")
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Image(systemName: "arrow.right")
                    }
                    .foregroundColor(AppColors.primaryOrange)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(AppColors.warmsand)
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Active Meal Plan: \(plan.title), \(plan.completedMealsCount) of \(plan.totalMealsCount) meals completed")
        }
    }
}

//#Preview {
//    CurrentPlanCard(plan: Plan.mockWeeklyPlan().plan)
//}


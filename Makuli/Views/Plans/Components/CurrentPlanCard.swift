//
//  CurrentPlanCard.swift
//  Makuli
//
//  Created by Ian   on 20/06/2025.
//

import SwiftUI

struct CurrentPlanCard: View {
    
    let plan: WeekPlan
    
    var body: some View {
        
        VStack (alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Active Plan")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .textCase(.uppercase)
                        .tracking(0.5)
                    
                    Text(plan.planName)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Text("\(plan.mealsCompleted)/\(plan.totalMeals)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                }
                
                Spacer()
                
                AsyncImage(url: URL(string: "meal_placeholder")) { image in
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
                
            }
            
            //progress bar
            VStack (alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(Int(plan.progressPercentage * 100))%")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(AppColors.successGreen)
                }
                
                //resume button
                Button {
                    // to implement the resume functionality
                } label: {
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
                    .shadow(color: .black.opacity(0.08) ,radius: 10, x: 0, y: 4)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Active Meal Plan: \(plan.planName), \(plan.mealsCompleted) of \(plan.totalMeals) meals completed")
            
            
        }
    }
}

#Preview {
   // CurrentPlanCard()
}

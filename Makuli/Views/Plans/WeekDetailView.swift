//
//  WeekDetailView.swift
//  Makuli
//
//  Created by Ian   on 21/06/2025.
//

import SwiftUI

struct WeekDetailView: View {
    
    let weekPlan: WeekPlan
    @State private var dayPlans: [DayPlan] = []
    @Environment(\.dismiss) private var dismiss
    

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                
                //main content
                ScrollView {
                    VStack (spacing: 0) {
                        
                        //header section
                        headerSection
                        
                        //daycards
                        LazyVStack(spacing: 16){
                            ForEach(dayPlans) { dayPlan in
                                DayCardView(dayPlan: dayPlan)
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 24)
                        .padding(.bottom, 100) //the space for the sticky button
                    }
                }
                
                //sticky bottom button
                groceryListButton
                    .padding(.horizontal, 20)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 16)
            }
        }
        .navigationBarBackButtonHidden(true)
        .background(
            AppColors.warmsand.opacity(0.3)
        )
        .onAppear {
            dayPlans = DayPlan.mockData()
        }
        
    }
}


extension WeekDetailView {
    
    //header section
    private var headerSection: some View {
        VStack(spacing: 16) {
            // Navigation and title
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(AppColors.textCharcoal)
                }
                .accessibilityLabel("Go back")
                
                
                Spacer()
                
                
                Text(weekPlan.weekTitle + " Plan")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(AppColors.textCharcoal)
                
                Spacer()
                
                
                Button (action:{
                    // implement more options
                }) {
                    Image(systemName: "ellipsis")
                        .font(.title2)
                        .foregroundColor(AppColors.textCharcoal)
                }
                .accessibilityLabel("More options")
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            // Budget and progress card
            budgetProgressCard
                .padding(.horizontal, 20)
        }
    }
    
    //budget progress card
    private var budgetProgressCard: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Budget")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("KES \(Int(weekPlan.totalCost * 0.8).formatted())")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(AppColors.textCharcoal)
                    
                    Text("/ KES \(Int(weekPlan.totalCost).formatted())")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Text("\(weekPlan.mealsCompleted) of \(weekPlan.totalMeals) Days Completed")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // circular progress indicator
            CircularProgressView(progress: weekPlan.progressPercentage)
                .frame(width: 60, height: 60)
            
            Button("Add to Grocery List") {
                // implement the add to grocery list action
            }
            .font(.caption)
            .foregroundColor(AppColors.primaryOrange)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(AppColors.warmsand)
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    
    //grocery list button
    private var groceryListButton: some View {
        Button(action: {
            //implement the generate grocery list function
        }){
            HStack {
                Image(systemName: "cart.fill")
                Text("Finish Week")
                    .fontWeight(.semibold)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color("PrimaryOrange"))
            )
        }
        .accessibilityLabel("Generate grocery list for this week")
        
    }
    
}

#Preview {
    WeekDetailView(weekPlan: WeekPlan.mockData[2])
}

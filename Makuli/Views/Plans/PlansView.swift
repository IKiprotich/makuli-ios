//
//  PlansView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct PlansView: View {
    
    @State private var weekPlans = WeekPlan.mockData
    @State private var selectedWeek: WeekPlan?
    
    var activePlan: WeekPlan? {
        weekPlans.first {$0.isActive}
    }
    
    var pastPlans: [WeekPlan] {
        weekPlans.filter{ !$0.isActive}.sorted { $0.weekNumber > $1.weekNumber}
    }
    
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
                    //header with add button
                    headerSection
                    
                    //week carousel section
                    weekCarouselSection
                    
                    //current active plan section
                    if let activePlan = activePlan {
                        currentPlansSection(activePlan)
                    }
                    
                    //previous plans section
                    previousPlansSection

                }
                .padding(.top, 8)
            }
            .navigationBarHidden(true)
            .background(AppColors.warmsand.opacity(0.3).ignoresSafeArea())
        }
        .onAppear {
            selectedWeek = weekPlans.first
        }
    }
    
    
}



extension PlansView {
    
    //headersection
    private var headerSection: some View {
        HStack {
            Text("My Meal Plans")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textCharcoal)
            
            Spacer()
            
            Button {
                //implement the add plan functionality later
            } label: {
                Image(systemName: "plus")
                    .font(.title2)
                    .foregroundColor(AppColors.primaryOrange)
                    .frame(width: 44, height: 44)
                    .background(
                        Circle()
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.1), radius: 4)
                    )
            }
            .accessibilityLabel("Add a new meal plan")

        }
        .padding(.horizontal, 20)
    }
    
    //week carousel section
    private var weekCarouselSection: some View {
        WeekCarouselView(weeks: weekPlans, selectedWeek: $selectedWeek )
    }
    
    //current plans section
    private func currentPlansSection(_ plan: WeekPlan) -> some View {
        CurrentPlanCard(plan: plan)
            .padding(.horizontal, 20)
    }
    
    
    //previous plans section
    private var previousPlansSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Previous Plans")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textCharcoal)
                .padding(.horizontal, 20)
            
            
            LazyVStack(alignment: .leading, spacing: 16) {
                ForEach(pastPlans) { plan in
                    PreviousPlanRow(plan: plan)
                        .padding(.horizontal, 20)
                }
            }
        }
    }
    
    // previoous plan row section
    
    struct PreviousPlanRow: View {
        
        let plan: WeekPlan
        
        var body: some View {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(plan.weekTitle)
                        .font(.headline)
                        .foregroundColor(AppColors.textCharcoal)
                    
                    
                    Text(plan.planName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 4)
            )
            .accessibilityElement(children: .combine)
            .accessibilityLabel(Text("Previous plan: \(plan.planName) from week \(plan.weekNumber)"))
            .accessibilityHint(Text("Tap to view details"))
        }
    }
    
    
    
    
}

#Preview {
    PlansView()
}

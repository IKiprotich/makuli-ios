//
//  HomeView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct HomeView: View {
    
    //sample meals
    private let sampleMeals = [
            MealPlan(
                mealType: .breakfast,
                name: "Kenyan Chai and Mandazi",
                duration: 30,
                difficulty: .easy,
                imageName: "cup.and.saucer.fill",
                backgroundColor: "orange"
            ),
            MealPlan(
                mealType: .lunch,
                name: "Sukuma Wiki with Ugali",
                duration: 45,
                difficulty: .medium,
                imageName: "leaf.fill",
                backgroundColor: "green"
            ),
            MealPlan(
                mealType: .dinner,
                name: "Nyama Choma with Kachumbari",
                duration: 60,
                difficulty: .hard,
                imageName: "flame.fill",
                backgroundColor: "red"
            )
        ]
    
    //sample metrics
    private let sampleMetrics = [
           ProgressMetrics(title: "Meals Cooked", value: "12", change: "+10%", isPositive: true),
           ProgressMetrics(title: "Budget Usage", value: "Ksh 2,500", change: "-5%", isPositive: false),
           ProgressMetrics(title: "Consistency Streak", value: "7 days", change: "+20%", isPositive: true)
       ]
    
    
    
    var body: some View {
        NavigationView {
            
            ZStack{
                
                AppColors.bgCream
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        HeaderView()
                        
                        greetingView
                        
                        TodaysMealPlanSection(meals: sampleMeals)
                        
                        QuickAccessSection(onGroceryListTap:handleGroceryListTap ,
                                           onExploreRecipeTap: handleExploreRecipesTap)
                        
                        ProgressTrackerSection(metrics: sampleMetrics)
                        
                        featuredMealView
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 16)
                    
                }
                .background(AppColors.warmsand.opacity(0.3).ignoresSafeArea())
                
                
            }
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden()
            
        }
        
    }
    
}



extension HomeView {
    
    //greeting view
    private var greetingView: some View {
        HStack {
            Text("Good Morning, Ian 👋")
                .font(.title)
                .foregroundColor(.primary)
            Spacer()
        }
    }
    
    //featured meal view
    private var featuredMealView: some View {
        VStack {
            Image(systemName: "photo")
                .font(.system(size: 60))
                .foregroundColor(.gray)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(gradient: Gradient(colors: [.primary.opacity(0.3), .brown.opacity(0.3)]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
                )
                .cornerRadius(16)
        }
    }
    
    // handle grocery list tap fucn
    private func handleGroceryListTap() {
            // Navigate to grocery list
            print("Grocery List tapped")
        }
    
    //explore recipe fucntion
    private func handleExploreRecipesTap() {
            // Navigate to recipes
            print("Explore Recipes tapped")
        }
    
    
    
}

#Preview {
    HomeView()
}

//
//  AppTabView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI


struct AppTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(0)

            PlansView()
                .tabItem {
                    Label("Plans", systemImage: "calendar")
                }
                .tag(1)

            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(3)
        }
        .accentColor(AppColors.primaryOrange)
    }
}


#Preview {
    AppTabView()
}

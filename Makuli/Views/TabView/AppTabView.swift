//
//  AppTabView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct AppTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }

            PlansView()
                .tabItem {
                    Label("Plans", systemImage: "calendar")
                }

            RecipesView()
                .tabItem {
                    Label("Recipes", systemImage: "fork.knife")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .accentColor(AppColors.primaryOrange)
    }
}


#Preview {
    AppTabView()
}

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
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tag(0)
                
                PlansView()
                    .tag(1)
                
                RecipesView()
                    .tag(2)
                
                ProfileView()
                    .tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Environment(\.colorScheme) var colorScheme
    
    private let tabs = [
        TabItem(title: "Home", emoji: "🏠"),
        TabItem(title: "Plans", emoji: "🍽️"),
        TabItem(title: "Recipes", emoji: "📖"),
        TabItem(title: "Profile", emoji: "👤")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                let tab = tabs[index]
                let isSelected = selectedTab == index
                
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        // Emoji with animation
                        Text(tab.emoji)
                            .font(.system(size: 22))
                            .scaleEffect(isSelected ? 1.1 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                        
                        // Title
                        Text(tab.title)
                            .font(.system(size: 10, weight: isSelected ? .semibold : .medium, design: .rounded))
                            .foregroundColor(isSelected ? AppColors.primaryOrange : AppColors.textSecondary)
                            .opacity(isSelected ? 1.0 : 0.8)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(
                        // Selection indicator
                        VStack {
                            Spacer()
                            if isSelected {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(AppColors.primaryOrange)
                                    .frame(width: 20, height: 3)
                                    .matchedGeometryEffect(id: "tab_indicator", in: namespace)
                            } else {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(Color.clear)
                                    .frame(width: 20, height: 3)
                            }
                        }
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 4)
        .background(
            // Tab bar background with blur effect
            Rectangle()
                .fill(AppColors.surface)
                .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -2)
        )
        .overlay(
            // Top border
            Rectangle()
                .fill(AppColors.border)
                .frame(height: 0.5),
            alignment: .top
        )
    }
    
    @Namespace private var namespace
}

struct TabItem {
    let title: String
    let emoji: String
}

#Preview {
    AppTabView()
        .environmentObject(ThemeManager.shared)
}

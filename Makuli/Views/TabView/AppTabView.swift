//
//  AppTabView.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//

import SwiftUI

struct AppTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab)
                    .tag(0)
                    .toolbarBackground(.hidden, for: .tabBar)
                PlansView()
                    .tag(1)
                    .toolbarBackground(.hidden, for: .tabBar)
                RecipesView()
                    .tag(2)
                    .toolbarBackground(.hidden, for: .tabBar)
                ProfileView()
                    .tag(3)
                    .toolbarBackground(.hidden, for: .tabBar)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 90)
            }

            GlassTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Glass Tab Bar

struct GlassTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var selectionAnimation
    @Environment(\.colorScheme) private var colorScheme

    private let tabs: [TabItem] = [
        TabItem(title: "Home",    icon: "house",               activeIcon: "house.fill"),
        TabItem(title: "Plans",   icon: "calendar",            activeIcon: "calendar.badge.clock"),
        TabItem(title: "Recipes", icon: "book.closed",         activeIcon: "book.fill"),
        TabItem(title: "Profile", icon: "person.crop.circle",  activeIcon: "person.crop.circle.fill"),
    ]

    var body: some View {
        HStack(spacing: 4) {
            ForEach(tabs.indices, id: \.self) { index in
                tabButton(for: tabs[index], at: index)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    .white.opacity(colorScheme == .dark ? 0.18 : 0.70),
                                    .white.opacity(colorScheme == .dark ? 0.04 : 0.15),
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.40 : 0.14), radius: 24, x: 0, y: 8)
        .shadow(color: .black.opacity(colorScheme == .dark ? 0.20 : 0.06), radius:  6, x: 0, y: 2)
        .padding(.horizontal, 28)
        .padding(.bottom, 20)
    }

    // MARK: Tab Button

    private func tabButton(for tab: TabItem, at index: Int) -> some View {
        let isSelected = selectedTab == index

        return Button {
            guard selectedTab != index else { return }
            withAnimation(.spring(response: 0.38, dampingFraction: 0.72)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 3) {
                Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                    .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? .white : AppColors.textSecondary)
                    .symbolEffect(.bounce.up.byLayer, value: isSelected)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium, design: .rounded))
                    .foregroundStyle(isSelected ? .white : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 9)
            .padding(.horizontal, 6)
            .background {
                if isSelected {
                    Capsule()
                        .fill(AppColors.primaryOrange)
                        .matchedGeometryEffect(id: "tab-indicator", in: selectionAnimation)
                        .overlay(alignment: .top) {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.white.opacity(0.25), .clear],
                                        startPoint: .top,
                                        endPoint: .center
                                    )
                                )
                                .padding(.horizontal, 4)
                                .padding(.top, 2)
                                .frame(maxHeight: 18)
                        }
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Model

private struct TabItem {
    let title: String
    let icon: String
    let activeIcon: String
}

// MARK: - Preview

#Preview {
    AppTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager.shared)
}

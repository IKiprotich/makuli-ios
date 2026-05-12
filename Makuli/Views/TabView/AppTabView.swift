//
//  AppTabView.swift
//  Makuli
//

import SwiftUI

struct AppTabView: View {
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView(selectedTab: $selectedTab).tag(0)
                PlansView().tag(1)
                RecipesView().tag(2)
                ProfileView().tag(3)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))

            CustomTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation

    private let tabs: [TabItem] = [
        TabItem(title: "Home",    icon: "house.fill",          activeIcon: "house.fill"),
        TabItem(title: "Plans",   icon: "calendar",            activeIcon: "calendar.badge.clock"),
        TabItem(title: "Recipes", icon: "book.closed",         activeIcon: "book.fill"),
        TabItem(title: "Profile", icon: "person.crop.circle",  activeIcon: "person.crop.circle.fill"),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                tabButton(for: tabs[index], at: index)
            }
        }
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
        .background(
            AppColors.surface
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: -2)
        )
        .overlay(Divider(), alignment: .top)
    }

    private func tabButton(for tab: TabItem, at index: Int) -> some View {
        let isSelected = selectedTab == index

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedTab = index
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? tab.activeIcon : tab.icon)
                    .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppColors.primaryOrange : AppColors.textSecondary)
                    .symbolEffect(.bounce, value: isSelected)

                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular, design: .rounded))
                    .foregroundColor(isSelected ? AppColors.primaryOrange : AppColors.textSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
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

#Preview {
    AppTabView()
        .environmentObject(AuthViewModel())
        .environmentObject(ThemeManager.shared)
}

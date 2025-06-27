//
//  ProfileView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var authManager: AuthManager
    @State private var mealReminders = false
    @State private var darkMode = false
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    
    private var user: User {
        authManager.user ?? mockUser
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 12) {
                    
                    //header section
                    profileHeader
                    
                    //dietary preferences section
                    dietaryPreferencesSection
                    
                    //subscription section
                    subscriptionSection
                    
                    //app setting section
                    appsettingsSection
                    
                    //support and legal section
                    supportLegalSection
                    
                    //account actions
                    accountActionsSection
                    
                    Spacer(minLength: 100)
                }
                .padding(.horizontal, 16)
                .padding(.top, 10)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle(Text("Profile"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert("Log Out", isPresented: $showingLogoutAlert){
            Button("Cancel", role: .cancel){}
            Button("Log Out",role: .destructive){
                handleLogout()
            }
        } message: {
            Text("Are you sure you want to log out?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAlert){
            Button("Cancel", role: .cancel){}
            Button("Delete", role: .destructive){
                handleDeleteAccount()
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
    }
}


extension ProfileView {
    
    //MARK: Profile header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            
            //profile image
            ZStack {
                Circle()
                    .fill(Color(AppColors.primaryOrange.opacity(0.2)))
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(AppColors.primaryOrange)
            }
            
            //user info
            VStack(spacing: 4) {
                
                Text(user.name)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(user.email)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            //edit profile buton
            Button("Edit Profile"){
                handleEditProfile()
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(12)
            .fontWeight(.medium)
        }
        .padding(.vertical, 20)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Profile \(user.name), \(user.email)")
    }
    
    
    //MARK: Dietary Preferences Section
    private var dietaryPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Dietary Preferemces", icon: "fork.knife")
            
            VStack (spacing: 8) {
                ProfileRowView(title: "Goal", value: "Set Goal")
                ProfileRowView(title: "Dietary Type", value: user.diet)
                ProfileRowView(title: "Budget", value: user.diet)
                
                
                Button ("Update Preferences"){
                    handleUpdatePreferences()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(.systemBackground))
                .foregroundColor(Color(.systemOrange))
                .cornerRadius(12)
                .fontWeight(.medium)
            }
        }
    }
    
    
    
    //MARK: Subscription Section
    private var subscriptionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Subscription", icon: "crown.fill")
            
            
            VStack(spacing: 8) {
                if user.isPremium {
                    ProfileRowView(title: "Plan", value: "Premium")
                    if let renewalDate = user.subscriptionRenewalDate {
                        ProfileRowView(title: "Renewal Date", value: renewalDate)
                    }
                    
                    Button("Manage Subscription"){
                        handleManageSubscription()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(Color(.systemBackground))
                    .foregroundColor(Color(.systemOrange))
                    .cornerRadius(12)
                    .fontWeight(.medium)
                }
                else {
                    ProfileRowView(title: "Plan", value: "Free")
                    
                    Button("Upgrade to Premium"){
                        handleUpgradeToPremium()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.systemOrange))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .fontWeight(.semibold)
                    
                }
            }
           
            
        }
    }
    
    
    
    
    //MARK: App Settings Section
    private var appsettingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("AppSettings", icon: "gearshape.fill")
            
            VStack(spacing: 8) {
                ProfileRowView(title: "Meal Reminder", toggleValue: $mealReminders)
                
                
                HStack {
                    Text("Language")
                        .font(.body)
                        .foregroundColor(.primary)
                    Spacer()
                    Text("English")
                        .font(.body)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                
                ProfileRowView(title: "Dark Mode", toggleValue: $darkMode)
            }
            
        }
    }
    
    
    
    //MARK: Support and Legal Section
    private var supportLegalSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Support & Legal", icon: "questionmark.circle.fill")
            
            
            VStack(spacing: 8) {
                ProfileRowView(icon: "questionmark.circle.fill",
                               iconColor:.blue,
                               title: "Help Centre") {
                    handleHelpCenter()
                }
                
                
                ProfileRowView(icon: "envelope",
                               iconColor:.green,
                               title: "Contact Us") {
                    handleContactUs()
                }
                
                ProfileRowView(icon: "shield",
                               iconColor:.purple,
                               title: "Privacy Policy") {
                    handlePrivacyPolicy()
                }
                
                ProfileRowView(icon: "doc.text",
                               iconColor:.orange,
                               title: "Terms Of Use") {
                    handleTermsOfUse()
                }
            }
        }
    }
    
    
    // MARK: - Account Actions Section
    private var accountActionsSection: some View {
        VStack(spacing: 12) {
            Button("Log Out") {
                showingLogoutAlert = true
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color(.systemBackground))
            .foregroundColor(.red)
            .cornerRadius(12)
            .fontWeight(.medium)
            
            Button("Delete Account") {
                showingDeleteAlert = true
            }
            .font(.subheadline)
            .foregroundColor(.red)
            .padding(.vertical, 8)
        }
    }
    
    // MARK: - Helper Views
    private func sectionHeader(_ title: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(Color(.systemOrange))
                .font(.headline)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 4)
    }
    
    // MARK: - Action Handlers
    private func handleEditProfile() {
        print("Edit Profile tapped")
        // TODO: Navigate to edit profile screen
    }
    
    private func handleUpdatePreferences() {
        print("Update Preferences tapped")
        // TODO: Navigate to preferences screen
    }
    
    private func handleUpgradeToPremium() {
        print("Upgrade to Premium tapped")
        // TODO: Present premium upgrade flow
    }
    
    private func handleManageSubscription() {
        print("Manage Subscription tapped")
        // TODO: Present subscription management
    }
    
    private func handleHelpCenter() {
        print("Help Center tapped")
        // TODO: Navigate to help center
    }
    
    private func handleContactUs() {
        print("Contact Us tapped")
        // TODO: Open contact options (WhatsApp, email, etc.)
        if let whatsappURL = URL(string: "https://wa.me/254728925915") {
            UIApplication.shared.open(whatsappURL)
        }
    }
    
    private func handlePrivacyPolicy() {
        print("Privacy Policy tapped")
        // TODO: Present privacy policy
    }
    
    private func handleTermsOfUse() {
        print("Terms of Use tapped")
        // TODO: Present terms of use
    }
    
    private func handleLogout() {
        print("User logged out")
        Task {
            await authManager.signOut()
        }
    }
    
    private func handleDeleteAccount() {
        print("Account deletion requested")
        // TODO: Implement account deletion
        // API call to delete user data, clear local storage
    }

    
    
    
}




#Preview {
    ProfileView()
}

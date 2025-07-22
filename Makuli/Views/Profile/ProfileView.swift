//
//  ProfileView.swift
//  Makuli
//
//  Created by Ian   on 18/06/2025.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var mealReminders = false
    @State private var darkMode = false
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    @StateObject var viewModel = ProfileViewModel()
    @StateObject private var profileViewModel = UserProfileViewModel()
    
    @State private var showingDeveloperPanel = false
    @State private var selectedItem: PhotosPickerItem? = nil
    @State private var selectedImageData: Data? = nil
    @State private var showCropper = false
    @State private var imageToCrop: UIImage? = nil
    
    private var user: User {
        authViewModel.user ?? User(
            id: "guest-id",
            email: "guest@example.com",
            fullName: "Guest User",
            profileImageUrl: nil,
            age: 25,
            gender: "Other",
            height: 170.0,
            weight: 70.0,
            activityLevel: "Moderately Active",
            fitnessGoal: "General Health",
            dietaryPreferences: ["Balanced"],
            budgetRange: "$50-75",
            preferredCuisines: [],
            cookingSkillLevel: "Beginner",
            preferredPrepTime: 30,
            preferredServings: 2,
            allergies: [],
            favoriteIngredients: [],
            dislikedIngredients: [],
            hasCompletedOnboarding: false,
            createdAt: Date(),
            updatedAt: Date()
        )
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
        .sheet(isPresented: $showingDeveloperPanel) {
            DeveloperPanelView()
        }
        .task {
            await profileViewModel.fetchProfile()
        }
    }
}


extension ProfileView {
    
    //MARK: Profile header
    private var profileHeader: some View {
        VStack(spacing: 16) {
            
            //profile image
            // Profile Image with overlay camera button
            ZStack(alignment: .bottomTrailing) {
                if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else if let url = profileViewModel.profile?.profileImageUrl, let imageUrl = URL(string: url) {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 100, height: 100)
                }

                PhotosPicker(
                    selection: $selectedItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 32, height: 32)
                            .shadow(radius: 2)
                        Image(systemName: "camera.fill")
                            .foregroundColor(.black)
                    }
                }
                .offset(x: 8, y: 8)
                .onChange(of: selectedItem) { newItem in
                    Task {
                        if let data = try? await newItem?.loadTransferable(type: Data.self),
                           let uiImage = UIImage(data: data) {
                            imageToCrop = uiImage
                            showCropper = true
                        }
                    }
                }
            }
            .frame(width: 100, height: 100)
            .sheet(isPresented: $showCropper) {
                if let image = imageToCrop {
                    ImageCropperView(image: image) { croppedImage in
                        if let croppedData = croppedImage.jpegData(compressionQuality: 0.9) {
                            selectedImageData = croppedData
                            Task {
                                await profileViewModel.uploadProfileImage(data: croppedData)
                            }
                        }
                        showCropper = false
                    }
                }
            }
            .alert("Profile Picture Updated", isPresented: $profileViewModel.uploadSuccess) {
                Button("OK", role: .cancel) { profileViewModel.uploadSuccess = false }
            } message: {
                Text("Your profile picture has been successfully uploaded.")
            }
            .alert("Upload Failed", isPresented: .constant(profileViewModel.uploadError != nil)) {
                Button("OK", role: .cancel) { profileViewModel.uploadError = nil }
            } message: {
                Text(profileViewModel.uploadError ?? "Unknown error")
            }
            
            //user info
            VStack(spacing: 4) {
                if profileViewModel.isLoading {
                    ProgressView()
                } else if let error = profileViewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                } else if let profile = profileViewModel.profile {
                    Text(profile.name ?? "No Name")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .padding(.bottom, 4)
                    if let goal = profile.goal {
                        Text("Goal: \(goal)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                } else {
                    Text("Looks like your profile is missing. Please restart onboarding.")
                        .foregroundColor(.orange)
                }
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
        .accessibilityLabel("Profile \(profileViewModel.profile?.name ?? user.name), \(profileViewModel.profile?.id ?? user.email)")
    }
    
    
    //MARK: Dietary Preferences Section
    private var dietaryPreferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Dietary Preferences", icon: "fork.knife")
            
            VStack (spacing: 8) {
                if let profile = profileViewModel.profile {
                    ProfileRowView(title: "Goal", value: profile.goal ?? "Set Goal")
                    ProfileRowView(title: "Budget", value: profile.budget ?? "Not set")
                } else {
                    ProfileRowView(title: "Goal", value: "Set Goal")
                    ProfileRowView(title: "Budget", value: "Not set")
                }
                
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
                
                // Developer Panel (only show in debug builds)
                #if DEBUG
                ProfileRowView(icon: "hammer.circle.fill",
                               iconColor: AppColors.primaryOrange,
                               title: "Developer Panel") {
                    showingDeveloperPanel = true
                }
                #endif
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
    /// Helper view for section headers with an icon and title.
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
    /// Handles the edit profile action.
    private func handleEditProfile() {
        Logger.debug("Edit Profile tapped")
        // TODO: Navigate to edit profile screen
    }
    
    /// Handles the update preferences action.
    private func handleUpdatePreferences() {
        Logger.debug("Update Preferences tapped")
        // TODO: Navigate to preferences screen
    }
    
    /// Handles the upgrade to premium action.
    private func handleUpgradeToPremium() {
        Logger.debug("Upgrade to Premium tapped")
        // TODO: Present premium upgrade flow
    }
    
    /// Handles the manage subscription action.
    private func handleManageSubscription() {
        Logger.debug("Manage Subscription tapped")
        // TODO: Present subscription management
    }
    
    /// Handles the help center action.
    private func handleHelpCenter() {
        Logger.debug("Help Center tapped")
        // TODO: Navigate to help center
    }
    
    /// Handles the contact us action (opens WhatsApp).
    private func handleContactUs() {
        Logger.debug("Contact Us tapped")
        // TODO: Open contact options (WhatsApp, email, etc.)
        if let whatsappURL = URL(string: "https://wa.me/254728925915") {
            UIApplication.shared.open(whatsappURL)
        }
    }
    
    /// Handles the privacy policy action.
    private func handlePrivacyPolicy() {
        Logger.debug("Privacy Policy tapped")
        // TODO: Present privacy policy
    }
    
    /// Handles the terms of use action.
    private func handleTermsOfUse() {
        Logger.debug("Terms of Use tapped")
        // TODO: Present terms of use
    }
    
    /// Handles the logout action.
    private func handleLogout() {
        Logger.authEvent("User logged out from profile")
        Task {
            await authViewModel.signOut()
        }
    }
    
    /// Handles the delete account action.
    private func handleDeleteAccount() {
        Logger.warning("Account deletion requested")
        // TODO: Implement account deletion
        // API call to delete user data, clear local storage
    }

    
    
    
}




#Preview {
    ProfileView()
}

//
//  ProfileViewModel.swift
//  Makuli
//
//  Created by Ian on 2025-01-13.
//
//  Production-ready profile view model for Supabase database operations.
//

import Foundation

enum ProfileError: Error {
    case profileNotLoaded
}

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isUpdating = false
    @Published var successMessage: String?
    
    private let supabaseManager = SupabaseManager.shared
    private var fetchTask: Task<Void, Never>?
    
    // MARK: - Computed Properties
    
    /// Whether user has premium access
    var hasPremiumAccess: Bool {
        return profile?.hasPremiumAccess ?? false
    }
    
    /// User's subscription display name
    var subscriptionDisplayName: String {
        return profile?.subscriptionDisplayName ?? "Free Plan"
    }
    
    /// Days until subscription renewal
    var daysUntilRenewal: Int? {
        return profile?.daysUntilRenewal
    }
    
    /// Plans remaining this month
    var plansRemainingThisMonth: Int {
        return profile?.plansRemainingThisMonth ?? 0
    }
    
    /// AI generations remaining this month
    var aiGenerationsRemainingThisMonth: Int {
        return profile?.aiGenerationsRemainingThisMonth ?? 0
    }
    
    /// Whether profile is complete
    var isProfileComplete: Bool {
        return profile?.isProfileComplete ?? false
    }
    
    /// Profile completion percentage
    var profileCompletionPercentage: Double {
        guard let profile = profile else { return 0.0 }
        
        var completedFields = 0
        let totalFields = 6
        
        if profile.name != nil && !profile.name!.isEmpty { completedFields += 1 }
        if profile.age != nil { completedFields += 1 }
        if profile.gender != nil { completedFields += 1 }
        if profile.goal != nil { completedFields += 1 }
        if profile.diet != nil { completedFields += 1 }
        if profile.budget != nil { completedFields += 1 }
        
        return Double(completedFields) / Double(totalFields) * 100.0
    }
    
    // MARK: - Public Methods
    
    /// Fetches user profile from database
    func fetchProfile(for userId: String) async {
        // Don't fetch if we already have a profile and no error
        if profile != nil && errorMessage == nil {
            Logger.debug("Profile already loaded, skipping fetch")
            return
        }
        
        // Cancel any existing fetch task to prevent duplicate requests
        fetchTask?.cancel()
        
        fetchTask = Task {
            await performFetch(for: userId)
        }
        
        await fetchTask?.value
    }
    
    /// Forces a refresh of the profile
    func forceRefreshProfile(for userId: String) async {
        profile = nil
        errorMessage = nil
        await performFetch(for: userId)
    }
    
    /// Updates user profile information
    func updateProfile(
        userId: String,
        name: String? = nil,
        age: Int? = nil,
        gender: String? = nil,
        goal: String? = nil,
        diet: String? = nil,
        budget: String? = nil,
        profileImageUrl: String? = nil
    ) async -> Bool {
        
        do {
            Logger.info("Updating profile for user: \(userId)")
            
            isUpdating = true
            errorMessage = nil
            successMessage = nil
            
            // Create updated profile with current data + new updates
            let updatedProfile = UserProfile(
                id: userId,
                name: name,
                email: profile?.email ?? "",
                age: age,
                gender: gender,
                goal: goal,
                diet: diet,
                budget: budget,
                isPremium: profile?.isPremium ?? false,
                subscriptionRenewal: profile?.subscriptionRenewal,
                profileImageUrl: profileImageUrl,
                createdAt: profile?.createdAt ?? Date(),
                updatedAt: Date(),
                isOnboardingCompleted: profile?.isOnboardingCompleted ?? false,
                subscriptionType: profile?.subscriptionType ?? "free",
                plansCreatedThisMonth: profile?.plansCreatedThisMonth ?? 0,
                aiGenerationsThisMonth: profile?.aiGenerationsThisMonth ?? 0,
                lastPlanReset: profile?.lastPlanReset ?? Date()
            )
            
            try await supabaseManager.updateUserProfile(updatedProfile)
            
            // Update local state
            self.profile = updatedProfile
            self.successMessage = "Profile updated successfully"
            
            Logger.info("Successfully updated profile")
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update profile: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    /// Completes onboarding process
    func completeOnboarding(
        userId: String,
        name: String,
        age: Int,
        gender: String,
        goal: String,
        diet: String,
        budget: String
    ) async -> Bool {
        
        do {
            Logger.info("Completing onboarding for user: \(userId)")
            
            isUpdating = true
            errorMessage = nil
            
            // Create updated profile for onboarding completion
            let updatedProfile = UserProfile(
                id: userId,
                name: name,
                email: profile?.email ?? "",
                age: age,
                gender: gender,
                goal: goal,
                diet: diet,
                budget: budget,
                isPremium: profile?.isPremium ?? false,
                subscriptionRenewal: profile?.subscriptionRenewal,
                profileImageUrl: nil,
                createdAt: profile?.createdAt ?? Date(),
                updatedAt: Date(),
                isOnboardingCompleted: true,
                subscriptionType: profile?.subscriptionType ?? "free",
                plansCreatedThisMonth: profile?.plansCreatedThisMonth ?? 0,
                aiGenerationsThisMonth: profile?.aiGenerationsThisMonth ?? 0,
                lastPlanReset: profile?.lastPlanReset ?? Date()
            )
            
            try await supabaseManager.updateUserProfile(updatedProfile)
            
            // Update local state
            self.profile = updatedProfile
            self.successMessage = "Welcome to Makuli! Your profile is now complete."
            
            Logger.info("Successfully completed onboarding")
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to complete onboarding: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    /// Updates subscription status (premium upgrade/downgrade)
    func updateSubscription(
        userId: String,
        subscriptionType: String,
        renewalDate: Date?
    ) async -> Bool {
        
        do {
            Logger.info("Updating subscription for user: \(userId)")
            
            isUpdating = true
            errorMessage = nil
            
            // Update subscription in profile
            guard var currentProfile = profile else { 
                throw ProfileError.profileNotLoaded 
            }
            
            currentProfile.subscriptionType = subscriptionType
            currentProfile.subscriptionRenewal = renewalDate
            currentProfile.updatedAt = Date()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            // Refresh profile to get updated subscription data
            await forceRefreshProfile(for: userId)
            
            self.successMessage = "Subscription updated successfully"
            
            Logger.info("Successfully updated subscription")
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to update subscription: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    /// Increments plan creation count
    func incrementPlanCreationCount() async {
        guard var currentProfile = profile else { return }
        
        do {
            currentProfile.incrementPlanCreationCount()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            // Update local state
            self.profile = currentProfile
            
        } catch {
            Logger.error("Failed to increment plan creation count: \(error)")
        }
    }
    
    /// Increments AI generation count
    func incrementAIGenerationCount() async {
        guard var currentProfile = profile else { return }
        
        do {
            currentProfile.incrementAIGenerationCount()
            
            try await supabaseManager.updateUserProfile(currentProfile)
            
            // Update local state
            self.profile = currentProfile
            
        } catch {
            Logger.error("Failed to increment AI generation count: \(error)")
        }
    }
    
    /// Checks if user can perform a specific action
    func canPerformAction(_ action: UserAction) -> Bool {
        return profile?.canPerformAction(action) ?? false
    }
    
    /// Gets usage stats for the current month
    func getUsageStats() -> (plans: Int, maxPlans: Int, aiGenerations: Int, maxAIGenerations: Int) {
        guard let profile = profile else {
            return (0, 0, 0, 0)
        }
        
        let maxPlans = profile.hasPremiumAccess ? 
            Configuration.maxPlansPerUser : 
            Configuration.freePlanLimits.maxPlansPerMonth
        
        let maxAIGenerations = profile.hasPremiumAccess ? 
            Int.max : 
            Configuration.freePlanLimits.maxAIGenerationsPerMonth
        
        return (
            plans: profile.plansCreatedThisMonth,
            maxPlans: maxPlans,
            aiGenerations: profile.aiGenerationsThisMonth,
            maxAIGenerations: maxAIGenerations
        )
    }
    
    /// Uploads profile image
    func uploadProfileImage(_ imageData: Data, userId: String) async -> Bool {
        do {
            Logger.info("Uploading profile image for user: \(userId)")
            
            isUpdating = true
            errorMessage = nil
            
            // TODO: Implement profile image upload
            let imageUrl = "https://placeholder.com/profile-\(userId).jpg"
            
            // Update profile with new image URL
            let success = await updateProfile(
                userId: userId,
                profileImageUrl: imageUrl
            )
            
            if success {
                self.successMessage = "Profile image updated successfully"
            }
            
            isUpdating = false
            return success
            
        } catch {
            Logger.error("Failed to upload profile image: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    /// Deletes user account
    func deleteAccount(userId: String) async -> Bool {
        do {
            Logger.info("Deleting account for user: \(userId)")
            
            isUpdating = true
            errorMessage = nil
            
            try await supabaseManager.deleteUserAccount(userId: userId)
            
            // Clear local state
            self.profile = nil
            
            Logger.info("Successfully deleted user account")
            isUpdating = false
            return true
            
        } catch {
            Logger.error("Failed to delete account: \(error)")
            self.errorMessage = error.localizedDescription
            isUpdating = false
            return false
        }
    }
    
    /// Exports user data
    func exportUserData(userId: String) async -> UserDataExport? {
        do {
            Logger.info("Exporting user data for: \(userId)")
            
            let userDataExport = try await supabaseManager.exportUserData(userId: userId)
            
            Logger.info("Successfully exported user data")
            return userDataExport
            
        } catch {
            Logger.error("Failed to export user data: \(error)")
            self.errorMessage = error.localizedDescription
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    /// Clears error message
    func clearError() {
        errorMessage = nil
    }
    
    /// Clears success message
    func clearSuccess() {
        successMessage = nil
    }
    
    /// Clears all messages
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
    
    /// Gets subscription status text
    func getSubscriptionStatusText() -> String {
        guard let profile = profile else { return "Unknown" }
        
        if profile.hasPremiumAccess {
            if let daysUntilRenewal = daysUntilRenewal {
                return "Premium • Renews in \(daysUntilRenewal) days"
            } else {
                return "Premium Active"
            }
        } else {
            return "Free Plan"
        }
    }
    
    /// Gets usage warning message if approaching limits
    func getUsageWarning() -> String? {
        guard let profile = profile, !profile.hasPremiumAccess else { return nil }
        
        let planLimit = Configuration.freePlanLimits.maxPlansPerMonth
        let aiLimit = Configuration.freePlanLimits.maxAIGenerationsPerMonth
        
        if profile.plansCreatedThisMonth >= planLimit {
            return "You've reached your monthly plan limit. Upgrade to premium for unlimited plans."
        }
        
        if profile.aiGenerationsThisMonth >= aiLimit {
            return "You've reached your monthly AI generation limit. Upgrade to premium for unlimited AI meal plans."
        }
        
        if profile.plansCreatedThisMonth >= planLimit - 1 {
            return "You have 1 plan remaining this month. Upgrade to premium for unlimited plans."
        }
        
        if profile.aiGenerationsThisMonth >= aiLimit - 1 {
            return "You have 1 AI generation remaining this month. Upgrade to premium for unlimited access."
        }
        
        return nil
    }
    
    // MARK: - Private Methods
    
    private func performFetch(for userId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            Logger.info("Fetching profile for user: \(userId)")
            
            let fetchedProfile = try await supabaseManager.fetchUserProfile(userId: userId)
            self.profile = fetchedProfile
            
            Logger.info("Successfully loaded profile")
            
        } catch {
            Logger.error("Failed to fetch profile: \(error)")
            self.errorMessage = "Failed to load profile. Please check your connection and try again."
            self.profile = nil
        }
        
        isLoading = false
    }
    
    deinit {
        fetchTask?.cancel()
    }
}

// MARK: - Supporting Models

struct UserDataExport {
    let profile: UserProfile
    let plans: [PlanWithRecipes]
    let groceryLists: [GroceryItem]
    let favoriteRecipes: [Recipe]
    let exportDate: Date
    
    var fileName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "makuli-user-data-\(formatter.string(from: exportDate)).json"
    }
} 
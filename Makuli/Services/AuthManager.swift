//
//  AuthManager.swift
//  Makuli
//
//  Created by Ian on 2025-06-27.
//

import SwiftUI
import Supabase
import GoogleSignIn

@MainActor
class AuthManager: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client
    
    init() {
        Task { await getCurrentUser() }
    }

    func getCurrentUser() async {
        do {
            let session = try await supabase.auth.session
            await loadUserProfile(supabaseUser: session.user)
        } catch {
            Logger.info("No current user session found")
            self.user = nil
        }
    }
    
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            let _ = try await createUserProfileIfNotExists(response.user)
            await loadUserProfile(supabaseUser: response.user)
            
            Logger.authEvent("New user created via email signup")
        } catch {
            Logger.error("Sign up failed", error: error)
            errorMessage = handleAuthError(error)
        }
        
        isLoading = false
    }
    
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            let isNewUser = try await createUserProfileIfNotExists(response.user)
            
            await loadUserProfile(supabaseUser: response.user)
            
            if isNewUser {
                Logger.authEvent("New user created via email sign-in")
            } else {
                Logger.authEvent("Existing user signed in via email")
            }
        } catch {
            errorMessage = handleAuthError(error)
        }
        
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to find root view controller"
            isLoading = false
            return
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                errorMessage = "Failed to get ID token"
                isLoading = false
                return
            }
            
            let accessToken = result.user.accessToken.tokenString
            
            let response = try await supabase.auth.signInWithIdToken(
                credentials: OpenIDConnectCredentials(
                    provider: .google,
                    idToken: idToken,
                    accessToken: accessToken
                )
            )
            
            let isNewUser = try await createUserProfileIfNotExists(response.user)
            
            await loadUserProfile(supabaseUser: response.user)
            
            if isNewUser {
                Logger.authEvent("New user created via Google Sign-In")
            } else {
                Logger.authEvent("Existing user signed in via Google")
            }
        } catch {
            errorMessage = handleAuthError(error)
        }
        
        isLoading = false
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            self.user = nil
            Logger.authEvent("User logged out")
        } catch {
            Logger.error("Sign out failed", error: error)
            errorMessage = handleAuthError(error)
        }
    }
    
    func completeOnboarding(age: Int, gender: String, diet: String, budget: String, goal: String) async {
        guard let currentUser = user else { 
            Logger.error("Cannot complete onboarding - no current user")
            return 
        }
        
        Logger.info("Starting onboarding completion process")
        
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id.uuidString.lowercased()
            
            Logger.debug("Using upsert approach for user ID: \(userId)")
            
            let existingProfiles: [ProfileTimestamp] = try await supabase
                .from("profiles")
                .select("created_at")
                .eq("id", value: userId)
                .execute()
                .value
            
            let createdAt: Date
            if let existingProfile = existingProfiles.first,
               let existingCreatedAt = ISO8601DateFormatter().date(from: existingProfile.createdAt) {
                createdAt = existingCreatedAt
                Logger.debug("Preserving existing createdAt: \(existingProfile.createdAt)")
            } else {
                createdAt = Date()
                Logger.debug("Using new createdAt for new profile")
            }
            
            let profileData = ProfileData(
                id: userId,
                name: currentUser.name,
                email: currentUser.email,
                age: age,
                gender: gender,
                goal: goal,
                diet: diet,
                budget: budget,
                isPremium: currentUser.isPremium,
                subscriptionRenewal: currentUser.subscriptionRenewalDate,
                profileImageURL: currentUser.profileImageUrl,
                createdAt: createdAt,
                isOnboardingCompleted: true
            )
            
            let response = try await supabase
                .from("profiles")
                .upsert(profileData)
                .execute()
            
            Logger.success("Profile upserted successfully")
            
            let verifyResponse: [DatabaseProfile] = try await supabase
                .from("profiles")
                .select("*")
                .eq("id", value: userId)
                .execute()
                .value
            
            if let profile = verifyResponse.first {
                Logger.debug("Verified profile: isOnboardingCompleted=\(profile.isOnboardingCompleted)")
                if !profile.isOnboardingCompleted {
                    Logger.warning("Upsert completed but onboarding status is still false")
                }
            } else {
                Logger.warning("Profile not found after upsert")
            }
            
            self.user = User(
                id: userId,
                email: currentUser.email,
                fullName: currentUser.name,
                profileImageUrl: currentUser.profileImageUrl,
                age: age,
                gender: gender,
                height: 170.0,
                weight: 70.0,
                activityLevel: "moderately active",
                fitnessGoal: goal,
                dietaryPreferences: [diet],
                budgetRange: budget,
                preferredCuisines: ["american", "italian"],
                cookingSkillLevel: "beginner",
                preferredPrepTime: 30,
                preferredServings: 2,
                allergies: [],
                favoriteIngredients: [],
                dislikedIngredients: [],
                hasCompletedOnboarding: true,
                createdAt: Date(),
                updatedAt: Date()
            )
            
            Logger.success("Local user object updated")
            Logger.authEvent("Onboarding completed successfully")
            
            try await Task.sleep(nanoseconds: 500_000_000)
            
            await verifyOnboardingCompletion(userId: userId)
            
        } catch {
            Logger.error("Failed to complete onboarding", error: error)
            errorMessage = "Failed to complete onboarding: \(error.localizedDescription)"
        }
    }
    
    private func verifyOnboardingCompletion(userId: String) async {
        do {
            Logger.debug("Verifying onboarding completion in database")
            
            let response: [DatabaseProfile] = try await supabase
                .from("profiles")
                .select("*")
                .eq("id", value: userId)
                .execute()
                .value
            
            if let profile = response.first {
                if !profile.isOnboardingCompleted {
                    Logger.warning("Database verification shows onboarding not completed")
                } else {
                    Logger.success("Database confirmation: Onboarding marked as completed")
                }
            } else {
                Logger.warning("Could not verify - profile not found in database")
            }
        } catch {
            Logger.warning("Verification failed")
        }
    }
    
    private func loadUserProfile(supabaseUser: Supabase.User) async {
        do {
            let response: [DatabaseProfile] = try await supabase
                .from("profiles")
                .select("*")
                .eq("id", value: supabaseUser.id.uuidString.lowercased())
                .execute()
                .value
            
            if let profile = response.first {
                self.user = User(
                    id: profile.id,
                    email: profile.email,
                    fullName: profile.name,
                    profileImageUrl: profile.profileImageURL,
                    age: profile.age,
                    gender: profile.gender,
                    height: 170.0,
                    weight: 70.0,
                    activityLevel: "moderately active",
                    fitnessGoal: profile.goal,
                    dietaryPreferences: [profile.diet],
                    budgetRange: profile.budget,
                    preferredCuisines: ["american", "italian"],
                    cookingSkillLevel: "beginner",
                    preferredPrepTime: 30,
                    preferredServings: 2,
                    allergies: [],
                    favoriteIngredients: [],
                    dislikedIngredients: [],
                    hasCompletedOnboarding: profile.isOnboardingCompleted,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                
                if profile.isOnboardingCompleted {
                    Logger.authEvent("Existing user signed in - onboarding completed")
                } else {
                    Logger.authEvent("Existing user signed in - onboarding required")
                }
            } else {
                self.user = convertToCustomUser(supabaseUser)
                Logger.warning("No profile found in database - using fallback user")
            }
        } catch {
            Logger.error("Failed to load user profile", error: error)
            self.user = convertToCustomUser(supabaseUser)
        }
    }
    
    func checkOnboardingStatus() -> String {
        guard let user = user else { return "No user logged in" }
        return "Onboarding completed: \(user.isOnboardingCompleted)"
    }
    
    private func convertToCustomUser(_ supabaseUser: Supabase.User) -> User {
        let name = anyJSONToString(supabaseUser.userMetadata["name"]) ?? supabaseUser.email ?? ""
        let profileImageURL = anyJSONToString(supabaseUser.userMetadata["avatar_url"]) ?? ""
        return User(
            id: supabaseUser.id.uuidString.lowercased(),
            email: supabaseUser.email ?? "",
            fullName: name,
            profileImageUrl: profileImageURL,
            age: 0, 
            gender: "prefer_not_to_say",
            height: 170.0,
            weight: 70.0,
            activityLevel: "moderately active",
            fitnessGoal: "maintain_weight",
            dietaryPreferences: ["none"],
            budgetRange: "medium",
            preferredCuisines: ["american", "italian"],
            cookingSkillLevel: "beginner",
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
    
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as? AuthError {
            switch authError {
            case .api(_, let apiError, _, _):
                return String(describing: apiError)
            default:
                return "Authentication failed: \(authError.localizedDescription)"
            }
        }
        
        let errorString = error.localizedDescription
        if errorString.contains("profiles") || errorString.contains("database") {
            return "Database error saving new user"
        }
        
        return error.localizedDescription
    }
    
    private func createUserProfileIfNotExists(_ supabaseUser: Supabase.User) async throws -> Bool {
        do {
            let existingProfile: [DatabaseProfile] = try await supabase
                .from("profiles")
                .select("*")
                .eq("id", value: supabaseUser.id.uuidString.lowercased())
                .execute()
                .value
            
            if !existingProfile.isEmpty {
                Logger.debug("User profile already exists - preserving onboarding status")
                return false
            }
        } catch {
            Logger.warning("Error checking existing profile")
        }
        
        do {
            let profileData = ProfileData(
                id: supabaseUser.id.uuidString.lowercased(),
                name: anyJSONToString(supabaseUser.userMetadata["name"]) ?? supabaseUser.email ?? "",
                email: supabaseUser.email ?? "",
                age: 0,
                gender: "prefer_not_to_say",
                goal: "maintain_weight",
                diet: "none",
                budget: "medium",
                isPremium: false,
                subscriptionRenewal: nil,
                profileImageURL: anyJSONToString(supabaseUser.userMetadata["avatar_url"]),
                createdAt: Date(),
                isOnboardingCompleted: false
            )
            
            try await supabase
                .from("profiles")
                .insert(profileData)
                .execute()
            
            Logger.authEvent("New user profile created with onboarding required")
            return true
        } catch {
            Logger.error("Failed to insert profile", error: error)
            throw error
        }
    }
    
    // MARK: - Profile Data Structures

    private struct ProfileTimestamp: Decodable {
        let createdAt: String
        enum CodingKeys: String, CodingKey {
            case createdAt = "created_at"
        }
    }

    private struct DatabaseProfile: Decodable {
        let id: String
        let name: String
        let email: String
        let age: Int
        let gender: String
        let goal: String
        let diet: String
        let budget: String
        let isPremium: Bool
        let subscriptionRenewal: String?
        let profileImageURL: String?
        let createdAt: String
        let isOnboardingCompleted: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case email
            case age
            case gender
            case goal
            case diet
            case budget
            case isPremium = "is_premium"
            case subscriptionRenewal = "subscription_renewal"
            case profileImageURL = "profile_image_url"
            case createdAt = "created_at"
            case isOnboardingCompleted = "is_onboarding_completed"
        }
    }
    
    private struct ProfileData: Encodable {
        let id: String
        let name: String
        let email: String
        let age: Int
        let gender: String
        let goal: String
        let diet: String
        let budget: String
        let isPremium: Bool
        let subscriptionRenewal: String?
        let profileImageURL: String?
        let createdAt: Date
        let isOnboardingCompleted: Bool
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case email
            case age
            case gender
            case goal
            case diet
            case budget
            case isPremium = "is_premium"
            case subscriptionRenewal = "subscription_renewal"
            case profileImageURL = "profile_image_url"
            case createdAt = "created_at"
            case isOnboardingCompleted = "is_onboarding_completed"
        }
    }
    
    private struct ProfileUpdateData: Encodable {
        let age: Int
        let gender: String
        let diet: String
        let budget: String
        let goal: String
        let isOnboardingCompleted: Bool
        
        enum CodingKeys: String, CodingKey {
            case age
            case gender
            case diet
            case budget
            case goal
            case isOnboardingCompleted = "is_onboarding_completed"
        }
    }
    
    private func anyJSONToString(_ value: Any?) -> String? {
        guard let anyJSON = value as? AnyJSON else { return nil }
        if case let .string(str) = anyJSON { return str }
        return nil
    }
    
    func refreshUserProfile() async {
        do {
            let session = try await supabase.auth.session
            await loadUserProfile(supabaseUser: session.user)
            Logger.debug("User profile refreshed successfully")
        } catch {
            Logger.warning("Failed to refresh user profile")
        }
    }
}


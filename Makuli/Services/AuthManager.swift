//
//  AuthManager.swift
//  Makuli
//
//  Created by Ian   on 27/06/2025.
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
        // checks for existing session
        Task {
            await getCurrentUser()
        }
    }
    
    //MARK: Gets the current user
    func getCurrentUser() async {
        do {
            let session = try await supabase.auth.session
            // Loads complete user profile from database
            await loadUserProfile(supabaseUser: session.user)
        } catch {
            Logger.info("No current user session found")
            self.user = nil
        }
    }
    
    //MARK: Sign Up
    func signUp(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password
            )
            
            // Create user profile in the database (this is always a new user)
            let _ = try await createUserProfileIfNotExists(response.user)
            // Load complete user profile from database
            await loadUserProfile(supabaseUser: response.user)
            
            Logger.authEvent("New user created via email signup")
        } catch {
            Logger.error("Sign up failed", error: error)
            errorMessage = handleAuthError(error)
        }
        
        isLoading = false
    }
    
    //MARK: Sign In Function
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            // Check if this is a new user or existing user by checking if profile exists
            let isNewUser = try await createUserProfileIfNotExists(response.user)
            
            // Load complete user profile from database
            await loadUserProfile(supabaseUser: response.user)
            
            // Log authentication event
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
    
    //MARK: SiGN in with Google
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
            
            // Check if this is a new user or existing user by checking if profile exists
            let isNewUser = try await createUserProfileIfNotExists(response.user)
            
            // Load complete user profile from database
            await loadUserProfile(supabaseUser: response.user)
            
            // Log authentication event
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
    
    //MARK: Sign out
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
    
    //MARK: Complete onboarding
    func completeOnboarding(age: Int, gender: String, diet: String, budget: String) async {
        guard let currentUser = user else { 
            Logger.error("Cannot complete onboarding - no current user")
            return 
        }
        
        Logger.info("Starting onboarding completion process")
        
        do {
            // Get current user ID
            let session = try await supabase.auth.session
            let userId = session.user.id.uuidString.lowercased()
            
            // Ensure profile exists before attempting update (for existing sessions)
            Logger.debug("Ensuring profile exists before update")
            let wasNewUser = try await createUserProfileIfNotExists(session.user)
            if wasNewUser {
                Logger.debug("Missing profile created for existing session")
            } else {
                Logger.debug("Profile already exists")
            }
            
            // Create update data struct
            let updateData = ProfileUpdateData(
                age: age,
                gender: gender,
                diet: diet,
                budget: budget,
                isOnboardingCompleted: true
            )
            
            Logger.debug("Updating database profile")
            
            // Update profile in database
            let response = try await supabase
                .from("profiles")
                .update(updateData)
                .eq("id", value: userId)
                .execute()
            
            let responseCount = response.count ?? 0
            
            if responseCount == 0 {
                Logger.warning("Database update returned 0 rows affected")
            } else {
                Logger.success("Profile updated successfully")
            }
            
            // Update local user object
            self.user = User(
                name: currentUser.name,
                email: currentUser.email,
                age: age,
                gender: gender,
                diet: diet,
                budget: budget,
                isPremium: currentUser.isPremium,
                subscriptionRenewalDate: currentUser.subscriptionRenewalDate,
                profileImageURL: currentUser.profileImageURL,
                isOnboardingCompleted: true
            )
            
            Logger.success("Local user object updated")
            Logger.authEvent("Onboarding completed successfully")
            
            // Add a small delay to ensure database consistency
            try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            
            // Verify the update by reading back from database
            await verifyOnboardingCompletion(userId: userId)
            
        } catch {
            Logger.error("Failed to complete onboarding", error: error)
            errorMessage = "Failed to complete onboarding: \(error.localizedDescription)"
        }
    }
    
    //MARK: Verify onboarding completion
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
    
    //MARK: Load user profile from database
    private func loadUserProfile(supabaseUser: Supabase.User) async {
        do {
            let response: [DatabaseProfile] = try await supabase
                .from("profiles")
                .select("*")
                .eq("id", value: supabaseUser.id.uuidString.lowercased())
                .execute()
                .value
            
            if let profile = response.first {
                // Create User with database data
                self.user = User(
                    name: profile.name,
                    email: profile.email,
                    age: profile.age,
                    gender: profile.gender,
                    diet: profile.diet,
                    budget: profile.budget,
                    isPremium: profile.isPremium,
                    subscriptionRenewalDate: profile.subscriptionRenewal,
                    profileImageURL: profile.profileImageURL,
                    isOnboardingCompleted: profile.isOnboardingCompleted
                )
                
                // Log authentication result
                if profile.isOnboardingCompleted {
                    Logger.authEvent("Existing user signed in - onboarding completed")
                } else {
                    Logger.authEvent("Existing user signed in - onboarding required")
                }
            } else {
                // Fallback to basic user if profile not found
                self.user = convertToCustomUser(supabaseUser)
                Logger.warning("No profile found in database - using fallback user")
            }
        } catch {
            Logger.error("Failed to load user profile", error: error)
            // Fallback to basic user
            self.user = convertToCustomUser(supabaseUser)
        }
    }
    
    //MARK: Check if user needs onboarding (utility method for debugging)
    func checkOnboardingStatus() -> String {
        guard let user = user else { return "No user logged in" }
        return "Onboarding completed: \(user.isOnboardingCompleted)"
    }
    
    //MARK: Convert to user after onboarding
    private func convertToCustomUser(_ supabaseUser: Supabase.User) -> User {
        let name = anyJSONToString(supabaseUser.userMetadata["name"]) ?? supabaseUser.email ?? ""
        let profileImageURL = anyJSONToString(supabaseUser.userMetadata["avatar_url"]) ?? ""
        return User(
            name: name,
            email: supabaseUser.email ?? "",
            age: 0, 
            gender: "",
            diet: "",
            budget: "",
            isPremium: false,
            subscriptionRenewalDate: nil,
            profileImageURL: profileImageURL,
            isOnboardingCompleted: false
        )
    }
    
    //MARK: Handle authentication errors
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as? AuthError {
            switch authError {
            case .api(_, let apiError, _, _):
                return String(describing: apiError)
            default:
                return "Authentication failed: \(authError.localizedDescription)"
            }
        }
        
        // Check for specific database errors
        let errorString = error.localizedDescription
        if errorString.contains("profiles") || errorString.contains("database") {
            return "Database error saving new user"
        }
        
        return error.localizedDescription
    }
    
    //MARK: Create user profile if not exists
    private func createUserProfileIfNotExists(_ supabaseUser: Supabase.User) async throws -> Bool {
        // First, check if profile already exists
        do {
            let existingProfile: [DatabaseProfile] = try await supabase
                .from("profiles")
                .select("*")
                .eq("id", value: supabaseUser.id.uuidString.lowercased())
                .execute()
                .value
            
            if !existingProfile.isEmpty {
                Logger.debug("User profile already exists - preserving onboarding status")
                return false // Existing user
            }
        } catch {
            Logger.warning("Error checking existing profile")
            // Continue to create profile if check failed
        }
        
        // Create new profile (this is a new user)
        do {
            let profileData = ProfileData(
                id: supabaseUser.id.uuidString.lowercased(),
                name: anyJSONToString(supabaseUser.userMetadata["name"]) ?? supabaseUser.email ?? "",
                email: supabaseUser.email ?? "",
                age: 0,
                gender: "",
                diet: "",
                budget: "",
                isPremium: false,
                subscriptionRenewal: nil,
                profileImageURL: anyJSONToString(supabaseUser.userMetadata["avatar_url"]),
                createdAt: Date(),
                isOnboardingCompleted: false // New users always need onboarding
            )
            
            try await supabase
                .from("profiles")
                .insert(profileData)
                .execute()
            
            Logger.authEvent("New user profile created with onboarding required")
            return true // New user created
        } catch {
            Logger.error("Failed to insert profile", error: error)
            throw error
        }
    }
    
    // MARK: - Profile Data Structure
    /// Represents a user profile as stored in the database (decodable from Supabase).
    private struct DatabaseProfile: Decodable {
        let id: String
        let name: String
        let email: String
        let age: Int
        let gender: String
        let diet: String
        let budget: String
        let isPremium: Bool
        let subscriptionRenewal: String?
        let profileImageURL: String?
        let createdAt: String
        let isOnboardingCompleted: Bool
        
        /// Maps struct properties to database column names for decoding.
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case email
            case age
            case gender
            case diet
            case budget
            case isPremium = "is_premium"
            case subscriptionRenewal = "subscription_renewal"
            case profileImageURL = "profile_image_url"
            case createdAt = "created_at"
            case isOnboardingCompleted = "is_onboarding_completed"
        }
    }
    
    /// Represents the data used to create or update a user profile in the database (encodable to Supabase).
    private struct ProfileData: Encodable {
        let id: String
        let name: String
        let email: String
        let age: Int
        let gender: String
        let diet: String
        let budget: String
        let isPremium: Bool
        let subscriptionRenewal: String?
        let profileImageURL: String?
        let createdAt: Date
        let isOnboardingCompleted: Bool
        
        /// Maps struct properties to database column names for encoding.
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case email
            case age
            case gender
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
        let isOnboardingCompleted: Bool
        
        enum CodingKeys: String, CodingKey {
            case age
            case gender
            case diet
            case budget
            case isOnboardingCompleted = "is_onboarding_completed"
        }
    }
    
    private func anyJSONToString(_ value: Any?) -> String? {
        guard let anyJSON = value as? AnyJSON else { return nil }
        if case let .string(str) = anyJSON { return str }
        return nil
    }
    
    //MARK: Refresh user profile from database
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


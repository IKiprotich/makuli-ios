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
        // Check for existing session
        Task {
            await getCurrentUser()
        }
    }
    
    func getCurrentUser() async {
        do {
            let session = try await supabase.auth.session
            self.user = convertToCustomUser(session.user)
        } catch {
            print("No current user: \(error)")
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
            
            // Create user profile in the database
            try await createUserProfile(response.user)
            self.user = convertToCustomUser(response.user)
        } catch {
            errorMessage = handleAuthError(error)
        }
        
        isLoading = false
    }
    
    //MARK: Sign In
    func signIn(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            self.user = convertToCustomUser(response.user)
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
            
            // Create user profile if it doesn't exist
            try await createUserProfile(response.user)
            self.user = convertToCustomUser(response.user)
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
        } catch {
            errorMessage = handleAuthError(error)
        }
    }
    
    
    //MARK: Convert to user after onboarding
    private func convertToCustomUser(_ supabaseUser: Supabase.User) -> User {
        return User(
            name: supabaseUser.userMetadata["name"] as? String ?? supabaseUser.email ?? "",
            email: supabaseUser.email ?? "",
            age: 0, 
            gender: "",
            diet: "",
            budget: "",
            isPremium: false,
            subscriptionRenewalDate: nil,
            profileImageURL: supabaseUser.userMetadata["avatar_url"] as? String
        )
    }
    
    //MARK: Handle authentication errors
    private func handleAuthError(_ error: Error) -> String {
        if let authError = error as? AuthError {
            switch authError {
            case .api(let apiError):
                return apiError.message ?? "Authentication failed"
            default:
                return "Authentication failed. Please try again."
            }
        }
        return error.localizedDescription
    }
    
    //MARK: Create user profile
    private func createUserProfile(_ supabaseUser: Supabase.User) async throws {
        do {
            try await supabase
                .from("profiles")
                .select()
                .eq("id", value: supabaseUser.id)
                .single()
                .execute()
            return
        } catch {
            let profileData = ProfileData(
                id: supabaseUser.id,
                name: supabaseUser.userMetadata["name"] as? String ?? supabaseUser.email ?? "",
                email: supabaseUser.email ?? "",
                age: 0,
                gender: "",
                diet: "",
                budget: "",
                isPremium: false,
                createdAt: ISO8601DateFormatter().string(from: Date())
            )
            
            try await supabase
                .from("profiles")
                .insert(profileData)
                .execute()
        }
    }
    
    // MARK: - Profile Data Structure
    private struct ProfileData: Encodable {
        let id: UUID
        let name: String
        let email: String
        let age: Int
        let gender: String
        let diet: String
        let budget: String
        let isPremium: Bool
        let createdAt: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case email
            case age
            case gender
            case diet
            case budget
            case isPremium = "is_premium"
            case createdAt = "created_at"
        }
    }
}

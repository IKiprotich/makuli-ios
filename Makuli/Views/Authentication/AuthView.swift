//
//  AuthView.swift
//  Makuli
//
//  Created by Ian   on 27/06/2025.
//

import SwiftUI
import GoogleSignIn

struct AuthView: View {
    @StateObject private var authManager = AuthManager()
    @State private var email = ""
    @State private var password = ""
    @State private var isSignUp = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // App Logo/Title
                AuthHeaderView(isSignUp: isSignUp)
                
                Spacer()
                
                // Email/Password Form
                AuthFormView(
                    email: $email,
                    password: $password,
                    isSignUp: isSignUp,
                    authManager: authManager
                )
                
                // Toggle Sign Up/Sign In
                AuthToggleView(isSignUp: $isSignUp, authManager: authManager)
                
                // Divider
                AuthDividerView()
                
                // Social Sign In Buttons
                SocialSignInView(authManager: authManager)
                
                // Error Message
                if let errorMessage = authManager.errorMessage {
                    AuthErrorMessageView(message: errorMessage)
                }
                
                Spacer()
            }
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .onAppear {
            configureGoogleSignIn()
        }
    }
    
    private func configureGoogleSignIn() {
        guard let path = Bundle.main.path(forResource: "Google Auth Client", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
            print("Failed to get Google Client ID")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
}

// MARK: - Preview
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
} 
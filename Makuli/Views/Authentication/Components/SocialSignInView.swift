//
//  SocialSignInView.swift
//  Makuli
//
//  Created by Ian   on 27/06/2025.
//

import SwiftUI
import GoogleSignIn

struct SocialSignInView: View {
    let authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 12) {
            // Google Sign In Button
            GoogleSignInButton(authManager: authManager)
        }
        .padding(.horizontal)
    }
}

// MARK: - Google Sign In Button
struct GoogleSignInButton: View {
    let authManager: AuthManager
    
    var body: some View {
        Button(action: {
            Task {
                await authManager.signInWithGoogle()
            }
        }) {
            HStack {
                Image(systemName: "globe")
                Text("Continue with Google")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(10)
        }
        .disabled(authManager.isLoading)
    }
}

// MARK: - Preview
struct SocialSignInView_Previews: PreviewProvider {
    static var previews: some View {
        SocialSignInView(authManager: AuthManager())
            .padding()
    }
} 
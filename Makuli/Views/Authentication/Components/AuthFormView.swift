//
//  AuthFormView.swift
//  Makuli
//
//  Created by Ian   on 27/06/2025.
//

import SwiftUI

struct AuthFormView: View {
    @Binding var email: String
    @Binding var password: String
    let isSignUp: Bool
    let authManager: AuthManager
    
    var body: some View {
        VStack(spacing: 16) {
            // Email Field
            AuthTextField(
                text: $email,
                placeholder: "Email",
                keyboardType: .emailAddress,
                textContentType: .emailAddress
            )
            
            // Password Field
            AuthSecureField(
                text: $password,
                placeholder: "Password",
                textContentType: isSignUp ? .newPassword : .password
            )
            
            // Submit Button
            AuthSubmitButton(
                isSignUp: isSignUp,
                isLoading: authManager.isLoading,
                isDisabled: authManager.isLoading || email.isEmpty || password.isEmpty
            ) {
                Task {
                    if isSignUp {
                        await authManager.signUp(email: email, password: password)
                    } else {
                        await authManager.signIn(email: email, password: password)
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Supporting Views
struct AuthTextField: View {
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    let textContentType: UITextContentType?
    
    var body: some View {
        TextField(placeholder, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .keyboardType(keyboardType)
            .autocapitalization(.none)
            .textContentType(textContentType)
    }
}

struct AuthSecureField: View {
    @Binding var text: String
    let placeholder: String
    let textContentType: UITextContentType?
    
    var body: some View {
        SecureField(placeholder, text: $text)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .textContentType(textContentType)
    }
}

struct AuthSubmitButton: View {
    let isSignUp: Bool
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(isSignUp ? "Sign Up" : "Sign In")
                    .fontWeight(.semibold)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
        .background(Color.blue)
        .foregroundColor(.white)
        .cornerRadius(10)
        .disabled(isDisabled)
    }
}

// MARK: - Preview
struct AuthFormView_Previews: PreviewProvider {
    static var previews: some View {
        AuthFormView(
            email: .constant("test@example.com"),
            password: .constant("password"),
            isSignUp: false,
            authManager: AuthManager()
        )
        .padding()
    }
} 
//
//  AuthView.swift
//  Makuli
//
//  Created by Ian   on 27/06/2025.
//

import SwiftUI
import GoogleSignIn

struct AuthView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var firstName = ""
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?
    
    enum Field {
        case firstName, email, password
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()
                
                // App Logo/Title
                VStack(spacing: 16) {
                    // App Icon/Logo Placeholder
                    Circle()
                        .fill(AppColors.primaryOrange)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .font(.system(size: 36, weight: .medium))
                                .foregroundColor(.white)
                        )
                        .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    // App Name
                    Text("Makuli")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(AppColors.textCharcoal)
                        .tracking(1.2)
                    
                    // Subtitle
                    Text(isSignUp ? "Create your account" : "Welcome back")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textCharcoal.opacity(0.7))
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                
                Spacer()
                
                // Form Fields
                VStack(spacing: 16) {
                    if isSignUp {
                        // First Name Field (Sign Up only)
                        TextField("First Name", text: $firstName)
                            .textFieldStyle(AuthTextFieldStyle())
                            .focused($focusedField, equals: .firstName)
                            .textContentType(.givenName)
                            .autocapitalization(.words)
                    }
                    
                    // Email Field
                    TextField("Email", text: $email)
                        .textFieldStyle(AuthTextFieldStyle())
                        .focused($focusedField, equals: .email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)
                    
                    // Password Field
                    SecureField("Password", text: $password)
                        .textFieldStyle(AuthTextFieldStyle())
                        .focused($focusedField, equals: .password)
                        .textContentType(isSignUp ? .newPassword : .password)
                    
                    // Submit Button
                    Button(action: handleSubmit) {
                        HStack {
                            if authViewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            }
                            Text(isSignUp ? "Create Account" : "Sign In")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(isSubmitEnabled ? AppColors.primaryOrange : AppColors.primaryOrange.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(!isSubmitEnabled || authViewModel.isLoading)
                }
                
                // Toggle Sign Up/Sign In
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSignUp.toggle()
                        clearFields()
                    }
                }) {
                    Text(isSignUp ? "Already have an account? Sign in" : "Don't have an account? Sign up")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.primaryOrange)
                }
                
                // Divider
                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.3))
                    Text("or")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textCharcoal.opacity(0.6))
                        .padding(.horizontal, 16)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.gray.opacity(0.3))
                }
                
                // Google Sign In Button
                Button(action: {
                    Task {
                        await authViewModel.signInWithGoogle()
                    }
                }) {
                    HStack {
                        Image("Google")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 20, height: 20)
                        Text("Continue with Google")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textCharcoal)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                }
                .disabled(authViewModel.isLoading)
                
                // Error Message
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.warnRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                // Test Connection Button (for debugging)
                // Button(action: {
                //     Task {
                //         let isConnected = await SupabaseManager.shared.testConnection()
                //         if isConnected {
                //             print("🎉 Supabase is properly configured and accessible!")
                //         } else {
                //             print("⚠️ Supabase connection issues detected - check your configuration")
                //         }
                //     }
                // }) {
                //     Text("Test Supabase Connection")
                //         .font(.system(size: 12, weight: .medium, design: .rounded))
                //         .foregroundColor(AppColors.textCharcoal.opacity(0.6))
                // }
                // .padding(.top, 8)
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .background(AppColors.bgCream)
            .navigationBarHidden(true)
            .onTapGesture {
                hideKeyboard()
            }
        }
        .onAppear {
            configureGoogleSignIn()
        }
    }
    
    // MARK: - Computed Properties
    private var isSubmitEnabled: Bool {
        if isSignUp {
            return !firstName.isEmpty && !email.isEmpty && !password.isEmpty
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    // MARK: - Actions
    private func handleSubmit() {
        Task {
            if isSignUp {
                await authViewModel.signUp(email: email, password: password)
            } else {
                await authViewModel.signIn(email: email, password: password)
            }
        }
    }
    
    private func clearFields() {
        firstName = ""
        email = ""
        password = ""
        focusedField = nil
        authViewModel.errorMessage = nil
    }
    
    private func configureGoogleSignIn() {
        guard let path = Bundle.main.path(forResource: "Google Auth Client", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let clientId = plist["CLIENT_ID"] as? String else {
                            Logger.error("Failed to get Google Client ID")
            return
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
}

// MARK: - Custom Text Field Style
struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

// MARK: - Preview
struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
    }
} 

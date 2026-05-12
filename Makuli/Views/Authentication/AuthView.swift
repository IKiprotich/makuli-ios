//
//  AuthView.swift
//  Makuli
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

    enum Field { case firstName, email, password }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                Spacer()

                brandHeader

                Spacer()

                formFields

                toggleModeButton

                divider

                googleSignInButton

                if let error = authViewModel.errorMessage {
                    Text(error)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.warnRed)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.horizontal, 40)
            .background(AppColors.background.ignoresSafeArea())
            .navigationBarHidden(true)
            .onTapGesture { hideKeyboard() }
        }
        .onAppear { configureGoogleSignIn() }
    }

    // MARK: - Subviews

    private var brandHeader: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(AppColors.primaryOrange)
                .frame(width: 80, height: 80)
                .overlay(
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundColor(.white)
                )
                .shadow(color: AppColors.primaryOrange.opacity(0.3), radius: 8, x: 0, y: 4)

            Text("Makuli")
                .font(.system(size: 36, weight: .bold, design: .rounded))
                .foregroundColor(AppColors.text)

            Text(isSignUp ? "Create your account" : "Welcome back")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var formFields: some View {
        VStack(spacing: 16) {
            if isSignUp {
                TextField("First Name", text: $firstName)
                    .textFieldStyle(AuthTextFieldStyle())
                    .focused($focusedField, equals: .firstName)
                    .textContentType(.givenName)
                    .textInputAutocapitalization(.words)
            }

            TextField("Email", text: $email)
                .textFieldStyle(AuthTextFieldStyle())
                .focused($focusedField, equals: .email)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .textContentType(.emailAddress)

            SecureField("Password", text: $password)
                .textFieldStyle(AuthTextFieldStyle())
                .focused($focusedField, equals: .password)
                .textContentType(isSignUp ? .newPassword : .password)

            Button(action: handleSubmit) {
                HStack(spacing: 8) {
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
                .background(isSubmitEnabled ? AppColors.primaryOrange : AppColors.primaryOrange.opacity(0.4))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(!isSubmitEnabled || authViewModel.isLoading)
        }
    }

    private var toggleModeButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                isSignUp.toggle()
                clearFields()
            }
        } label: {
            Text(isSignUp ? "Already have an account? **Sign in**" : "Don't have an account? **Sign up**")
                .font(.system(size: 14, design: .rounded))
                .foregroundColor(AppColors.primaryOrange)
        }
    }

    private var divider: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
            Text("or")
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal, 12)
            Rectangle().frame(height: 1).foregroundColor(Color.gray.opacity(0.3))
        }
    }

    private var googleSignInButton: some View {
        Button {
            Task { await authViewModel.signInWithGoogle() }
        } label: {
            HStack(spacing: 12) {
                Image("Google")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 20, height: 20)
                Text("Continue with Google")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.text)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(AppColors.surface)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1))
            .cornerRadius(12)
        }
        .disabled(authViewModel.isLoading)
    }

    // MARK: - Helpers

    private var isSubmitEnabled: Bool {
        isSignUp
            ? !firstName.isEmpty && !email.isEmpty && password.count >= 6
            : !email.isEmpty && !password.isEmpty
    }

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
            Logger.error("Failed to load Google Client ID")
            return
        }
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)
    }
}

// MARK: - Text Field Style

struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppColors.surface)
            .cornerRadius(12)
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.border, lineWidth: 1))
    }
}

#Preview {
    AuthView()
        .environmentObject(AuthViewModel())
}

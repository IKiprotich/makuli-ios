//
//  SplashScreenView.swift
//  Buildplate
//
//  Created by ian on 2025-01-03.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var currentPage: Int
    let totalPages: Int
    @State private var scale = 0.8
    @State private var opacity = 0.6
    
    var body: some View {
        ZStack {
            //Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [AppColors.primaryOrange, AppColors.warmsand]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // App Logo
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 32, style: .continuous))
                    .shadow(radius: 8)
                
                // App Name
                Text("Buildplate")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // Tagline
                Text("Your personalized meal planning companion")
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // Loading indicator
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
            }
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.2)) {
                    scale = 1.0
                    opacity = 1.0
                }
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    SplashScreenView(currentPage: .constant(0), totalPages: 14)
}

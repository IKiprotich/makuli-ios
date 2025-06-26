//
//  SplashScreenView.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import SwiftUI

struct SplashScreenView: View {
    
    @Binding var currentPage: Int
    
    var body: some View {
        ZStack{
            //Background Gradient
            LinearGradient(
                colors: [Color(hex: "#F97316"), Color(hex: "#EF4444")],
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea(.all)
            
            VStack(spacing: 40) {
                Spacer()
                
                //logo/icon placeholder
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                
                //App title
                Text("Makuli")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                //tag line
                Text("Smart Meal Planning Made Simple")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                //get started button
                Button( action: {
                    withAnimation(.easeInOut(duration: 0.5)){
                        currentPage = 1
                    }
                }){
                    Text("Get Started")
                        .font(.headline)
                        .foregroundColor(Color(hex: "#F97316"))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
        }
        .ignoresSafeArea(.all) 
    }
}

// Extension for hex colors
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    SplashScreenView(currentPage: .constant(0))
}

//
//  HeaderView.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import SwiftUI

struct HeaderView: View {
    let onProfileTap: () -> Void
    let onSettingsTap: () -> Void
    let profileImageUrl: String?
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced profile image with actual profile picture
            Button(action: onProfileTap) {
                ZStack {
                    Circle()
                        .fill(AppColors.primaryOrange.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    if let url = profileImageUrl, let imageUrl = URL(string: url) {
                        AsyncImage(url: imageUrl) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            ProgressView()
                                .scaleEffect(0.6)
                                .tint(AppColors.primaryOrange)
                        }
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(AppColors.primaryOrange)
                    }
                }
            }
            
            Spacer()
            
            // Enhanced home title
            VStack(spacing: 2) {
                Text("Home")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.text)
                
                Text("Your meal planning hub")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // Enhanced settings button
            Button(action: onSettingsTap) {
                ZStack {
                    Circle()
                        .fill(AppColors.text.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "gearshape")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(AppColors.text)
                }
            }
        }
        .padding(.top, 12)
        .padding(.bottom, 8)
    }
}

#Preview {
    HeaderView(
        onProfileTap: {},
        onSettingsTap: {},
        profileImageUrl: nil
    )
}

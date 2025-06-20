//
//  WeekCarouselView.swift
//  Makuli
//
//  Created by Ian   on 20/06/2025.
//

import SwiftUI

struct WeekCarouselView: View {
    
    let weeks: [WeekPlan]
    @Binding var selectedWeek: WeekPlan?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(weeks) { week in
                    WeekCarouselCard(
                        week: week,
                        isSelected: selectedWeek?.id == week.id
                    )
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            selectedWeek = week
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

struct WeekCarouselCard: View {
    let week: WeekPlan
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            AsyncImage(url: URL(string: "meal_placeholder")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray5))
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.secondary)
                    )
            }
            .frame(width: 120, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            VStack(spacing: 4) {
                Text(week.weekTitle)
                    .font(.headline)
                    .foregroundColor(isSelected ? Color(AppColors.primaryOrange) : Color(AppColors.textCharcoal))
                
                Text(week.costFormatted)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}
#Preview {
   // WeekCarouselView()
}

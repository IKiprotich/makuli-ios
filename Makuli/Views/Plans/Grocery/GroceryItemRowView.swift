//
//  GroceryItemRowView.swift
//  Makuli
//
//  Created by Ian   on 24/06/2025.
//

import SwiftUI

struct GroceryItemRowView: View {
    
    let item: GroceryItem
    let isChecked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            //checkbox
            Button(action: onToggle) {
                ZStack {
                    
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isChecked ? AppColors.successGreen : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(isChecked ? AppColors.successGreen : Color.clear)
                        )
                    
                    
                    if isChecked {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            //emoji
            Text(item.emoji)
            .font(.title2)
            .frame(width: 32)
            
            //item details
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.system(size:16, weight: .medium))
                    .foregroundColor(isChecked ? AppColors.successGreen : AppColors.textCharcoal)
                    .strikethrough(isChecked)
                
                Text(item.quantity)
                    .font(.system(size:14))
                    .foregroundColor(isChecked ? AppColors.successGreen.opacity(0.7) : Color.gray)
                    .strikethrough(isChecked)
            }
            
            Spacer()
            
            
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .background(Color.clear)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle()
        }
        .animation(.easeInOut(duration: 0.2), value: isChecked)
    }
}



#Preview {
  //  GroceryItemRowView()
}

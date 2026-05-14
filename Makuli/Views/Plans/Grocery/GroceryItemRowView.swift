//
//  GroceryItemRowView.swift
//  Makuli
//
//  Created by Ian on 2025-06-24.
//

import SwiftUI

struct GroceryItemRowView: View {
    
    let item: GroceryItem
    let isChecked: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
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
            
            Text("🛒")
            .font(.title2)
            .frame(width: 32)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.system(size:16, weight: .medium))
                    .foregroundColor(isChecked ? AppColors.successGreen : AppColors.text)
                    .strikethrough(isChecked)
                
                Text(item.formattedQuantity)
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
}

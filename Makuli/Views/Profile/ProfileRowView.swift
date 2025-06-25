//
//  ProfileRowView.swift
//  Makuli
//
//  Created by Ian   on 25/06/2025.
//

import SwiftUI

struct ProfileRowView: View {
    
    let icon: String?
    let iconColor: Color
    let title: String
    let value: String?
    let showChevron: Bool
    let showToggle: Bool
    @Binding var toggleValue: Bool
    let action: (() -> Void)?
    
    
    init(
        icon: String? = nil,
        iconColor: Color = .gray,
        title: String,
        value: String? = nil,
        showChevron: Bool = false,
        showToggle: Bool = false,
        toggleValue: Binding<Bool> = .constant(false),
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.value = value
        self.showChevron = showChevron
        self.showToggle = showToggle
        self._toggleValue = toggleValue
        self.action = action
    }
    
    
    // Convenience initializer for simple rows with values
    init(title: String, value: String) {
        self.init(title: title, value: value, showChevron: false)
    }
    
    // Convenience initializer for navigation rows
    init(icon: String? = nil, iconColor: Color = .gray, title: String, action: @escaping () -> Void) {
        self.init(icon: icon, iconColor: iconColor, title: title, showChevron: true, action: action)
    }
    
    // Convenience initializer for toggle rows
    init(title: String, toggleValue: Binding<Bool>) {
        self.init(title: title, showToggle: true, toggleValue: toggleValue)
    }
    
    
    var body: some View {
        Button {
            action?()
        } label: {
            HStack(spacing: 12) {
                //icon
                if let icon = icon {
                    Image(systemName: icon)
                        .foregroundColor(iconColor)
                        .frame(width: 20, height: 20)
                }
                
                //title
                Text(title)
                    .font(.body)
                    .foregroundColor(Color(.label))
                    .multilineTextAlignment(.leading)
                
                
                Spacer()
                
                //value, toggle, or chevron
                if showToggle {
                    Toggle("", isOn: $toggleValue)
                        .labelsHidden()
                }
                else if let value = value {
                    Text(value)
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                }
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil && !showToggle)

        
        
        
        
        
        
    }
}

#Preview {
    //ProfileRowView()
}

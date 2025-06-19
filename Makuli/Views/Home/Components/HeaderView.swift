//
//  HeaderView.swift
//  Makuli
//
//  Created by Ian   on 19/06/2025.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack{
            //profile image
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .foregroundColor(AppColors.textCharcoal)
            
            Spacer()
            
            //home title
            Text("Home")
                .font(AppFonts.title2())
                .foregroundColor(AppColors.textCharcoal)
            
            Spacer()
            
            //settings button
            Button(action: {
                //to handle redirect to settings
            }) {
                Image(systemName: "gearshape")
                    .font(.title2)
                    .foregroundColor(AppColors.textCharcoal)
            }
        }
        .padding(.top, 8)
    }
}

#Preview {
    HeaderView()
}

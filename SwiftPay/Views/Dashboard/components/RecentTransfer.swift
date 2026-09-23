//
//  QuickTransfer.swift
//  SwiftPay
//
//  Created by iPHTech 34 on 22/09/26.
//

import SwiftUI

struct RecentTransfer: View {
    
    let name: String
    let icon: String
    
    var body: some View {
        
        VStack(spacing: 4) {
            
            Group {
                
                if name == "More" {
                    Image(systemName: icon)
                        .font(.title)
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .glassEffect().opacity(0.8)

                        
                    
                } else {
                    Image("demo_profile_image")
                        .resizable()
                        .scaledToFill()
                        .font(.largeTitle)
                        .background(
                            Color("surface")
                        )
                        .clipShape(Circle())
                        .frame(width: 70, height: 70)

                }
                
            }
            .foregroundStyle(
                Color(.white)
            )
            .overlay {
                Circle()
                    .stroke(
                        Color("border").opacity(0.25),
                        lineWidth: 1
                    )
            }
            
            Text(name)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(
                    Color("secondaryText")
                )
        }
    }
}

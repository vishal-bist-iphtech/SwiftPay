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
    let image: String
    
    var body: some View {
        
        VStack(spacing: 4) {
            
            Group {
                
                if name == "Add" {
                    Image(systemName: "plus")
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .glassEffect().opacity(0.8)

                        
                    
                } else {
                    Image(image)
                        .resizable()
                        .scaledToFill()
                        .background(
                            Color("surface")
                        )
                        .clipShape(Circle())
                        .frame(width: 70, height: 70)

                }
                
            }
            .font(.largeTitle)
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

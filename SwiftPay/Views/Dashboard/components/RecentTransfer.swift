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
    /// Saved photo; nil -> person badge.
    var imageData: Data? = nil

    
    var body: some View {
        
        VStack(spacing: 4) {
            
            Group {
                
                if name == "See more" || name == "See less" {
                    Image(systemName: icon)
                        .font(.title)
                        .frame(width: 70, height: 70)
                        .clipShape(Circle())
                        .glassEffect().opacity(0.8)

                        
                    
                } else if let imageData,
                          let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .background(
                            Color("surface")
                        )
                        .clipShape(Circle())
                        .frame(width: 70, height: 70)

                } else {
                    Image(systemName: "person.fill")
                        .font(.title)
                        .foregroundStyle(Color("mutedText"))
                        .frame(width: 70, height: 70)
                        .background(Color("surface"))
                        .clipShape(Circle())
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

//
//  SettingsItemView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
//

import SwiftUI

struct SettingsItemView<Destination: View>: View {
    var title: LocalizedStringKey
    var icon: String
    var destination: Destination?
    var action: (() -> Void)? = nil
    var hasGradientBorder: Bool = false
    
    var body: some View {
        Group {
            if let destination = destination {
                NavigationLink(destination: destination) {
                    itemContent
                }
            } else {
                Button(action: {
                    action?()
                }) {
                    itemContent
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var itemContent: some View {
        GeometryReader { geometry in
            HStack {
                
                Text(title)
                    .font(Font.custom("Montserrat-Regular", size: 20))
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    .offset(x: 10)
                
                Spacer()
                
                Image(systemName: icon)
                    .font(Font.custom("Montserrat-Regular", size: 20))
                    .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                    .offset(x: -10)
            }
            .padding()
            .frame(maxWidth: .infinity, maxHeight: geometry.size.height)
            .background(
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .fill(Color(uiColor: .CalliopeBlack()).opacity(0.1))
            )
            .overlay(
                hasGradientBorder ?
                RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(uiColor: .AuraFlowBlue()).opacity(0.9), Color.cyan.opacity(0.9)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
                :  RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.9), Color.gray.opacity(0.9)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
        }
        .frame(height: 60)
    }
}

#Preview {
    NavigationStack {
        SettingsItemView(
            title: "Example Item",
            icon: "chevron.right",
            destination: Text("Destination View"),
            hasGradientBorder: true
        )
    }
}

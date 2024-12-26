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
    var destination: Destination? // Make the destination optional
    var action: (() -> Void)? = nil // Optional action closure
    var hasGradientBorder: Bool = false // Flag to determine if the gradient border is applied

    var body: some View {
        Group {
            if let destination = destination {
                // Use NavigationLink when a destination is provided
                NavigationLink(destination: destination) {
                    itemContent
                }
            } else {
                // Use Button when only action closure is provided
                Button(action: {
                    action?()
                }) {
                    itemContent
                }
            }
        }
        .padding(.horizontal)
    }

    // Separate the item content for reuse
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
                                gradient: Gradient(colors: [Color(uiColor: .CalliopeYellow()).opacity(0.9), Color.cyan.opacity(0.9)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1 // Adjust the border thickness as needed
                        )
                    :  RoundedRectangle(cornerRadius: geometry.size.height / 2)
                    .strokeBorder(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.gray.opacity(0.9), Color.gray.opacity(0.9)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1 // Adjust the border thickness as needed
                    )
            )
        }
        .frame(height: 60) // Example fixed height for consistent appearance
    }
}

#Preview {
    NavigationStack {
        SettingsItemView(
            title: "Example Item",
            icon: "chevron.right",
            destination: Text("Destination View"),
            hasGradientBorder: true // Example of an item with a gradient border
        )
    }
}

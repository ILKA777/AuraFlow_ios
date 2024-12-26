//
//  SubscriptionView.swift
//  Calliope
//
//  Created by Илья on 06.08.2024.
//

import SwiftUI

struct SubscriptionView: View {
    @State private var isSubscriptionActive = true
    @Environment(\.dismiss) private var dismiss // Access the dismiss environment action
    
    // Example subscription instance
    private let subscription = Subscription(
        id: UUID(),
        startDate: Date(), // Set the start date to the current date
        endDate: Calendar.current.date(byAdding: .year, value: 1, to: Date())!, // Set the end date to one year from now
        type: .yearly
    )
    
    var body: some View {
        VStack(spacing: 20) {
            // Subscription Information
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Подписка")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                }
                
                HStack {
                    Text("Активна до \(formattedDate(subscription.endDate))")
                        .font(.system(size: 16))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                    
                    Spacer()
                    
                    Toggle("", isOn: $isSubscriptionActive)
                        .toggleStyle(SwitchToggleStyle(tint: Color.green))
                        .labelsHidden()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .CalliopeBlack()).opacity(0.2))
            )
            .padding(.horizontal)
            .offset(y: 20)
            
            // Purchase History Button
            NavigationLink(destination: PurchaseHistoryView()) {
                HStack {
                    Text("История покупок")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .CalliopeBlack()).opacity(0.2))
                )
            }
            .padding(.horizontal)
            .offset(y: 20)
            
            Spacer()
        }
        .background(
            Image("default") // Replace with your image asset name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Hide default back button title
        .toolbar {
            ToolbarItem(placement: .principal) { // Use .principal to customize the title
                Text("Подписка и покупки")
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .CalliopeWhite())) // Set the desired color here
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss() // Dismiss the current view to navigate back
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(uiColor: .CalliopeWhite())) // White back button
                }
            }
        }
        .tint(Color(uiColor: .CalliopeWhite())) // Set the tint color for navigation items to white
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        SubscriptionView()
    }
}

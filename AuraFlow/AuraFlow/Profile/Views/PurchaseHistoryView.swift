//
//  PurchaseHistoryView.swift
//  Calliope
//
//  Created by Илья on 06.08.2024.
//

import SwiftUI

struct PurchaseHistoryView: View {
    
    @Environment(\.dismiss) private var dismiss // Access the dismiss environment action
    
    // Example purchase data
    let purchases: [Purchase] = [
        Purchase(name: "Подписка", date: "сегодня", amount: "-399 ₽"),
        Purchase(name: "Пакет Природа", date: "23.02", amount: "-199 ₽")
    ]
    
    var body: some View {
        VStack {
            List {
                ForEach(purchases) { purchase in
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(purchase.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            Text(purchase.date)
                                .font(.system(size: 16))
                                .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                        }
                        Spacer()
                        Text(purchase.amount)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    }
                    .padding(.vertical, 10)
                    .listRowBackground(Color.clear)
                }
            }
            .background(Color.clear)
            .scrollContentBackground(.hidden) // iOS 16 specific, to hide the default list background
            
            Spacer()
            
            // Footer Options
            VStack(alignment: .leading, spacing: 10) {
                Button(action: {
                    print("Поддержка tapped")
                }) {
                    Text("Поддержка")
                        .font(.system(size: 20))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
                .padding(.bottom, -25)
                
                
                Button(action: {
                    print("Восстановить покупки tapped")
                }) {
                    Text("Восстановить покупки")
                        .font(.system(size: 20))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                }
            }
            .padding(.leading, 10)  // Padding from the left edge
            .padding(.bottom, 20)   // Padding from the bottom
        }
        .background(
            Image("default") // Replace with your image asset name
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationTitle("История покупок")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // Hide default back button title
        .tint(Color(uiColor: .CalliopeWhite()))
        .toolbar {
            ToolbarItem(placement: .principal) { // Use .principal to customize the title
                Text("Подписка и покупки")
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .CalliopeWhite())) // Set the desired color here
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        PurchaseHistoryView()
    }
}

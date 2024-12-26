//
//  TargetBarView.swift
//  Calliope
//
//  Created by Илья on 13.08.2024.
//

import SwiftUI

struct TargetBar: View {
    @State private var targetText = ""
    
    var body: some View {
        NavigationStack {
            HStack {
                Image(systemName: "questionmark.circle.fill")
                    .foregroundColor(.gray)

                ZStack(alignment: .leading) {
                    if targetText.isEmpty {
                        Text("Задать цель")
                            .foregroundColor(.gray)
                    }
                    TextField("", text: $targetText)
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }

            }
            .frame(height: 30)
            .padding(8)
            .background(Color(uiColor: .CalliopeDarkBlue()))
            .cornerRadius(50)
            .overlay( // Adding a gray border
                RoundedRectangle(cornerRadius: 50)
                    .stroke(Color.gray, lineWidth: 1)
            )
            
            .padding(.horizontal)
        }
    }
}

#Preview {
    TargetBar()
}


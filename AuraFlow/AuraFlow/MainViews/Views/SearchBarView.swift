//
//  SearchBarView.swift
//  Calliope
//
//  Created by Илья on 17.08.2024.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(Color(uiColor: .CalliopeWhite()))

            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Поиск")
                        .font(Font.custom("Montserrat-Regular", size: 16))
                        .foregroundColor(.gray)
                }
                TextField("", text: $searchText)
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding(8)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(50)
        .padding(.horizontal)
    }
}

//#Preview {
//    SearchBar()
//}


//
//  SearchBarView.swift
//  Calliope
//
//  Created by Илья on 08.08.2024.
//

import SwiftUI

struct MainSearchBar: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Поиск")
                        .font(Font.custom("Montserrat-Regular", size: 16))
                        .foregroundColor(.white)
                }
                TextField("", text: $searchText)
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            
            NavigationLink(destination: AIIntroView()) {
                Image("searchCircle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                
            }
            .padding(.leading, 8)
        }
        .padding(8)
        .background(Color(uiColor: .AuraFlowBlue()))
        .cornerRadius(50)
        .overlay(
            RoundedRectangle(cornerRadius: 50)
                .stroke(Color.gray, lineWidth: 1)
        )
        .padding(.horizontal)
    }
}

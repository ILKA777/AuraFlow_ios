//
//  CustomButtonForTestView.swift
//  Calliope
//
//  Created by Илья on 09.08.2024.
//

import SwiftUI

struct CustomButton: View {
    var text: String
    
    var body: some View {
        Text(text)
            .font(Font.custom("Montserrat-Regular", size: 20))
            .foregroundColor(Color(uiColor: .CalliopeWhite()))
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(uiColor: .CalliopeWhite()).opacity(0.5), lineWidth: 1)
            )
            .background(
                Color(uiColor: .CalliopeBlack()).opacity(0.2)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
            )
            .padding(.horizontal, 10)
    }
}

#Preview {
    CustomButton(text: "Мужской")
}

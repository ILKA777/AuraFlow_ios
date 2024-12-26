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
            .font(Font.custom("Montserrat-Regular", size: 20)) // Устанавливаем шрифт и размер текста
            .foregroundColor(Color(uiColor: .CalliopeWhite())) // Цвет текста
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(uiColor: .CalliopeWhite()).opacity(0.5), lineWidth: 1) // Граница с закругленными краями и прозрачностью
            )
            .background(
                Color(uiColor: .CalliopeBlack()).opacity(0.2)
                    .clipShape(RoundedRectangle(cornerRadius: 30)) // Заливка с закругленными краями
            )
            .padding(.horizontal, 10)
    }
}

#Preview {
    CustomButton(text: "Мужской")
}

//
//  CustomSearchbar.swift
//  Calliope
//
//  Created by Илья on 11.09.2024.
//

import SwiftUI

struct CustomSearchbar: View {
    @Binding var searchText: String
    @State var iconOffset = false
    @State var state = false
    @State var progress: CGFloat = 1.0
    @State var showTextFi = false
    @FocusState private var isTextFieldFocused: Bool
    var body: some View {
        ZStack(alignment: .trailing) {
            ZStack {
                Capsule()
                if showTextFi {
                    TextField("Поиск", text: $searchText)
                        .padding(.horizontal)
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .focused($isTextFieldFocused)
                        .onAppear {
                            isTextFieldFocused = true
                        }
                }
            }
            .frame(width: state ? UIScreen.main.bounds.width * 0.75 : 48, height: 48)
            .foregroundColor(Color.gray.opacity(0.7))
            
            icon(searchText: $searchText, progress: $progress, iconOffset: $iconOffset, state: $state, showTextFi: $showTextFi)
        }
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

struct customSearchbar_Previews: PreviewProvider {
    static var previews: some View {
        CustomSearchbar(searchText: .constant(""))
    }
}

struct icon: View {
    @Binding var searchText: String
    @Binding var progress: CGFloat
    @Binding var iconOffset: Bool
    @Binding var state: Bool
    @Binding var showTextFi: Bool
    
    var body: some View {
        Button {
            if showTextFi {
                showTextFi = false
                searchText = ""
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation {
                    if !showTextFi && state {
                        showTextFi = true
                    }
                }
            }
            withAnimation {
                state.toggle()
            }
            if progress == 1.0 {
                withAnimation(.linear(duration: 0.5)) {
                    progress = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation {
                        iconOffset.toggle()
                    }
                }
            } else {
                withAnimation {
                    iconOffset.toggle()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    withAnimation(.linear(duration: 0.5)) {
                        progress = 1.0
                    }
                }
            }
        } label: {
            VStack(spacing: 0) {
                Circle()
                    .trim(from: 0.0, to: progress)
                    .stroke(lineWidth: 1.5)
                    .rotationEffect(.degrees(88))
                    .frame(width: 15, height: 15)
                    .padding()
                RoundedRectangle(cornerRadius: 5)
                    .frame(width: 1.5, height: iconOffset ? 20 : 16)
                    .offset(y: -17)
                    .overlay {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 1.5, height: iconOffset ? 20 : 16)
                            .rotationEffect(.degrees(iconOffset ? 80 : 0), anchor: .center)
                            .offset(y: -17)
                    }
            }
        }
        .rotationEffect(.degrees(-40))
        .offset(x: iconOffset ? -5 : -3, y: iconOffset ? -5 : 2)
        .foregroundColor(Color(uiColor: .CalliopeWhite()))
        .frame(width: 38, height: 38)
    }
}

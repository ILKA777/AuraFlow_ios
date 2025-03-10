//
//  HeartRateView.swift
//  AuraFlow
//
//  Created by Ilya on 19.01.2025.
//

//
//  HeartRateView.swift
//  AuraFlow
//
//  Created by Ilya on 19.01.2025.
//

import SwiftUI

struct HeartRateView: View {
    @StateObject private var heartRateMonitor = HeartRateMonitor()

    var body: some View {
        VStack(spacing: 15) {
            Text("Ваш пульс")
                .font(.headline)

            Text("\(Int(heartRateMonitor.heartRate)) BPM")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding()

            // Кнопка для запуска измерения пульса
            Button(action: {
                heartRateMonitor.startWorkout()
            }) {
                Text("Начать измерение")
                    .font(.system(size: 13.19, weight: .medium)) // Уменьшаем шрифт
                    .padding()
                    .frame(maxWidth: .infinity)
                    //.background(Color.green)
                    .foregroundColor(.white)

            }
            .background(LinearGradient(gradient: Gradient(colors: [.green, .blue]), startPoint: .leading, endPoint: .trailing))
            .mask(RoundedRectangle(cornerRadius: 32))
            .padding(.horizontal)

            // Кнопка для остановки измерения пульса
            Button(action: {
                heartRateMonitor.stopWorkout()
            }) {
                Text("Остановить измерение")
                    .font(.system(size: 13.19, weight: .medium)) // Уменьшаем шрифт
                    .padding()
                    .frame(maxWidth: .infinity)
                    
                    .foregroundColor(.white)
            }
            .background(LinearGradient(gradient: Gradient(colors: [.red, .orange]), startPoint: .leading, endPoint: .trailing))
            .mask(RoundedRectangle(cornerRadius: 32))
            .padding(.horizontal)

            Spacer() // Добавляем отступ внизу
        }
        .padding()
        .onAppear {
            print("HeartRateView отображен.")
        }
        .onDisappear {
            heartRateMonitor.stopWorkout()
        }
    }
}

// MARK: - Preview
struct HeartRateView_Previews: PreviewProvider {
    static var previews: some View {
        HeartRateView()
            .previewDevice("iPhone 14 Pro")
    }
}

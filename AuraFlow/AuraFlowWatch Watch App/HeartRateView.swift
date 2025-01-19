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
        VStack(spacing: 20) {
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
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            // Кнопка для остановки измерения пульса
            Button(action: {
                heartRateMonitor.stopWorkout()
            }) {
                Text("Остановить измерение")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer() // Добавляем отступ внизу
        }
        .padding()
        .onAppear {
            // Действия при появлении экрана (если нужны)
            print("HeartRateView отображен.")
        }
        .onDisappear {
            // Действия при закрытии экрана (например, остановка измерения)
            heartRateMonitor.stopWorkout()
        }
    }
}

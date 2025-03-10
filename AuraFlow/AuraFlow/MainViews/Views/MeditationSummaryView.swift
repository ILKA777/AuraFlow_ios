//
//  Untitled.swift
//  AuraFlow
//
//  Created by Ilya on 04.03.2025.
//

import SwiftUI
import Charts

struct MeditationSummaryView: View {
    let startHeartRate: Double
    let endHeartRate: Double
    let heartRateHistory: [Double]
    
    // Рекомендация формируется на основе того, как изменился пульс:
    // Если пульс был высоким (>80) и снизился до нормального (<80) – позитивное сообщение.
    // Если пульс остался высоким или повысился – предложение заняться медитацией ещё.
    // Если пульс был и остался нормальным – похвала.
    var recommendation: String {
        if startHeartRate > 80 {
            if endHeartRate < 80 {
                return "У вас отлично получается медитировать! Сейчас вы успокоились и зарядились энергией, можете продолжать заниматься своими делами дальше!"
            } else {
                return "Кажется, вам надо помедитировать ещё, попробуйте найти новую медитацию в нашем каталоге или создать медитацию под себя с помощью функции генерации медитаций."
            }
        } else {
            if endHeartRate <= 80 {
                return "Вы молодец! Продолжайте в том же духе, надеюсь медитации помогли вам расслабиться и настроиться на нужный лад."
            } else {
                return "Кажется, вам надо помедитировать ещё, попробуйте найти новую медитацию в нашем каталоге или создать медитацию под себя с помощью функции генерации медитаций."
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Медитация завершена")
                .font(.title)
                .bold()
            
            HStack {
                Text("Пульс в начале:")
                Spacer()
                Text("\(Int(startHeartRate)) BPM")
            }
            .padding(.horizontal)
            
            HStack {
                Text("Пульс в конце:")
                Spacer()
                Text("\(Int(endHeartRate)) BPM")
            }
            .padding(.horizontal)
            
            Chart {
                ForEach(heartRateHistory.indices, id: \.self) { index in
                    LineMark(
                        x: .value("Время", index),
                        y: .value("Пульс", heartRateHistory[index])
                    )
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
            
            Text(recommendation)
                .font(.headline)
                .multilineTextAlignment(.center)
                .padding()
            
            Spacer()
        }
        .padding()
    }
}

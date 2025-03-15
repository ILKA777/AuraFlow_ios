//
//  HeartRateView.swift
//  AuraFlow
//
//  Created by Ilya on 19.01.2025.
//

import SwiftUI

struct HeartRateView: View {
    @StateObject private var heartRateReceiver = HeartRateReceiver()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Ваш пульс")
                .font(.headline)
            
            Text("\(Int(heartRateReceiver.heartRate)) BPM")
                .font(.largeTitle)
                .foregroundColor(.red)
                .padding()
            
            Text("Данные передаются с Apple Watch")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
    }
}

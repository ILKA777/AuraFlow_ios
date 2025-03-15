//
//  StatisticView.swift
//  AuraFlow
//
//  Created by Ilya on 12.03.2025.
//


import SwiftUI
import UIKit

struct StatisticView: View {
    
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ResponseViewModel()
    @StateObject private var statisticsManager = StatisticService.shared
    @StateObject private var playbackManager = PlaybackManager.shared
    @State private var shouldShowBreathingPractice = false
    @State private var date = Date()
    
    @State private var showPopup: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color.white.opacity(0.15))
                        .frame(width: geometry.size.width, height: 280)
                        .position(x: geometry.size.width / 2, y: -40)
                    
                    VStack {
                        HStack {
                            Text("\(Int(statisticsManager.meditationMinutes))/\(Int(statisticsManager.targetMinutes))")
                                .font(Font.custom("Montserrat-Semibold", size: 50))
                                .foregroundColor(Color(uiColor: .AuraFlowBlue()))
                                .lineLimit(1)
                                .multilineTextAlignment(.leading)
                            
                            VStack(alignment: .leading) {
                                Text("минут")
                                    .font(Font.custom("Montserrat-Semibold", size: 23))
                                    .foregroundColor(Color(uiColor: .AuraFlowBlue()))
                                    .lineLimit(1)
                                
                                Text("активности")
                                    .font(Font.custom("Montserrat-Semibold", size: 23))
                                    .foregroundColor(Color(uiColor: .AuraFlowBlue()))
                                    .lineLimit(1)
                            }
                            
                            ProgressRingView(
                                progress: CGFloat(statisticsManager.meditationMinutes / statisticsManager.targetMinutes)
                            )
                            .frame(width: 100, height: 100)
                        }
                        .padding(.horizontal, 10)
                        .position(x: geometry.size.width / 2, y: 40)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(Color.white.opacity(0.15))
                                .frame(width: geometry.size.width * 0.95, height: UIScreen.main.bounds.height < 900 ? 340 : 360)
                            
                            DatePicker(
                                "Start Date",
                                selection: $date,
                                displayedComponents: [.date]
                            )
                            .datePickerStyle(.graphical)
                            .foregroundColor(.white)
                            .colorScheme(.dark)
                            .accentColor(Color(uiColor: .AuraFlowPink()))
                            .frame(width: geometry.size.width * 0.9)
                            .onChange(of: date) { newDate in
                                withAnimation { showPopup = true }
                            }
                        }
                        .position(x: geometry.size.width / 2, y: UIScreen.main.bounds.height < 900 ? -20 : -80)
                    }
                    .padding(.top, -20)
                    
                    if showPopup {
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                withAnimation { showPopup = false }
                            }
                            .edgesIgnoringSafeArea(.all)
                        
                        DayProgressPopupView(
                            meditationMinutes: statisticsManager.meditationMinutes(for: date),
                            targetMinutes: statisticsManager.targetMinutes
                        )
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .transition(.scale)
                    }
                }
                .background(
                    Image("default")
                        .resizable()
                        .scaledToFill()
                        .ignoresSafeArea(.all)
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Статистика")
                    .font(Font.custom("Montserrat-Semibold", size: 20))
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
        }
        .onAppear {
            playbackManager.isMiniPlayerVisible = false
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    StatisticView()
}

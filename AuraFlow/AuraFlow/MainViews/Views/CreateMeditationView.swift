//
//  CreateMeditationView.swift
//  AuraFlow
//
//  Created by Ilya on 27.12.2024.
//

import SwiftUI


struct CreateMeditationView: View {
    @State private var selectedDuration = 5
    @State private var melodyPrompt = ""
    @State private var meditationPrompt = ""
    @State private var selectedVideo: VideoForGeneration? = nil
    
    let durations = [5, 10, 15, 20, 30, 45, 60]  // Available meditation durations
    @State private var duration: Double = 5
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {  // Adjusted spacing for better positioning closer to top
                
                // Title and Duration Controls
                HStack {
                    Text("Время медитации: \(Int(duration))" + " мин.")
                        .foregroundColor(.white)
                        .font(.system(size: 18)).bold()
                    
                    Button(action: {
                        if duration > 0 {
                            duration -= 1
                        }
                    }) {
                        Text("-")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white))
                    }
                    
                    Button(action: {
                        if duration < 30 {
                            duration += 1
                        }
                    }) {
                        Text("+")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(RoundedRectangle(cornerRadius: 10).strokeBorder(Color.white))
                    }
                }
                .padding(.top, 20)  // Adjusted top padding
                .padding(.leading, -60)
                
                // Melody Prompt Field
                VStack(alignment: .leading) {
                    Text("Выберите шаблон")
                        .foregroundColor(.white)
                        .font(.system(size: 18)).bold()

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(videosForGeneration, id: \.title) { video in
                                VideoCell(video: video, isSelected: video.title == selectedVideo?.title)
                                                                    .onTapGesture {
                                                                        // При тапе обновляем выбранное видео
                                                                        selectedVideo = video
                                                                    }

                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                    }
                    
                }
                .padding(.horizontal)
                .padding(.top, 10)  // Adjusted spacing to move it higher
                
                // Meditation Prompt Field
                VStack(alignment: .leading) {
                    Text("Какую вы бы хотели медитацию ?")
                        .foregroundColor(.white)
                        .font(.system(size: 18)).bold()
                    
                    ZStack(alignment: .leading) {
                        if meditationPrompt.isEmpty {
                            Text("Опишите свое состояние, и то какой результат вы хотите получить от медитации.")
                                .bold()
                                .foregroundColor(Color(uiColor: .lightGray))
                                .padding(.top, -40)
                            
                        }
                        TextEditor(text: $meditationPrompt)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).fill(Color.white))
                    .scrollContentBackground(.hidden)
                    .foregroundColor(.black)
                    
                    .frame(height: 130)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    
                    
                }
                
                
                .padding(.horizontal)
                .padding(.top, 10)  // Adjusted spacing to move it higher
                
                // Create Meditation Button
                Button(action: {
                    // Action to create meditation
                    print("Создание медитации с длительностью: \(selectedDuration) минут, промптом для мелодии: \(melodyPrompt), промптом для медитации: \(meditationPrompt)")
                }) {
                    Text("Создать медитацию")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).fill(Color.blue))
                        
               
                }
                .padding(.top, 20) // Adjusted padding for button positioning
                
                Spacer()
                
            }
            .padding(.top, -40)
            .background(
                Image("default")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            )
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Создай свою медитацию")
                        .font(Font.custom("Montserrat-Semibold", size: 20))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
        }
    }
}

#Preview {
    CreateMeditationView()
}

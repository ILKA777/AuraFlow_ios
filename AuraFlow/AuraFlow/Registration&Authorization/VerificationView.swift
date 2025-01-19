//
//  VerificationView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
//

import SwiftUI


struct VerificationView: View {
    @State private var verificationCode: [String] = Array(repeating: "", count: 6)
    @State private var timeRemaining: Int = 56
    @FocusState private var focusedField: Int? // Shared focus state for all fields
    @Environment(\.dismiss) private var dismiss
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
    @State private var navigateToProfile = false // State to trigger navigation
    
    @StateObject private var playbackManager = PlaybackManager.shared
    
    

    // State to track keyboard height
    @State private var keyboardHeight: CGFloat = 0

    // Timer to count down the remaining time
    private var timer: Timer.TimerPublisher {
        Timer.publish(every: 1, on: .main, in: .common)
    }

    var body: some View {
        ZStack {
            // Background image
            Image("default")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 40) {
                // Logo image
                Image("logo_login")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                    .padding(.top, 40)

                // Verification code text fields
                HStack(spacing: 10) {
                    ForEach(0..<6) { index in
                        TextField("", text: $verificationCode[index])
                            .frame(width: 51, height: 51)
                            .background(Circle().fill(Color(uiColor: .CalliopeWhite()).opacity(0.1)))
                            .foregroundColor(Color(uiColor: .CalliopeWhite()))
                            .font(Font.custom("Montserrat-Regular", size: 24))
                            .multilineTextAlignment(.center)
                            .keyboardType(.numberPad)
                            .focused($focusedField, equals: index)
                            .onChange(of: verificationCode[index]) { newValue in
                                if newValue.count > 1 {
                                    verificationCode[index] = String(newValue.prefix(1))
                                }
                                if newValue.count == 1 {
                                    moveToNextField(currentIndex: index)
                                }
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.gray, lineWidth: 1)
                            )
                            .overlay(
                                Text(verificationCode[index].isEmpty ? "_" : verificationCode[index])
                                    .font(.system(size: 24))
                                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                                    .opacity(0.8)
                            )
                    }
                }
                
                // Timer
                Text("00:\(timeRemaining, specifier: "%02d")")
                    .font(.system(size: 24))
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    .onReceive(timer) { _ in
                        if timeRemaining > 0 {
                            timeRemaining -= 1
                        }
                    }

                // Enter Button
                Button(action: {
                    loginUser()
                }) {
                    Text("Войти")
                        .font(Font.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(isCodeComplete() ? Color(uiColor: .AuraFlowBlue()) : Color.gray.opacity(0.5))
                        .cornerRadius(30)
                        .overlay(
                            RoundedRectangle(cornerRadius: 30)
                                .stroke(Color(.CalliopeWhite()), lineWidth: 1)
                        )
                }
                .frame(maxWidth: UIScreen.main.bounds.width - 32)
                .disabled(!isCodeComplete())
                .navigationDestination(isPresented: $navigateToProfile) {
                            ProfileView()
                        }


                Spacer()

                Button(action: {
                    dismiss()
                }) {
                    Text("Отмена")
                        .font(Font.custom("Montserrat-Regular", size: 18))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .cornerRadius(30)
                }
                .frame(maxWidth: UIScreen.main.bounds.width - 32)
                .padding(.bottom, 40)
            }
            .offset(y: UIScreen.main.bounds.height == 667 ? keyboardHeight / 2.25 : keyboardHeight / 2.30)
            .animation(.easeOut(duration: 0.3), value: keyboardHeight)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer() // Push the Done button to the right
                    Button("Готово") {
                        focusedField = nil // Dismiss the keyboard
                    }
                }
            }
        }
        .onAppear {
            playbackManager.isMiniPlayerVisible = false
            startTimer()
            focusedField = 0 // Focus on the first field when the view appears
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
            if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                withAnimation {
                    keyboardHeight = keyboardFrame.height
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { _ in
            withAnimation {
                keyboardHeight = 0
            }
        }
    }
    
    // Function to move to the next text field
    private func moveToNextField(currentIndex: Int) {
        if currentIndex < verificationCode.count - 1 {
            focusedField = currentIndex + 1
        } else {
            focusedField = nil // Dismiss the keyboard if the last field is filled
        }
    }

    // Check if the verification code is complete
    private func isCodeComplete() -> Bool {
        return verificationCode.allSatisfy { $0.count == 1 }
    }

    // Login the user and set isUserLoggedIn to true, navigate to ProfileView
    private func loginUser() {
        if isCodeComplete() {
            isUserLoggedIn = true
            navigateToProfile = true // Trigger navigation to ProfileView
        }
    }

    // Start the countdown timer
    private func startTimer() {
        _ = timer.connect()
    }
}

#Preview {
    VerificationView()
}

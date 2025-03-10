//
//  ContentView.swift
//  AuraFlow
//
//  Created by Ilya on 26.12.2024.
//

import SwiftUI
import CoreData
import FLEX

struct ContentView: View {
    @State private var showSplash = true
    @State private var isAnimated = false
    @State private var shouldShowOnboarding: Bool = {
        let hasShownOnboarding = UserDefaults.standard.bool(forKey: "hasShownOnboarding")
        if !hasShownOnboarding {
            UserDefaults.standard.set(true, forKey: "hasShownOnboarding")
            return true
        }
        return false
    }()

    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(2)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1.5)) {
                            isAnimated = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                showSplash = false
                            }
                        }
                    }
            } else {
                if shouldShowOnboarding {
                    OnboardingMainView()
                        .transition(.slide)
                        .onDisappear {
                            UserDefaults.standard.set(false, forKey: "hasShownOnboarding")
                        }
                        .zIndex(1)
                } else {
                    TabBarView()
                        .zIndex(0)
                }
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut, value: showSplash || shouldShowOnboarding)
    }
}

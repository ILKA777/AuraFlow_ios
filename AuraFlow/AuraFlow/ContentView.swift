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
    @State private var shouldShowOnboarding = true

    var body: some View {
        NavigationView {
            ZStack {
                if showSplash {
                    SplashScreenView()
                        .opacity(isAnimated ? 1 : 0)
                        .onAppear {
                            withAnimation(.easeInOut(duration: 1.5)) {
                                isAnimated = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                withAnimation(.easeInOut(duration: 1.5)) {
                                    showSplash = false
                                }
                            }
                        }
                } else {
                    if shouldShowOnboarding {
                        OnboardingMainView()
                    } else {
                        //MainView()
                        TabBarView()
                    }
                }
            }
        }.onAppear {
            // Swift
            FLEXManager.shared.showExplorer()
        }
    }
}

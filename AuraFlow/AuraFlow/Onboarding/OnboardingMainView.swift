//
//  OnboardingMainView.swift
//  Calliope
//
//  Created by Илья on 30.07.2024.
//

import SwiftUI

struct OnboardingMainView: View {
    
    @StateObject var viewModel = OnboardingMainViewModel()
    @State private var onboardingIndex = 0
    
    var body: some View {
        OnboardingSliderView(index: $onboardingIndex) {
            ForEach(viewModel.onboardingData.indices, id: \.self) { i in
                OnboardingItemView(
                    data: viewModel.onboardingData[i],
                    isLastSlide: i == viewModel.onboardingData.count - 1
                )
            }
        }
        .environmentObject(viewModel)
        .onAppear {
            viewModel.fillData()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    OnboardingMainView()
}

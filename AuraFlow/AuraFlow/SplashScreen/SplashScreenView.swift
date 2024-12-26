//
//  SplashScreenView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
//

import SwiftUI

struct SplashScreenView: View {
    var body: some View {
        ZStack {
            Color(uiColor: .CalliopeBlack()).edgesIgnoringSafeArea(.all)
            
            Image("Load")
                .resizable()
                .frame(minWidth: 0, maxWidth: .infinity)
                .edgesIgnoringSafeArea(.all)
            
//            Image("Logo_Calliope")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .frame(width: 300, height: 300)
        }
    }
}

struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
    }
}

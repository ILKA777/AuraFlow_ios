//
//  CreateMeditationView.swift
//  AuraFlow
//
//  Created by Ilya on 27.12.2024.
//

//
//  CreateMeditationView.swift
//  AuraFlow
//
//  Created by Ilya on 27.12.2024.
//

import SwiftUI
import WebKit

struct CreateMeditationWebView: UIViewRepresentable {
    let urlString: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Здесь можно обновить WebView, если потребуется
    }
}

struct CreateMeditationView: View {
    var body: some View {
        NavigationStack {
            CreateMeditationWebView(urlString: "https://giga.chat/gigachat/48d41e1e-8981-4060-8df9-44f29718db9e/home?openMeditation=new&utm_source=catalog&utm_medium=owned")
                .edgesIgnoringSafeArea(.all) // WebView занимает весь экран
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Создай свою медитацию")
                            .font(Font.custom("Montserrat-Semibold", size: 20))
                            .foregroundColor(.white)
                    }
                }
        }
    }
}

#Preview {
    CreateMeditationView()
}

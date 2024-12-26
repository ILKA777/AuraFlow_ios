//
//  CustomHostingController.swift
//  Calliope
//
//  Created by Ilya on 01.11.2024.
//


import SwiftUI

class CustomHostingController<Content>: UIHostingController<Content> where Content: View {
    override func viewWillLayoutSubviews() {
        // Не вызываем super.viewWillLayoutSubviews(), чтобы отключить поведение избегания клавиатуры
    }
}

struct HostingControllerWrapper<Content: View>: UIViewControllerRepresentable {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    func makeUIViewController(context: Context) -> CustomHostingController<Content> {
        CustomHostingController(rootView: content)
    }

    func updateUIViewController(_ uiViewController: CustomHostingController<Content>, context: Context) {
        uiViewController.rootView = content
    }
}

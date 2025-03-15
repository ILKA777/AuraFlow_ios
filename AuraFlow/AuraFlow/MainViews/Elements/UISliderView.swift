//
//  UISliderView.swift
//  AuraFlow
//
//  Created by Ilya on 15.03.2025.
//

import SwiftUI

struct UISliderView: UIViewRepresentable {
    @Binding var value: Double
    
    var minValue: Double = 0.0
    var maxValue: Double  // Передаем правильную продолжительность трека
    var thumbColor: UIColor = .clear
    var minTrackColor: UIColor = .yellow
    var maxTrackColor: UIColor = .lightGray
    
    class Coordinator: NSObject {
        var value: Binding<Double>
        let slider: UISlider
        
        init(value: Binding<Double>, slider: UISlider) {
            self.value = value
            self.slider = slider
        }
        
        @objc func valueChanged(_ sender: UISlider) {
            self.value.wrappedValue = Double(sender.value)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        let slider = UISlider(frame: .zero)
        return Coordinator(value: $value, slider: slider)
    }
    
    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        
        let slider = context.coordinator.slider
        slider.minimumValue = Float(minValue)
        slider.maximumValue = Float(maxValue)
        slider.value = Float(value)
        slider.minimumTrackTintColor = minTrackColor
        slider.maximumTrackTintColor = maxTrackColor
        slider.thumbTintColor = thumbColor
        
        slider.addTarget(context.coordinator, action: #selector(Coordinator.valueChanged(_:)), for: .valueChanged)
        
        containerView.addSubview(slider)
        slider.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            slider.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            slider.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            slider.widthAnchor.constraint(equalTo: containerView.widthAnchor)
        ])
        
        return containerView
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        if let slider = context.coordinator.slider as? UISlider {
            slider.value = Float(value)
            slider.maximumValue = Float(maxValue)  // Обновляем максимальное значение только после загрузки трека
        }
    }
}

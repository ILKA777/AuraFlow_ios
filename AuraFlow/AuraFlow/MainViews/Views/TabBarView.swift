//
//  TabBarView.swift
//  AuraFlow
//
//  Created by Ilya on 27.12.2024.
//

import SwiftUI

struct TabBarView: View {
    @State private var selectedTab: Tab = .main
    
    enum Tab {
        case main, createMeditation, myMeditations, profile
    }
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground() // Устанавливает дефолтный стиль
        
        // Установка цвета фона
        appearance.backgroundColor = UIColor.systemGray.withAlphaComponent(0.2) // Полупрозрачный серый
        
        // Настройка стиля для табов
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.selected.iconColor = UIColor.white // Цвет иконки для выбранного таба
        itemAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor.white // Цвет текста для выбранного таба
        ]
        itemAppearance.normal.iconColor = UIColor.gray // Цвет иконки для невыбранного таба
        itemAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor.gray // Цвет текста для невыбранного таба
        ]
        
        appearance.stackedLayoutAppearance = itemAppearance // Применяем стиль для табов
        
        UITabBar.appearance().standardAppearance = appearance
        
        // Для iOS 15+ настраиваем scrollEdgeAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            MainView(selectedTab: $selectedTab) // Передаем binding
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Главная")
                }
                .tag(Tab.main)
            
            CreateMeditationView()
                .tabItem {
                    Image(systemName: "plus.circle")
                    Text("Создай медитацию")
                }
                .tag(Tab.createMeditation)
            
            MyMeditationsView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Мои медитации")
                }
                .tag(Tab.myMeditations)
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.circle")
                    Text("Профиль")
                }
                .tag(Tab.profile)
        }
    }
}

#Preview {
    TabBarView()
}

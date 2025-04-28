//
//  SubscriptionView.swift
//  Calliope
//
//  Created by Илья on 06.08.2024.
//

import SwiftUI

struct SubscriptionView: View {
    // Получаем токен через NetworkService
    private var authToken: String? { NetworkService.shared.getAuthToken() }
    
    @State private var isSubscriptionActive = false
    @State private var isShowingSubscriptionAlert = false
    @State private var isShowingCancelAlert = false
    @State private var subscriptionEndDate: Date? = nil
    @Environment(\.dismiss) private var dismiss

    // Генерация ключей в UserDefaults на основе токена
    private var subscriptionKey: String { "subscription_\(authToken ?? "")" }
    private var subscriptionEndKey: String { "subscriptionEnd_\(authToken ?? "")" }

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Подписка")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    Spacer()
                }

                HStack {
                    Text(isSubscriptionActive && subscriptionEndDate != nil ?
                         "Активна до \(formattedDate(subscriptionEndDate!))" :
                         "Подписка неактивна")
                        .font(.system(size: 16))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { isSubscriptionActive },
                        set: { newValue in
                            if newValue {
                                isShowingSubscriptionAlert = true
                            } else {
                                isShowingCancelAlert = true
                            }
                        }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: Color.green))
                    .labelsHidden()
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(uiColor: .CalliopeBlack()).opacity(0.2))
            )
            .padding(.horizontal)
            .offset(y: 20)

            NavigationLink(destination: PurchaseHistoryView()) {
                HStack {
                    Text("История покупок")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20))
                        .foregroundColor(Color(uiColor: .CalliopeWhite()).opacity(0.7))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(uiColor: .CalliopeBlack()).opacity(0.2))
                )
            }
            .padding(.horizontal)
            .offset(y: 20)

            Spacer()
        }
        .background(
            Image("default")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Подписка и покупки")
                    .font(.headline)
                    .foregroundColor(Color(uiColor: .CalliopeWhite()))
            }
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(uiColor: .CalliopeWhite()))
                }
            }
        }
        .tint(Color(uiColor: .CalliopeWhite()))
        // Загрузка состояния при появлении и при смене токена
        .onAppear(perform: loadSubscriptionState)
        .onChange(of: authToken) { _ in loadSubscriptionState() }
        // Сохранение при изменении флага
        .onChange(of: isSubscriptionActive) { _ in saveSubscriptionState() }
        
        // Алерт оформления подписки
        .alert("Оформление подписки", isPresented: $isShowingSubscriptionAlert) {
            Button("Да, оформить !") {
                let endDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())
                subscriptionEndDate = endDate
                isSubscriptionActive = true
            }
            Button("Отмена", role: .cancel) {
                isSubscriptionActive = false
                subscriptionEndDate = nil
            }
        } message: {
            Text("Вы желаете оформить подписку на месяц за 399 рублей ?")
        }
        // Алерт отмены подписки
        .alert("Внимание !", isPresented: $isShowingCancelAlert) {
            Button("Да, отменить !", role: .destructive) {
                isSubscriptionActive = false
                subscriptionEndDate = nil
            }
            Button("Нет, оставить !", role: .cancel) {
                isSubscriptionActive = true
            }
        } message: {
            Text("Вы точно желаете отменить действующую подписку ?")
        }
    }
    
    /// Загрузка состояния подписки из UserDefaults
    private func loadSubscriptionState() {
        guard let token = authToken, !token.isEmpty else {
            isSubscriptionActive = false
            subscriptionEndDate = nil
            return
        }
        let defaults = UserDefaults.standard
        isSubscriptionActive = defaults.bool(forKey: subscriptionKey)
        subscriptionEndDate = defaults.object(forKey: subscriptionEndKey) as? Date
    }
    
    /// Сохранение состояния подписки
    private func saveSubscriptionState() {
        guard let token = authToken, !token.isEmpty else { return }
        let defaults = UserDefaults.standard
        defaults.set(isSubscriptionActive, forKey: subscriptionKey)
        if let end = subscriptionEndDate, isSubscriptionActive {
            defaults.set(end, forKey: subscriptionEndKey)
        } else {
            defaults.removeObject(forKey: subscriptionEndKey)
        }
    }
}

fileprivate extension SubscriptionView {
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationStack {
        SubscriptionView()
    }
}


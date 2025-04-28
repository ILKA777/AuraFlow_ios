//
//  UserProfileView.swift
//  Calliope
//
//  Created by Илья on 05.08.2024.
//

import SwiftUI
import CoreData

struct UserInfoCellView: View {
    let user: User
    @AppStorage("isUserLoggedIn") private var isUserLoggedIn = false
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = RegistrationAndAuthorizationViewModel()
    
    var body: some View {
        HStack(spacing: 16) {
            // Profile Image
            Image(user.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 60, height: 60)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(uiColor: .CalliopeBlack()), lineWidth: 2)
                )

            // User Details
            VStack(alignment: .leading, spacing: 4) {
                Text(user.name)
                    .font(Font.custom("Montserrat-SemiBold", size: 20))
                    .foregroundColor(Color(uiColor: .CalliopeBlack()))
                
                Text(user.email)
                    .font(Font.custom("Montserrat-Regular", size: 16))
                    .foregroundColor(Color(uiColor: .CalliopeBlack()))
            }
            
            Spacer()
            
            // Logout Button
            Button(action: {
                logoutUser()
            }) {
                Image(systemName: "arrow.turn.down.right")
                    .font(.system(size: 20))
                    .foregroundColor(Color(uiColor: .CalliopeBlack()))
            }
        }
        .padding()
        .background(
            Color(uiColor: .AuraFlowBlue())
            .clipShape(RoundedRectangle(cornerRadius: 20))
        )
        .shadow(color: Color(uiColor: .CalliopeBlack()).opacity(0.1), radius: 5, x: 0, y: 4)
    }
    
    // Logout function that clears Core Data and logs the user out
    private func logoutUser() {
        // 1) Remove the token from the Keychain
        KeychainService.shared.delete()  // or whatever your API for removing the token is

        // 2) Clear Core Data (your existing code)
        clearUserData()

        // 3) Reset login state
        isUserLoggedIn = false

        // 4) Clear in-memory and on-disk favorites
        FavoritesManager.shared.clearAll()

        // 5) Clear in-memory and on-disk generated meditations
        GeneratedMeditationsManager.shared.clearAll()

        print("User logged out successfully.")
    }

    
    // Clear user data from Core Data
    // В функции clearUserData()
    private func clearUserData() {
        let context = CoreDataManager.shared.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "UserCoreData")
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            try context.save()  // Сохраняем изменения в контексте после удаления
            print("User data cleared from Core Data.")
        } catch {
            print("Failed to clear user data: \(error.localizedDescription)")
        }
    }


}

#Preview {
    UserInfoCellView(
        user: User(
            name: "Лилия",
            email: "test@mail.ru",
            imageName: "meditationPerson"
        )
    )
}

//
//  CoreDataManager.swift
//  Calliope
//
//  Created by Ilya on 21.10.2024.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "AuraFlow")
        persistentContainer.loadPersistentStores { (description, error) in
            if let error = error {
                fatalError("Unable to initialize Core Data: \(error)")
            }
        }
    }
    
    func saveUser(name: String, email: String) {
        let context = persistentContainer.viewContext
        let user = UserCoreData(context: context)
        user.name = name
        user.email = email
        user.imageName = "meditationPerson"
        
        do {
            try context.save()
        } catch {
            print("Failed to save user: \(error)")
        }
    }
    
    func fetchUser() -> UserCoreData? {
        let context = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<UserCoreData> = UserCoreData.fetchRequest()
        
        do {
            let users = try context.fetch(fetchRequest)
            return users.first
        } catch {
            print("Failed to fetch user: \(error)")
            return nil
        }
    }
}

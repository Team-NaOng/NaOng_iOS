//
//  ToDoCoreDataManager.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/13.
//

import CoreData

class ToDoCoreDataManager: ObservableObject {
    let persistentContainer: NSPersistentContainer
    static let shared = ToDoCoreDataManager()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "ToDoModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                print("❌ TODO: 에러 메세지 수정 / \(error)")
            }
        }
    }
}

//
//  LocationCoreDataManager.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import Foundation
import CoreData

class LocationCoreDataManager: ObservableObject {
    let persistentContainer: NSPersistentContainer
    static let shared = LocationCoreDataManager()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "LocationModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("fail To loadPersistentStores.")
            }
        }
    }
}

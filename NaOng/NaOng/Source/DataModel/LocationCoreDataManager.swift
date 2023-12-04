//
//  LocationCoreDataManager.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import CoreData
import os.log

class LocationCoreDataManager {
    let persistentContainer: NSPersistentContainer
    static let shared = LocationCoreDataManager()
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "LocationModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                let osLog = OSLog(subsystem: "Seohyeon.NaOng", category: "CoreData")
                let log = Logger(osLog)
                log.log(level: .error, "LocationCoreData Error: \(error.localizedDescription)")
            }
        }
    }
}

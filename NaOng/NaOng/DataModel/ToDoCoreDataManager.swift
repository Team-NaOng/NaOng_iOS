//
//  ToDoCoreDataManager.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/13.
//

import CoreData
import os.log

class ToDoCoreDataManager {
    let persistentContainer: NSPersistentContainer
    
    init() {
        persistentContainer = NSPersistentContainer(name: "ToDoModel")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                let osLog = OSLog(subsystem: "Seohyeon.NaOng", category: "CoreData")
                let log = Logger(osLog)
                log.log(level: .error, "ToDoCoreData Error: \(error.localizedDescription)")
            }
        }
    }
}

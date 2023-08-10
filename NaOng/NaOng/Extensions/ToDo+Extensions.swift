//
//  ToDo+Extensions.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/16.
//

import CoreData

extension ToDo: CoreDataBaseProtocol {
    typealias ManagedObject = ToDo

    static var viewContext: NSManagedObjectContext {
        ToDoCoreDataManager.shared.persistentContainer.viewContext
    }
}

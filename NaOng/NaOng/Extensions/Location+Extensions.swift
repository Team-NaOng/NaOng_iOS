//
//  Location+Extensions.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import CoreData

extension Location: CoreDataBaseProtocol {
    typealias ManagedObject = Location

    static var viewContext: NSManagedObjectContext {
        LocationCoreDataManager.shared.persistentContainer.viewContext
    }
}

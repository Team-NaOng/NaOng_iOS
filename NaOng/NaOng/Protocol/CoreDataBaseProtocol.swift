//
//  CoreDataBaseProtocol.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import CoreData

protocol CoreDataBaseProtocol {
    associatedtype ManagedObject: NSManagedObject
    
    func save(viewContext: NSManagedObjectContext) throws
    func delete(viewContext: NSManagedObjectContext) throws
    static func deleteAll(viewContext: NSManagedObjectContext) throws
    static func all() -> NSFetchRequest<ManagedObject>?
}

extension CoreDataBaseProtocol {
    func save(viewContext: NSManagedObjectContext) throws {
        try viewContext.save()
    }

    func delete(viewContext: NSManagedObjectContext) throws {
        guard let managedObject = self as? NSManagedObject else {
            throw CoreDataError.invalidManagedObject
        }
        viewContext.delete(managedObject)
        try save(viewContext: viewContext)
    }
    
    static func deleteAll(viewContext: NSManagedObjectContext) throws {
        let fetchRequest = ManagedObject.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        try viewContext.execute(deleteRequest)
        try viewContext.save()
    }
    
    static func all() -> NSFetchRequest<ManagedObject>? {
        let request = ManagedObject.fetchRequest() as? NSFetchRequest<ManagedObject>
        request?.sortDescriptors = []
        return request
    }
}

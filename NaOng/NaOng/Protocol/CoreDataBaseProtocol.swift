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
        let request = fetchRequest(ManagedObject.self)
        request?.sortDescriptors = []
        return request
    }
    
    private static func fetchRequest<T: NSManagedObject>(_ type: T.Type) -> NSFetchRequest<T>? {
        return T.fetchRequest() as? NSFetchRequest<T>
    }
}

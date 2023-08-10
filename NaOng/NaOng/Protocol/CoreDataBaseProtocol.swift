//
//  CoreDataBaseProtocol.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import CoreData

protocol CoreDataBaseProtocol {
    associatedtype ManagedObject: NSManagedObject
    
    static var viewContext: NSManagedObjectContext { get }
    
    func save() throws
//    func delete() throws
    static func all() -> NSFetchRequest<ManagedObject>?
}

extension CoreDataBaseProtocol {
    func save() throws {
        try Self.viewContext.save()
    }
//
//    func delete() throws {
//        guard let managedObject = self as? NSManagedObject else {
//            throw CoreDataError.invalidManagedObject
//        }
//        Self.viewContext.delete(managedObject)
//        try save()
//    }
    
    static func all() -> NSFetchRequest<ManagedObject>? {
        let request = fetchRequest(ManagedObject.self)
        request?.sortDescriptors = []
        return request
    }
    
    private static func fetchRequest<T: NSManagedObject>(_ type: T.Type) -> NSFetchRequest<T>? {
        return T.fetchRequest() as? NSFetchRequest<T>
    }
}

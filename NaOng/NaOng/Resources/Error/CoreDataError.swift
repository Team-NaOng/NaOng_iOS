//
//  CoreDataError.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import Foundation

enum CoreDataError: Error {
    case failToSave
    case invalidManagedObject
    case invalidFetchRequest
}

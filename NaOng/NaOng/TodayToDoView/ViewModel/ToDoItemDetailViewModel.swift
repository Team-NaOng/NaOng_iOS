//
//  ToDoItemDetailViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/31.
//

import Foundation
import CoreData

class ToDoItemDetailViewModel: ObservableObject {
    @Published var content: String
    @Published var alarmType: String
    @Published var alarmTime: Date
    @Published var isRepeat: Bool
    
    private var toDoItem: ToDo
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext, toDoItem: ToDo) {
        self.viewContext = viewContext
        self.toDoItem = toDoItem
        
        self.content = self.toDoItem.content ?? ""
        self.alarmType = self.toDoItem.alarmType ?? "위치"
        self.alarmTime = self.toDoItem.alarmTime ?? Date()
        self.isRepeat = self.toDoItem.isRepeat
    }
    
    func EditToDo() {
        do {
            toDoItem.content = content
            toDoItem.alarmType = alarmType
            toDoItem.alarmTime = alarmTime
            toDoItem.isRepeat = isRepeat
            
            try toDoItem.save(viewContext: viewContext)
        } catch {
            print("error!")
        }
    }
}

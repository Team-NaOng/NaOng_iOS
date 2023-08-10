//
//  ToDoItemAddViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/07.
//

import Foundation
import CoreData

class ToDoItemAddViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var alarmTime: Date = Date()
    @Published var isRepeat: Bool = false
    @Published var alarmType: String = "위치"

    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func addToDo() {
        do {
            let toDoItem = ToDo(context: viewContext)
            toDoItem.id = UUID()
            toDoItem.isDone = false
            toDoItem.content = content
            toDoItem.alarmType = alarmType
            toDoItem.alarmTime = alarmTime
            toDoItem.isRepeat = isRepeat
            
            toDoItem.alarmDate = alarmTime.getFormatDate()

            try toDoItem.save()
            scheduleNotification(for: toDoItem)
        } catch {
            print("error!")
        }
    }
    
    private func scheduleNotification(for toDoItem: ToDo) {
        if toDoItem.alarmType == "위치" {
            NotificationManager.shared.setLocalNotification(toDo: toDoItem)
        } else {
            NotificationManager.shared.setCalendarNotification(toDo: toDoItem)
        }
    }
}

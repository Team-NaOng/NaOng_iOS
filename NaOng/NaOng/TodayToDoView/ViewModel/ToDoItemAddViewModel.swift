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
    @Published var location: String = "위치를 선택해 주세요"

    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func addToDo() {
        do {
            let toDoItem = ToDo(context: viewContext)
            toDoItem.id = UUID().uuidString
            toDoItem.isDone = false
            toDoItem.isNotificationVisible = true
            toDoItem.content = content
            toDoItem.alarmType = alarmType
            toDoItem.alarmTime = alarmTime
            toDoItem.isRepeat = isRepeat
            
            toDoItem.alarmDate = alarmTime.getFormatDate()

            try toDoItem.save(viewContext: viewContext)
            scheduleNotification(for: toDoItem)
        } catch {
            print("error!")
        }
    }
    
    private func scheduleNotification(for toDoItem: ToDo) {
        if toDoItem.alarmType == "위치" {
            LocalNotificationManager().setLocalNotification(toDo: toDoItem)
        } else {
            LocalNotificationManager().setCalendarNotification(toDo: toDoItem)
        }
    }
}

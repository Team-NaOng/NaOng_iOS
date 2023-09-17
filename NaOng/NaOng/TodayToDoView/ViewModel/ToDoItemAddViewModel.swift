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
    @Published var coordinates: Coordinates = Coordinates(lat: 0.0, lon: 0.0)
    @Published var path: [LocationViewStack] = [LocationViewStack]()

    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    func addPath(_ addedView: LocationViewStack) {
        path.append(addedView)
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
            toDoItem.alarmLocationLatitude = coordinates.lat
            toDoItem.alarmLocationLongitude = coordinates.lon
            toDoItem.alarmDate = alarmTime.getFormatDate()

            try toDoItem.save(viewContext: viewContext)
            scheduleNotification(for: toDoItem)
        } catch {
            print("error!")
        }
    }
    
    func addLocation() {
        if alarmType != "위치" {
            return
        }

        do {
            let locationViewContext = Location.viewContext
            let location = Location(context: locationViewContext)
            location.id = UUID().uuidString
            location.address = self.location
            location.latitude = coordinates.lat
            location.longitude = coordinates.lon

            try location.save(viewContext: locationViewContext)
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

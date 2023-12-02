//
//  ToDoListItemViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/16.
//

import Foundation
import CoreData

class ToDoItemViewModel: ObservableObject {
    @Published var markerName: String = "doneMarker"
    @Published var backgroundColor: String = "white"
    @Published var showErrorAlert = false
    var errorTitle: String = ""
    var errorMessage: String = ""
    
    private(set) var toDoItem: ToDo
    private let viewContext: NSManagedObjectContext
    private let localNotificationManager: LocalNotificationManager

    init(toDoItem: ToDo, viewContext: NSManagedObjectContext, localNotificationManager: LocalNotificationManager) {
        self.toDoItem = toDoItem
        self.viewContext = viewContext
        self.localNotificationManager = localNotificationManager

        setMarkerName()
        setBackgroundColor()
    }

    func didTapDoneButton() {
        do {
            if toDoItem.isRepeat {
                if let doneList = toDoItem.doneList {
                    toDoItem.doneList = [Date()] + doneList
                } else {
                    toDoItem.doneList = [Date()]
                }
            } else {
                let isDone = toDoItem.isDone ? false : true
                toDoItem.isDone = isDone
                toDoItem.doneList = [Date()]
            }
            
            try toDoItem.save(viewContext: viewContext)
        } catch {
            errorTitle = "할 일 완료 실패🥲"
            errorMessage = error.localizedDescription
            showErrorAlert.toggle()
        }

        guard let id = toDoItem.id else {
            return
        }
        
        if toDoItem.isDone {
            localNotificationManager.removeNotification(id: id)
        } else if toDoItem.isDone == false && toDoItem.isRepeat == false {
            localNotificationManager.scheduleNotification(for: toDoItem)
        }
    }

   func setMarkerName() {
        if toDoItem.isDone {
            markerName = "doneMarker"
            return
        }

        switch toDoItem.alarmType {
        case "위치":
            markerName = "locationMarker"
        case "시간":
            markerName = "timeMarker"
        default:
            markerName = "doneMarker"
        }
    }

    func setBackgroundColor() {
        if toDoItem.isDone {
            backgroundColor = "primary"
            return
        }

        backgroundColor = "white"
    }
    
    func getDistinguishedAlarmInformation() -> String {
        switch toDoItem.alarmType {
        case "위치":
            return "위치"
        default:
            return getAlarmTime()
        }
    }
    
    private func getAlarmTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        let alarmTime = toDoItem.alarmTime ?? Date()
        return dateFormatter.string(from: alarmTime)
    }
}

//
//  ToDoListItemViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/16.
//

import Foundation
import CoreData

class ToDoListItemViewModel: ObservableObject {
    @Published var markerName: String = "doneMarker"
    @Published var backgroundColor: String = "white"
    
    private(set) var toDoItem: ToDo

    init(toDoItem: ToDo) {
        self.toDoItem = toDoItem

        setMarkerName()
        setBackgroundColor()
    }

    func didTapDoneButton() {
        do {
            let currentToDoItem = toDoItem
            let isDone = currentToDoItem.isDone ? false : true
            currentToDoItem.isDone = isDone
            
            try currentToDoItem.save()
        } catch {
            print("error!")
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
            return getAlarmLocation()
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
    
    private func getAlarmLocation() -> String {
        // 수정
        return "위치"
    }
}

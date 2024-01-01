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
    
    private(set) var toDoItem: ToDo
    private let viewContext: NSManagedObjectContext
    private let localNotificationManager: LocalNotificationManager
    private let alertViewModel: AlertViewModel

    init(toDoItem: ToDo, viewContext: NSManagedObjectContext, localNotificationManager: LocalNotificationManager, alertViewModel: AlertViewModel) {
        self.toDoItem = toDoItem
        self.viewContext = viewContext
        self.localNotificationManager = localNotificationManager
        self.alertViewModel = alertViewModel

        setMarkerName()
        setBackgroundColor()
    }

    func didTapDoneButton() {
        do {
            updateDoneList()
            updateIsDone()

            try toDoItem.save(viewContext: viewContext)
            
            showRepeatCompletionAlert()
            manageLocalNotifications()
        } catch {
            showErrorAlert(error)
        }
    }

   func setMarkerName() {
       if toDoItem.isDone || toDoItem.isRepeat {
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
    
    private func updateDoneList() {
        if toDoItem.isRepeat, let doneList = toDoItem.doneList {
            toDoItem.doneList = [Date()] + doneList
        } else {
            toDoItem.doneList = [Date()]
        }
    }
    
    private func updateIsDone() {
        if toDoItem.isRepeat == false {
            toDoItem.isDone.toggle()
        }
    }
    
    private func manageLocalNotifications() {
        guard let id = toDoItem.id else {
            return
        }
        
        if toDoItem.isDone {
            localNotificationManager.removeNotification(id: id)
        } else if toDoItem.isDone == false && toDoItem.isRepeat == false {
            localNotificationManager.scheduleNotification(for: toDoItem)
        }
    }
    
    private func showErrorAlert(_ error: Error) {
        alertViewModel.alertTitle = "할 일 완료 실패🥲"
        alertViewModel.alertMessage = error.localizedDescription
        alertViewModel.isShowingAlert.toggle()
    }
    
    private func showRepeatCompletionAlert() {
        if toDoItem.isRepeat {
            alertViewModel.alertTitle = "할 일 완료🥳"
            
            let messages = [
                "오늘도 멋지게 하루를 마무리했네요!",
                "당신의 노력이 빛을 발하고 있어요. 멋져요!",
                "할 일을 끝마치는 감각은 최고죠! 오늘도 고생하셨어요.",
                "오늘 완료한 일은 내일의 당신을 더 강하게 만들 거예요.",
                "오늘도 한걸음 나아간 당신! 너무 대단해요!"
            ]
            alertViewModel.alertMessage = messages.randomElement() ?? "할 일을 잘 끝낸 당신은 정말 최고예요!"

            alertViewModel.isShowingAlert.toggle()
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

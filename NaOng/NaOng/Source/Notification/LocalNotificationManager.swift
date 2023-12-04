//
//  LocalNotificationManager.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/06.
//

import UserNotifications
import Combine
import os.log

class LocalNotificationManager: NSObject, ObservableObject {
    var authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }
    var removalAllNotificationsPublisher: AnyPublisher<Bool, Never> {
        removalAllNotificationsSubject.eraseToAnyPublisher()
    }
    
    private var authorizationStatusSubject = PassthroughSubject<UNAuthorizationStatus, Never>()
    private var removalAllNotificationsSubject = PassthroughSubject<Bool, Never>()
    
    func sendAuthorizationStatusEvent() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatusSubject.send(settings.authorizationStatus)
            }
        }
    }

    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                let osLog = OSLog(subsystem: "Seohyeon.NaOng", category: "Notification")
                let log = Logger(osLog)
                log.log(level: .error, "requestAuthorization Error: \(error.localizedDescription)")
            }
        }
    }

    func scheduleNotification(for toDoItem: ToDo) {
        if toDoItem.alarmType == "위치" {
            setLocationNotification(toDo: toDoItem)
        } else {
            setCalendarNotification(toDo: toDoItem)
        }
    }

    func editLocalNotification(toDoItem:ToDo) {
        guard let id = toDoItem.id else {
            return
        }

        removeNotification(id: id)
        scheduleNotification(for: toDoItem)
    }

    func removeNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [id])
    }

    private func setCalendarNotification(toDo:ToDo) {
        guard let date = toDo.alarmTime else {
            return
        }
        
        let content = getNotificationContent(
            subtitle: toDo.content,
            categoryIdentifier: toDo.alarmTime?.description ?? "",
            badge: nil)
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: toDo.isRepeat)
        let request = UNNotificationRequest(
            identifier: toDo.id ?? UUID().uuidString,
            content: content,
            trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    private func setLocationNotification(toDo:ToDo) {
        let content = getNotificationContent(
            subtitle: toDo.content,
            categoryIdentifier: toDo.alarmTime?.description ?? "",
            badge: nil)
        let region = LocationService.shared.getCircularRegion(
            latitude: toDo.alarmLocationLatitude,
            longitude: toDo.alarmLocationLongitude,
            identifier: toDo.id ?? UUID().uuidString)
        let trigger = UNLocationNotificationTrigger(
            region: region,
            repeats: toDo.isRepeat)
        let request = UNNotificationRequest(
            identifier: toDo.id ?? UUID().uuidString,
            content: content,
            trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }
    
    private func getNotificationContent(subtitle: String?, categoryIdentifier: String, badge: NSNumber? = nil) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "나옹"
        content.subtitle = subtitle ?? "할 일 했나옹?"
        content.sound = .default
        content.badge = badge
        content.categoryIdentifier = categoryIdentifier
        
        return content
    }
}

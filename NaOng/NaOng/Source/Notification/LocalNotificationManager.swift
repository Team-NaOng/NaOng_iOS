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
    var deliveredNotificationsPublisher: AnyPublisher<[String], Never> {
        deliveredNotificationsSubject.eraseToAnyPublisher()
    }
    var authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }
    var removalNotificationsPublisher: AnyPublisher<Bool, Never> {
        removalNotificationsSubject.eraseToAnyPublisher()
    }
    var removalAllNotificationsPublisher: AnyPublisher<Bool, Never> {
        removalAllNotificationsSubject.eraseToAnyPublisher()
    }
    
    private var deliveredNotificationsSubject = PassthroughSubject<[String], Never>()
    private var authorizationStatusSubject = PassthroughSubject<UNAuthorizationStatus, Never>()
    private var removalNotificationsSubject = PassthroughSubject<Bool, Never>()
    private var removalAllNotificationsSubject = PassthroughSubject<Bool, Never>()
    
    private var previousPendingNotificationsID: [String] {
        get {
            return UserDefaults.standard.array(forKey: UserDefaultsKey.previousPendingNotificationsID) as? [String] ?? [ ]
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: UserDefaultsKey.previousPendingNotificationsID)
        }
    }
    
    func sendAuthorizationStatusEvent() {
        UNUserNotificationCenter.current().getNotificationSettings { [weak self] settings in
            DispatchQueue.main.async {
                self?.authorizationStatusSubject.send(settings.authorizationStatus)
            }
        }
    }
    
    func sendRemovedEvent() {
        removalNotificationsSubject.send(true)
    }
    
    func sendAllRemoveEvent() {
        removalAllNotificationsSubject.send(true)
    }

    func sendDeliveredEvent() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] notifications in
            let notificationsID = notifications.map { $0.identifier }

            if let sendID = self?.previousPendingNotificationsID.filter({ notificationsID.contains($0) == false }) {
                self?.deliveredNotificationsSubject.send(sendID)
            }

            self?.previousPendingNotificationsID = notificationsID
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

        sendRemovedEvent()
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
        previousPendingNotificationsID.append(request.identifier)
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
        previousPendingNotificationsID.append(request.identifier)
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

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        deliveredNotificationsSubject.send([notification.request.identifier])
 
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        deliveredNotificationsSubject.send([notification.request.identifier])

        let options: UNNotificationPresentationOptions = [.banner, .badge, .sound]
        completionHandler(options)
    }
}


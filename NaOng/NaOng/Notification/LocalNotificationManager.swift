//
//  LocalNotificationManager.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/06.
//

import UserNotifications
import UIKit
import Combine

class LocalNotificationManager: NSObject, ObservableObject {
    var previousPendingNotifications = [UNNotificationRequest]()
    var deliveredNotificationsPublisher: AnyPublisher<[String], Never> {
        deliveredNotificationsSubject.eraseToAnyPublisher()
    }
    var authorizationStatusPublisher: AnyPublisher<UNAuthorizationStatus, Never> {
        authorizationStatusSubject.eraseToAnyPublisher()
    }
    var removalNotificationsPublisher: AnyPublisher<Bool, Never> {
        removalNotificationsSubject.eraseToAnyPublisher()
    }
    
    private var deliveredNotificationsSubject = PassthroughSubject<[String], Never>()
    private var authorizationStatusSubject = PassthroughSubject<UNAuthorizationStatus, Never>()
    private var removalNotificationsSubject = PassthroughSubject<Bool, Never>()
    
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

    func sendDeliveredEvent() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] notifications in
            let difference = self?.previousPendingNotifications.filter { notifications.contains($0) == false }
            if let identifiers = difference?.map({ $0.identifier }) {
                self?.deliveredNotificationsSubject.send(identifiers)
            }

            self?.previousPendingNotifications = notifications
        }
    }
    
    func setPreviousPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { [weak self] notifications in
            self?.previousPendingNotifications = notifications
        }
    }

    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if let error = error {
                print("notification Error: \(error)")
            } else {
                print("success")
            }
        }
    }
    
    func setCalendarNotification(toDo:ToDo, badge: NSNumber? = nil) {
        let content = getNotificationContent(
            subtitle: toDo.content,
            categoryIdentifier: toDo.alarmTime?.description ?? "")
        
        guard let date = toDo.alarmTime else {
            return
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false)
        addNotificationCenter(
            id: toDo.id ?? UUID().uuidString,
            content: content,
            trigger: trigger)
        changeBadgeNumberInPendingNotificationRequest()
    }

    func setLocalNotification(toDo:ToDo) {
        let content = getNotificationContent(
            subtitle: toDo.content,
            categoryIdentifier: toDo.alarmTime?.description ?? "")
        let region = LocationService.shared.getCircularRegion(
            latitude: toDo.alarmLocationLatitude,
            longitude: toDo.alarmLocationLongitude,
            identifier: toDo.id ?? UUID().uuidString)
        
        let trigger = UNLocationNotificationTrigger(
            region: region,
            repeats: false)
        addNotificationCenter(
            id: toDo.id ?? UUID().uuidString,
            content: content,
            trigger: trigger)
    }
    
    func editLocalNotification(toDo:ToDo) {
        guard let id = toDo.id else {
            return
        }
        
        UNUserNotificationCenter.current().getPendingNotificationRequests {
            [weak self] notificationRequests in
            let requests = notificationRequests.filter {
                $0.identifier == id
            }
            
            self?.removePendingNotification(id: id)
            
            if let request = requests.first {
                let badge = request.content.badge ?? 0
                self?.setCalendarNotification(toDo:toDo, badge: badge)
            }
        }
    }
    
    func changeBadgeNumberInPendingNotificationRequest() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notificationRequests in
            if notificationRequests.count < 2 {
                return
            }

            let sortedNotification = notificationRequests.sorted { $0.content.categoryIdentifier < $1.content.categoryIdentifier
            }
            
            sortedNotification.enumerated().forEach { [weak self] index, request in
                let badgeNumber = (index + 1) as NSNumber
                if let content = self?.getNotificationContent(
                    subtitle: request.content.subtitle,
                    categoryIdentifier: request.content.categoryIdentifier,
                    badge: badgeNumber) {
                    self?.addNotificationCenter(id: request.identifier, content: content, trigger: request.trigger)
                }
            }
        }
    }
    
    func removeAllDeliveredNotification() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        changeBadgeNumberInPendingNotificationRequest()
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func removePendingNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
        changeBadgeNumberInPendingNotificationRequest()
    }

    private func getNotificationContent(subtitle: String?, categoryIdentifier: String, badge: NSNumber = 1) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "나옹"
        content.subtitle = subtitle ?? "할 일 했나옹?"
        content.sound = .default
        content.badge = badge
        content.categoryIdentifier = categoryIdentifier
        
        return content
    }
    
    private func addNotificationCenter(id: String, content: UNNotificationContent, trigger: UNNotificationTrigger?) {
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
}

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        deliveredNotificationsSubject.send([notification.request.identifier])

        let badgeNumber = UIApplication.shared.applicationIconBadgeNumber
        if badgeNumber > 0 {
            UIApplication.shared.applicationIconBadgeNumber = badgeNumber - 1
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        deliveredNotificationsSubject.send([notification.request.identifier])

        let options: UNNotificationPresentationOptions = [.banner, .badge, .sound]
        completionHandler(options)
    }
}


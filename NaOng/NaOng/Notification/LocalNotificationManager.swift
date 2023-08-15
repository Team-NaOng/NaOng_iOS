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
    var deliveredNotificationsPublisher: AnyPublisher<[UNNotification], Never> {
        deliveredNotificationsSubject.eraseToAnyPublisher()
    }

    private var deliveredNotificationsSubject = PassthroughSubject<[UNNotification], Never>()
    
    func postRemovedEvent() {
        NotificationCenter.default.post(name: Notification.Name("removeAllDeliveredNotifications"), object: nil)
    }
    
    func sendRemovedEvent() {
        deliveredNotificationsSubject.send([])
    }
    
    func sendDeliveredEvent() {
        UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
            DispatchQueue.main.async {
                self?.deliveredNotificationsSubject.send(notifications)
            }
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
        let content = getNotificationContent(subtitle: toDo.content, badge: unwrapBadgeNumber(badge:badge))
        
        guard let date = toDo.alarmTime else {
            return
        }
        
        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: toDo.isRepeat)
        addNotificationCenter(
            id: toDo.id ?? UUID().uuidString,
            content: content,
            trigger: trigger)
    }

    func setLocalNotification(toDo:ToDo) {
        increaseBadgeNumber()
        let content = getNotificationContent(subtitle: toDo.content, badge: getBadgeNumber() as NSNumber)
        let region = LocationService.shared.getCircularRegion(
            latitude: toDo.alarmLocationLatitude,
            longitude: toDo.alarmLocationLongitude,
            identifier: toDo.id ?? UUID().uuidString)
        
        let trigger = UNLocationNotificationTrigger(
            region: region,
            repeats: toDo.isRepeat)
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
            
            self?.removePendingNotificationNotification(id: id)
            
            if let request = requests.first {
                let badge = request.content.badge ?? 0
                self?.setCalendarNotification(toDo:toDo, badge: badge)
            }
        }
    }
    
    func removeAllDeliveredNotification() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        clearBadgeNumber()
    }
    
    func removePendingNotificationNotification(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func changeBadgeNumberInPendingNotificationRequest() {
        decreaseBadgeNumber()

        UNUserNotificationCenter.current().getPendingNotificationRequests { notificationRequests in
            let badgeNumber = notificationRequests.count
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            notificationRequests.reversed().enumerated().forEach { [weak self] index, request in
                let subtitle = request.content.subtitle
                let badge = (badgeNumber - index) as NSNumber
                if let content = self?.getNotificationContent(subtitle: subtitle, badge: badge) {
                    self?.addNotificationCenter(id: request.identifier, content: content, trigger: request.trigger)
                }
            }
        }
    }

    private func getNotificationContent(subtitle: String?, badge: NSNumber) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "나옹"
        content.subtitle = subtitle ?? "할 일 했나옹?"
        content.sound = .default
        content.badge = badge
        
        return content
    }
    
    private func addNotificationCenter(id: String, content: UNNotificationContent, trigger: UNNotificationTrigger?) {
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }

    private func getBadgeNumber() -> Int {
        return UserDefaults.standard.integer(forKey: "badgeUserDefaultsKey")
    }
    
    private func unwrapBadgeNumber(badge: NSNumber?) -> NSNumber {
        guard let newBadge = badge else {
            increaseBadgeNumber()
            return getBadgeNumber() as NSNumber
        }
        
        return newBadge
    }
    
    private func changeBadge(number: Int) {
        UserDefaults.standard.set(number, forKey: "badgeUserDefaultsKey")
    }
    
    private func clearBadgeNumber() {
        changeBadge(number: 0)
        UIApplication.shared.applicationIconBadgeNumber = getBadgeNumber()
    }

    private func increaseBadgeNumber() {
        var badgeNumber = getBadgeNumber()
        badgeNumber += 1
        changeBadge(number: badgeNumber)
    }
    
    private func decreaseBadgeNumber() {
        var badgeNumber = getBadgeNumber()
        badgeNumber -= 1
        if badgeNumber < 0 {
            badgeNumber = 0
        }
        changeBadge(number: badgeNumber)
    }
}

extension LocalNotificationManager: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notification = response.notification
        deliveredNotificationsSubject.send([notification])
        
        decreaseBadgeNumber()
        UIApplication.shared.applicationIconBadgeNumber = getBadgeNumber()
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        deliveredNotificationsSubject.send([notification])
        
        decreaseBadgeNumber()
        let options: UNNotificationPresentationOptions = [.banner, .badge, .sound]
        completionHandler(options)
    }
}


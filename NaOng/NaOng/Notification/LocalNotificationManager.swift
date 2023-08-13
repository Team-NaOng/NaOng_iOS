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
    
    func setCalendarNotification(toDo:ToDo) {
        let content = getNotificationContent(subtitle: toDo.content)
        
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
        let content = getNotificationContent(subtitle: toDo.content)
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
    
    func removeAllDeliveredNotification() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    func removeAllPendingNotificationNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    private func getNotificationContent(subtitle: String?) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "나옹"
        content.subtitle = subtitle ?? "할 일 했나옹?"
        content.sound = .default
        
        increaseBadgeNumber()
        content.badge = (getBadgeNumber()) as NSNumber
        
        return content
    }
    
    private func addNotificationCenter(id: String, content: UNNotificationContent, trigger: UNNotificationTrigger?) {
        let request = UNNotificationRequest(
            identifier: id,
            content: content,
            trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func increaseBadgeNumber() {
        var badgeNumber = getBadgeNumber()
        badgeNumber += 1
        UserDefaults.standard.set(badgeNumber, forKey: "badgeUserDefaultsKey")
    }
    
    func decreaseBadgeNumber() {
        var badgeNumber = getBadgeNumber()
        badgeNumber -= 1
        if badgeNumber < 0 {
            badgeNumber = 0
        }
        UserDefaults.standard.set(badgeNumber, forKey: "badgeUserDefaultsKey")
    }
    
    func clearBadgeNumber() {
        UserDefaults.standard.set(0, forKey: "badgeUserDefaultsKey")
        UIApplication.shared.applicationIconBadgeNumber = getBadgeNumber()
    }

    func getBadgeNumber() -> Int {
        return UserDefaults.standard.integer(forKey: "badgeUserDefaultsKey")
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


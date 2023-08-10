//
//  NotificationManager.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/06.
//

import UserNotifications
import CoreLocation
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() { }

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
        cancelNotification()
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
            id: toDo.id?.uuidString ?? UUID().uuidString,
            content: content,
            trigger: trigger)
    }
    
    func setLocalNotification(toDo:ToDo) {
        let content = getNotificationContent(subtitle: toDo.content)
        let region = LocationService.shared.getCircularRegion(
            latitude: toDo.alarmLocationLatitude,
            longitude: toDo.alarmLocationLongitude,
            identifier: toDo.id?.uuidString ?? UUID().uuidString)
        
        let trigger = UNLocationNotificationTrigger(
            region: region,
            repeats: toDo.isRepeat)
        addNotificationCenter(
            id: toDo.id?.uuidString ?? UUID().uuidString,
            content: content,
            trigger: trigger)
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
    
    private func getNotificationContent(subtitle: String?) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "나옹"
        content.subtitle = subtitle ?? "할 일 했나옹?"
        content.sound = .default
        content.badge = 1
        
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

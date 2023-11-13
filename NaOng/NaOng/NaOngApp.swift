//
//  NaOngApp.swift
//  NaOng
//
//  Created by seohyeon park on 2023/05/23.
//

import SwiftUI

@main
struct NaOngApp: App {
    var body: some Scene {
        WindowGroup {
            let viewContext = ToDoCoreDataManager().persistentContainer.viewContext
            let localNotificationManager = LocalNotificationManager()
            
            ContentView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(localNotificationManager)
                .onAppear {
                    LocationService.shared.loadLocation()
                    localNotificationManager.requestAuthorization()
                    UNUserNotificationCenter.current().delegate = localNotificationManager
                    
                    NotificationCenter.default.addObserver(
                        forName: UIApplication.didBecomeActiveNotification,
                        object: nil,
                        queue: nil) { _ in
                            localNotificationManager.sendAuthorizationStatusEvent()
                        }
                }
        }
    }
}

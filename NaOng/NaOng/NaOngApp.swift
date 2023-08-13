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
            let viewContext = ToDoCoreDataManager.shared.persistentContainer.viewContext
            let localNotificationManager = LocalNotificationManager()
            ContentView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(localNotificationManager)
                .onAppear {
                    localNotificationManager.requestAuthorization()
                    UNUserNotificationCenter.current().delegate = localNotificationManager
                    UserDefaults.standard.set(0, forKey: "badgeUserDefaultsKey")
                }
        }
    }
}

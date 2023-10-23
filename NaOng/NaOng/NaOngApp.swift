//
//  NaOngApp.swift
//  NaOng
//
//  Created by seohyeon park on 2023/05/23.
//

import SwiftUI

@main
struct NaOngApp: App {
    @Environment(\.scenePhase) private var phase
    var body: some Scene {
        WindowGroup {
            let viewContext = ToDoCoreDataManager.shared.persistentContainer.viewContext
            let localNotificationManager = LocalNotificationManager()
            ContentView()
                .environment(\.managedObjectContext, viewContext)
                .environmentObject(localNotificationManager)
                .onAppear {
                    LocationService.shared.loadLocation()
                    localNotificationManager.requestAuthorization()
                    UNUserNotificationCenter.current().delegate = localNotificationManager
                }
        }
    }
}

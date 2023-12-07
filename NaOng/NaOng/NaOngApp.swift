//
//  NaOngApp.swift
//  NaOng
//
//  Created by seohyeon park on 2023/05/23.
//

import SwiftUI

@main
struct NaOngApp: App {
    @AppStorage("isOnboarding") var isOnboarding: Bool = true
    private let viewContext = ToDoCoreDataManager().persistentContainer.viewContext
    private let localNotificationManager = LocalNotificationManager()
    
    var body: some Scene {
        WindowGroup {
            if isOnboarding {
                OnboardingAnimationView()
            } else {
                ContentView()
                    .preferredColorScheme(.light)
                    .environment(\.managedObjectContext, viewContext)
                    .environmentObject(localNotificationManager)
                    .onAppear {
                        LocationService.shared.loadLocation()
                        localNotificationManager.requestAuthorization()
                        
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
}

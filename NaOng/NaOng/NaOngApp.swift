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
            ContentView()
                .environment(\.managedObjectContext, viewContext)
                .onAppear {
                    NotificationManager.shared.requestAuthorization()
                }
//            let vm = CalendarViewModel(viewContext: viewContext)
//            CalendarView(calendarViewModel: vm)
//                .environment(\.managedObjectContext, viewContext)
        }
    }
}

//
//  ContentView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/05/23.
//

import SwiftUI
import CoreData
import Combine

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @EnvironmentObject var localNotificationManager: LocalNotificationManager
    
    private let viewContext = ToDoCoreDataManager.shared.persistentContainer.viewContext
    
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    
    var body: some View {
        let toDoListViewModel = ToDoListViewModel(viewContext: viewContext, localNotificationManager: localNotificationManager)
        TabView {
            ToDoListView(toDoListViewModel: toDoListViewModel)
                .preferredColorScheme(.light)
                .tabItem {
                    Image(systemName: "checklist")
                        .foregroundColor(.black)
                    Text("오늘 할 일")
                        .font(.custom("Binggrae", size: 10))
                        .foregroundColor(.black)
                }
            
            let calendarViewModel = CalendarViewModel(viewContext: viewContext, localNotificationManager: localNotificationManager)
            CalendarView(calendarViewModel: calendarViewModel)
                .tabItem {
                    Image(systemName: "calendar")
                        .foregroundColor(.black)
                    Text("전체 할 일")
                        .font(.custom("Binggrae", size: 10))
                        .foregroundColor(.black)
                }
            
            let notificationListViewModel = NotificationListViewModel(viewContext: viewContext, localNotificationManager: localNotificationManager)
            NotificationListView(notificationListViewModel: notificationListViewModel)
                .tabItem {
                    Image(systemName: "bell")
                    Text("알림 목록")
                        .font(.custom("Binggrae", size: 10))
                        .foregroundColor(.black)
                }
            
            let settingViewModel = SettingViewModel(localNotificationManager: localNotificationManager)
            SettingView(settingViewModel: settingViewModel)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("설정")
                        .font(.custom("Binggrae", size: 10))
                        .foregroundColor(.black)
                }
        }
        .tint(Color("primary"))
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIApplication.didBecomeActiveNotification,
                object: nil,
                queue: nil) { _ in
                    localNotificationManager.sendAuthorizationStatusEvent()
                }
        }
    }
}

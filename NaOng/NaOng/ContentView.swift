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
    
    var body: some View {
        let viewContext = ToDoCoreDataManager.shared.persistentContainer.viewContext
        let toDoListViewModel = ToDoListViewModel(viewContext: viewContext, localNotificationManager: localNotificationManager)
        
        ToDoListView(toDoListViewModel: toDoListViewModel)
            .preferredColorScheme(.light)
            .onAppear {
                //LocationService.shared.loadLocation()
                NotificationCenter.default.addObserver(
                    forName: UIApplication.didBecomeActiveNotification,
                    object: nil,
                    queue: nil) { _ in
                        localNotificationManager.sendDeliveredEvent()
                    }
                let name = Notification.Name("removeAllDeliveredNotifications")
                NotificationCenter.default.addObserver(
                    forName: name,
                    object: nil,
                    queue: nil) { _ in
                        localNotificationManager.sendRemovedEvent()
                    }
            }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

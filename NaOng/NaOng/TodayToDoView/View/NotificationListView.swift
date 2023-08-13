//
//  NotificationListView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/12.
//

import SwiftUI

struct NotificationListView: View {
    @ObservedObject private var notificationListViewModel: NotificationListViewModel
    
    init(notificationListViewModel: NotificationListViewModel) {
        self.notificationListViewModel = notificationListViewModel
    }
    
    var body: some View {
        List {
            ForEach(notificationListViewModel.groupedToDoItems.keys.sorted(by: { $0 > $1}), id: \.self) { key in
                if let toDoItems = notificationListViewModel.groupedToDoItems[key] {
                    Section(header: Text(key)) {
                        ForEach(toDoItems, id: \.id) { toDoItem in
                            NotificationListItemView(toDo: toDoItem)
                        }
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 18, bottom: 10, trailing: 18))
                    }
                }
            }
        }
        .foregroundColor(.black)
        .font(.custom("Binggrae-Bold", size: 15))
        .listStyle(PlainListStyle())
        .onAppear {
            notificationListViewModel.fetchGroupedToDoItems()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("모두 읽음 표시") {
                    notificationListViewModel.clearDeliveredNotification()
                }
            }
        }
    }
}

struct NotificationListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = ToDoCoreDataManager.shared.persistentContainer.viewContext
        let localNotificationManager = LocalNotificationManager()
        let vm = NotificationListViewModel(viewContext: viewContext, localNotificationManager: localNotificationManager)
        NotificationListView(notificationListViewModel: vm)
    }
}

//
//  NotificationListViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/12.
//

import Foundation
import UserNotifications
import CoreData

@MainActor
class NotificationListViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    private(set) var groupedToDoItems: [String : [ToDo]] = [:]

    private var fetchedResultsController: NSFetchedResultsController<ToDo> = NSFetchedResultsController()
    private let viewContext: NSManagedObjectContext
    private let localNotificationManager: LocalNotificationManager
    
    init(viewContext: NSManagedObjectContext, localNotificationManager: LocalNotificationManager) {
        self.viewContext = viewContext
        self.localNotificationManager = localNotificationManager
        
        super.init()
        fetchedResultsController.delegate = self

        self.fetchGroupedToDoItems()
    }
    
    func clearDeliveredNotification() {
        localNotificationManager.removeAllDeliveredNotification()
        localNotificationManager.clearBadgeNumber()
        localNotificationManager.postRemovedEvent()
        
    }
    
    func fetchGroupedToDoItems() {
        let toDoItems = fetchTodoItems()
        groupedToDoItems = Dictionary(grouping: toDoItems, by: {$0.alarmDate ?? Date().getFormatDate()})
    }
    
    private func fetchTodoItems() -> [ToDo] {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "alarmTime <= %@ AND isNotificationVisible == %@", argumentArray: [Date(), false])
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ToDo.alarmTime, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        var toDoItems: [ToDo] = []
        do {
            try fetchedResultsController.performFetch()
            guard let fetchedItems = fetchedResultsController.fetchedObjects else {
                return []
            }
            
            toDoItems = fetchedItems
        } catch {
            print(error)
        }
        
        return toDoItems
    }
}

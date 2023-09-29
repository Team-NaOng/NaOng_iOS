//
//  NotificationListViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/12.
//

import Foundation
import UserNotifications
import CoreData
import Combine

@MainActor
class NotificationListViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var groupedToDoItems: [String : [ToDo]] = [:]

    private var fetchedResultsController: NSFetchedResultsController<ToDo> = NSFetchedResultsController()
    private var cancellables: Set<AnyCancellable> = []
    private let viewContext: NSManagedObjectContext
    private let localNotificationManager: LocalNotificationManager
    
    init(viewContext: NSManagedObjectContext, localNotificationManager: LocalNotificationManager) {
        self.viewContext = viewContext
        self.localNotificationManager = localNotificationManager
        
        super.init()
        fetchedResultsController.delegate = self

        let toDoItems = fetchTodoItems()
        addGroupedToDoItems(toDoItems: toDoItems)
    }
    
    func bind() {
        localNotificationManager.deliveredNotificationsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notifications in
                notifications.forEach { [weak self] notification in
                    Task {
                        let id = notification.request.identifier
                        await self?.modifyToDoForDisplayOnNotificationView(id: id)
                        let toDoItems = self?.fetchTodoItems()
                        self?.addGroupedToDoItems(toDoItems: toDoItems)
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    func clearDeliveredNotification() {
        localNotificationManager.removeAllDeliveredNotification()
        localNotificationManager.postRemovedEvent()
    }

    private func modifyToDoForDisplayOnNotificationView(id: String) async {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [id])
        
        do {
            let toDoItems = try viewContext.fetch(fetchRequest)
            if let toDoItem = toDoItems.first {
                toDoItem.isNotificationVisible = true
                try toDoItem.save(viewContext: viewContext)
            }
        } catch {
            print("Error: \(error)")
        }
    }

    private func fetchTodoItems() -> [ToDo] {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isNotificationVisible == %@", argumentArray: [true])
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ToDo.alarmDate, ascending: true)
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
    
    private func addGroupedToDoItems(toDoItems: [ToDo]?) {
        guard let toDoItems = toDoItems else { return }
        groupedToDoItems = Dictionary(grouping: toDoItems, by: {$0.alarmDate ?? Date().getFormatDate()})
    }
}

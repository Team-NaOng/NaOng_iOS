//
//  ToDoListViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/02.
//

import Foundation
import CoreData
import Combine

@MainActor
class ToDoListViewModel: NSObject, ObservableObject {
    @Published var showingToDoItemAddView: Bool = false
    @Published var toDoItems: [ToDo] = [ToDo]()
    @Published var notificationButtonName = "bell"
    
    private let fetchedResultsController: NSFetchedResultsController<ToDo>
    private let viewContext: NSManagedObjectContext
    private let localNotificationManager: LocalNotificationManager
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewContext: NSManagedObjectContext, localNotificationManager: LocalNotificationManager) {
        self.viewContext = viewContext
        self.localNotificationManager = localNotificationManager

        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "alarmDate == %@", argumentArray: [Date().getFormatDate()])
        let sortDescriptor = NSSortDescriptor(keyPath: \ToDo.alarmDate, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        
        super.init()
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            guard let toDoItems = fetchedResultsController.fetchedObjects else {
                return
            }
            
            self.toDoItems = toDoItems
        } catch {
            print(error)
        }
    }

    func getMarkerName(isDone: Bool, alertType: String) -> String {
        if isDone {
            return "doneMarker"
        }

        if alertType == "location" {
            return "locationMarker"
        }

        return "timeMarker"
    }
    
    func bind() {
        localNotificationManager.deliveredNotificationsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] notifications in
                print(notifications)
                self?.setNotificationButtonName(isEmpty: notifications.isEmpty)
                
                notifications.forEach { [weak self] notification in
                    let id = notification.request.identifier
                    self?.modifyToDoForDisplayOnNotificationView(id: id)
                }
            }
            .store(in: &cancellables)
    }
    
    private func setNotificationButtonName(isEmpty: Bool) {
        if isEmpty {
            notificationButtonName = "bell"
            return
        }
        
        notificationButtonName = "bell.badge"
    }
    
    private func modifyToDoForDisplayOnNotificationView(id: String) {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [id])
        
        do {
            let toDoItems = try viewContext.fetch(fetchRequest)
            if let toDoItem = toDoItems.first {
                toDoItem.isNotificationVisible = false
                try toDoItem.save(viewContext: viewContext)
            }
        } catch {
            print("Error: \(error)")
        }
    }

    func deleteItems(offsets: IndexSet) {
        offsets.map { toDoItems[$0] }.forEach { todo in
            guard let id = todo.id else {
                return
            }

            do {
                try todo.delete(viewContext: viewContext)
            } catch {
                print(error)
            }
            
            localNotificationManager.removePendingNotificationNotification(id: id)
            localNotificationManager.changeBadgeNumberInPendingNotificationRequest()
        }
    }
}

extension ToDoListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let toDoItems = controller.fetchedObjects as? [ToDo] else {
            return
        }
        
        self.toDoItems = toDoItems
    }
}


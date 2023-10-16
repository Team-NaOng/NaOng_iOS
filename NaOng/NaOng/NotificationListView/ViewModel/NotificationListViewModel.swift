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
        
        if let fetchedToDoItems = fetchTodoItems(with: "isNotificationVisible == %@", argumentArray: [true]) {
            replaceGroupedToDoItems(with: fetchedToDoItems)
        }
    }

    func bind() {
        localNotificationManager.sendDeliveredEvent()

        localNotificationManager.deliveredNotificationsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] notifications in
                notifications.forEach { [weak self] notification in
                    let id = notification.request.identifier
                    self?.modifyToDoForDisplayOnNotificationView(id: id)
                }
                
                if let fetchedToDoItems = self?.fetchTodoItems(with: "isNotificationVisible == %@", argumentArray: [true]) {
                    self?.replaceGroupedToDoItems(with: fetchedToDoItems)
                }
            }
            .store(in: &cancellables)
        
        localNotificationManager.removalNotificationsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isRemove in
                if let fetchedToDoItems = self?.fetchTodoItems(with: "isNotificationVisible == %@", argumentArray: [true]) {
                    self?.replaceGroupedToDoItems(with: fetchedToDoItems, isRemove)
                }
            }
            .store(in: &cancellables)
    }
    
    func clearDeliveredNotification() {
        localNotificationManager.removeAllDeliveredNotification()
    }

    private func modifyToDoForDisplayOnNotificationView(id: String) {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", argumentArray: [id])
        
        do {
            let toDoItems = try viewContext.fetch(fetchRequest)
            if let toDoItem = toDoItems.first,
                toDoItem.isNotificationVisible == false {
                toDoItem.isNotificationVisible = true

                try toDoItem.save(viewContext: viewContext)
                try addNextDayToDo(toDoItem: toDoItem)
            }
        } catch {
            print("Error: \(error)")
        }
    }
    
    private func addNextDayToDo(toDoItem: ToDo) throws {
        if toDoItem.isRepeat == false { return }

        var nextDate = Date()
        if let currentDate = toDoItem.alarmTime {
            let oneDay: TimeInterval = 24 * 60 * 60
            nextDate = currentDate.addingTimeInterval(oneDay)
        }

        let newToDoItem = ToDo(context: viewContext)
        newToDoItem.id = UUID().uuidString
        newToDoItem.isDone = false
        newToDoItem.isNotificationVisible = false
        newToDoItem.content = toDoItem.content
        newToDoItem.alarmType = toDoItem.alarmType
        newToDoItem.alarmTime = nextDate
        newToDoItem.isRepeat = toDoItem.isRepeat
        newToDoItem.alarmLocationLatitude = toDoItem.alarmLocationLatitude
        newToDoItem.alarmLocationLongitude = toDoItem.alarmLocationLongitude
        newToDoItem.alarmDate = newToDoItem.alarmTime?.getFormatDate()

        try newToDoItem.save(viewContext: viewContext)
        
        if toDoItem.alarmType == "위치" {
            LocalNotificationManager().setLocalNotification(toDo: toDoItem)
        } else {
            LocalNotificationManager().setCalendarNotification(toDo: toDoItem)
        }
    }

    private func fetchTodoItems(with format: String, argumentArray: [Any]?) -> [ToDo]? {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: format, argumentArray: argumentArray)
        
        let sortDescriptor = NSSortDescriptor(keyPath: \ToDo.alarmDate, ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil
        )

        do {
            try fetchedResultsController.performFetch()
            guard let fetchedItems = fetchedResultsController.fetchedObjects else {
                return nil
            }

            return fetchedItems
            
        } catch {
            print(error)
        }
        
        return nil
    }
    
    private func replaceGroupedToDoItems(with toDoItems: [ToDo]?, _ isRemove: Bool = false) {
        guard let toDoItems = toDoItems else { return }
        if (toDoItems.isEmpty) && (isRemove == false)  { return }
        
        groupedToDoItems = Dictionary(grouping: toDoItems, by: {$0.alarmDate ?? Date().getFormatDate()})
    }
}

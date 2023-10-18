//
//  CalendarViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/09.
//

import Foundation
import CoreData

@MainActor
class CalendarViewModel: NSObject, ObservableObject {
    @Published var date: Date = Date()
    @Published var showingToDoItemAddView: Bool = false
    @Published var toDoItems: [ToDo] = [ToDo]()
    @Published var selectedViewOption = "전체"

    private var fetchedResultsController: NSFetchedResultsController<ToDo> = NSFetchedResultsController()
    private(set) var localNotificationManager: LocalNotificationManager
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext, localNotificationManager: LocalNotificationManager) {
        self.viewContext = viewContext
        self.localNotificationManager = localNotificationManager
        
        super.init()
        fetchToDoItems(
            format: "alarmDate == %@",
            argumentArray: [Date().getFormatDate()])
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
            
            localNotificationManager.removePendingNotification(id: id)
            localNotificationManager.sendRemovedEvent()
        }
    }

    private func fetchToDoItems(format: String, argumentArray: [Any]?) {
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
    
    func setFetchedResultsPredicate()  {
        switch selectedViewOption {
        case "위치":
            fetchToDoItems(
                format: "alarmDate == %@ AND alarmType == %@",
                argumentArray: [date.getFormatDate(), "위치"])
            break
        case "시간":
            fetchToDoItems(
                format: "alarmDate == %@ AND alarmType == %@",
                argumentArray: [date.getFormatDate(), "시간"])
            break
        case "반복":
            fetchToDoItems(
                format: "alarmDate == %@ AND isRepeat == %@",
                argumentArray: [date.getFormatDate(), true])
            break
        default:
            fetchToDoItems(
                format: "alarmDate == %@",
                argumentArray: [date.getFormatDate()])
        }
    }
}

extension CalendarViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let toDoItems = controller.fetchedObjects as? [ToDo] else {
            return
        }
        
        self.toDoItems = toDoItems
    }
}

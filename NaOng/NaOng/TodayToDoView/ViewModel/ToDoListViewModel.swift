//
//  ToDoListViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/02.
//

import Foundation
import CoreData

@MainActor
class ToDoListViewModel: NSObject, ObservableObject {
    @Published var showingToDoItemAddView: Bool = false
    @Published var toDoItems: [ToDo] = [ToDo]()
    
    private var fetchedResultsController: NSFetchedResultsController<ToDo> =  NSFetchedResultsController()
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext

        super.init()
        fetchedResultsController.delegate = self
        self.fetchTodoItems()
        
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
    
    func deleteItems(offsets: IndexSet) {
        offsets.map { toDoItems[$0] }.forEach(viewContext.delete)
        do {
            try viewContext.save()
        } catch {
            print(error)
        }
    }
    
    private func fetchTodoItems() {
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
}

extension ToDoListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        fetchTodoItems()
    }
}

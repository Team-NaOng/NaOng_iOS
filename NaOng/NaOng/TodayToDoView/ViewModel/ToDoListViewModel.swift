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
    
    private let fetchedResultsController: NSFetchedResultsController<ToDo>
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext

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
    
    func deleteItems(offsets: IndexSet) {
        offsets.map { toDoItems[$0] }.forEach { todo in
            do {
                try todo.delete(viewContext: viewContext)
            } catch {
                print(error)
            }
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


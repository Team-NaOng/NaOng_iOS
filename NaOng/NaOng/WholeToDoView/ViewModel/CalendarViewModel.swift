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

    private var fetchedResultsController: NSFetchedResultsController<ToDo> = NSFetchedResultsController()
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        
        super.init()
        self.fetchTodoItems()
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

    func fetchTodoItems() {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "alarmDate == %@", argumentArray: [date.getFormatDate()])
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
}

extension CalendarViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let toDoItems = controller.fetchedObjects as? [ToDo] else {
            return
        }
        
        self.toDoItems = toDoItems
    }
}

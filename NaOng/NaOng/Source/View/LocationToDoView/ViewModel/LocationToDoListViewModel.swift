//
//  LocationToDoListViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/02.
//

import Foundation
import CoreData

class LocationToDoListViewModel: NSObject, ObservableObject {
    @Published var showingToDoItemAddView: Bool = false
    @Published var toDoItems: [ToDo] = [ToDo]()
    @Published var selectedViewOption = "전체"
    @Published var showErrorAlert = false
    var errorTitle: String = ""
    var errorMessage: String = ""
    var addModel: ToDoItemAddViewModel?
    
    private var fetchedResultsController: NSFetchedResultsController<ToDo> = NSFetchedResultsController()
    private(set) var localNotificationManager: LocalNotificationManager
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext, localNotificationManager: LocalNotificationManager) {
        self.viewContext = viewContext
        self.localNotificationManager = localNotificationManager

        super.init()
        fetchToDoItems(
            format: "alarmType == %@",
            argumentArray: ["위치"])
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
            guard let id = todo.id else {
                return
            }

            do {
                try todo.delete(viewContext: viewContext)
            } catch {
                errorTitle = "할 일 삭제 실패🥲"
                errorMessage = error.localizedDescription
                showErrorAlert.toggle()
            }
            
            localNotificationManager.removeNotification(id: id)
        }
    }
    
    func setFetchedResultsPredicate()  {
        switch selectedViewOption {
        case "한번":
            fetchToDoItems(
                format: "alarmType == %@ AND isRepeat == %@",
                argumentArray: ["위치", false])
            break
        case "반복":
            fetchToDoItems(
                format: "alarmType == %@ AND isRepeat == %@",
                argumentArray: ["위치", true])
            break
        default:
            fetchToDoItems(
                format: "alarmType == %@",
                argumentArray: ["위치"])
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
            
            self.toDoItems = sortedToDoItems(toDoItems: toDoItems)
        } catch {
            showErrorAlert.toggle()
        }
    }
    
    private func sortedToDoItems(toDoItems: [ToDo]) -> [ToDo] {
        return toDoItems.sorted {
            if let alarmTime0 = $0.alarmTime,
               let alarmTime1 = $1.alarmTime {
                if $0.isDone == $1.isDone {
                    return alarmTime0 < alarmTime1
                } else {
                    return !$0.isDone && $1.isDone
                }
            }
            
            return !$0.isDone && $1.isDone
        }
    }
}

extension LocationToDoListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let toDoItems = controller.fetchedObjects as? [ToDo] else {
            return
        }

        self.toDoItems = sortedToDoItems(toDoItems: toDoItems)
    }
}


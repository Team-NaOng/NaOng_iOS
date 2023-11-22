//
//  CalendarViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/09.
//

import Foundation
import CoreData
import Combine

class CalendarViewModel: NSObject, ObservableObject {
    @Published var date: Date = Date()
    @Published var showingToDoItemAddView: Bool = false
    @Published var toDoItems: [ToDo] = [ToDo]()
    @Published var selectedViewOption = "전체"
    @Published var showErrorAlert = false
    var errorTitle: String = ""
    var errorMessage: String = ""

    private var fetchedResultsController: NSFetchedResultsController<ToDo> = NSFetchedResultsController()
    private var cancellables: Set<AnyCancellable> = []
    private(set) var localNotificationManager: LocalNotificationManager
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext, localNotificationManager: LocalNotificationManager) {
        self.viewContext = viewContext
        self.localNotificationManager = localNotificationManager
        
        super.init()
        fetchToDoItems(
            format: "alarmDate == %@ OR (isRepeat == %@ AND alarmDate < %@)",
            argumentArray: [date.getFormatDate(), true, date.getFormatDate()])
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
    
    func bind() {
        localNotificationManager.removalAllNotificationsPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.fetchToDoItems(
                    format: "alarmDate == %@",
                    argumentArray: [Date().getFormatDate()])
            }
            .store(in: &cancellables)
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
            self.toDoItems.sort { !$0.isDone && $1.isDone }
        } catch {
            errorTitle = "할 일 가져오기 실패🥲"
            errorMessage = error.localizedDescription
            showErrorAlert.toggle()
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
                format: "(alarmDate == %@ AND isRepeat == %@) OR (isRepeat == %@ AND alarmDate < %@)",
                argumentArray: [date.getFormatDate(), true, true ,date.getFormatDate()])
            break
        default:
            fetchToDoItems(
                format: "alarmDate == %@ OR (isRepeat == %@ AND alarmDate < %@)",
                argumentArray: [date.getFormatDate(), true, date.getFormatDate()])
        }
    }
}

extension CalendarViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let toDoItems = controller.fetchedObjects as? [ToDo] else {
            return
        }
        
        self.toDoItems = toDoItems
        self.toDoItems.sort { !$0.isDone && $1.isDone }
    }
}

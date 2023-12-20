//
//  LocationToDoListViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/02.
//

import Foundation
import CoreData

class LocationToDoListViewModel: NSObject, ObservableObject {
    @Published var isShowingToDoItemAddView: Bool = false
    @Published var toDoItems: [ToDo] = [ToDo]()
    @Published var selectedViewOption: String = "전체"
    @Published var isShowingErrorAlert: Bool = false
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
    
    func addInitialData() {
        let initialData = [
            "할 일을 클릭하면 수정할 수 있으며,\n완료 시간도 볼 수 있어요!",
            "👈왼쪽 버튼을 누르면\n할 일이 완료돼요!",
            """
            👈왼쪽 버튼에 대해 더 알고 싶다면,
            여기를 클릭해 주세요.

            [할 일 완료 버튼]
            - 알림이 울리기 전에 버튼을 누르면 알림이 가지 않아요.
            - 버튼을 눌렀다가 다시 해제하면 알림이 가요.
            - 버튼을 누르면 아래 완료 시간에 기록이 남아요.
            - 반복 여부에 따라 버튼 모양이 달라요.
            - 반복되지 않는 할 일의 버튼을 누른 경우, 디자인이 바뀌어요.
            - 반복되는 할 일의 버튼을 누른 경우, 완료를 알리는 알림 창이 떠요.
            """
        ]
        
        for index in 0..<3 {
            let toDoItem = ToDo(context: viewContext)
            toDoItem.id = UUID().uuidString
            toDoItem.content = initialData[index]
            toDoItem.alarmType = "위치"
            toDoItem.alarmTime = Date()
            
            if index == 2 {
                toDoItem.isRepeat = true
            } else {
                toDoItem.isRepeat = false
            }
            
            toDoItem.alarmLocationLatitude = 0.0
            toDoItem.alarmLocationLongitude = 0.0
            toDoItem.alarmLocationName = "알 수 없음"
            toDoItem.alarmDate = Date().getFormatDate()
            toDoItem.isDone = false
            toDoItem.isNotificationVisible = false
            
            try? toDoItem.save(viewContext: viewContext)
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
            guard let id = todo.id else {
                return
            }

            do {
                try todo.delete(viewContext: viewContext)
            } catch {
                errorTitle = "할 일 삭제 실패🥲"
                errorMessage = error.localizedDescription
                isShowingErrorAlert.toggle()
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
            isShowingErrorAlert.toggle()
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


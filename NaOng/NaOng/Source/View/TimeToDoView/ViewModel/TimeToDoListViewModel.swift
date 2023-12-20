//
//  TimeToDoListViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/09.
//

import Foundation
import CoreData

class TimeToDoListViewModel: NSObject, ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var isShowingToDoItemAddView: Bool = false
    @Published var toDoItems: [ToDo] = [ToDo]()
    @Published var dateValues: [DateValue] = []
    @Published var currentMonth: Int = 0
    @Published var selectedViewOption: String = "전체"
    @Published var isShowingErrorAlert: Bool = false
    
    var errorTitle: String = ""
    var errorMessage: String = ""
    var toDoItemsForMonth: [ToDo] = [ToDo]()
    
    let days: [String] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]
    private var fetchedResultsController: NSFetchedResultsController<ToDo> = NSFetchedResultsController()
    private(set) var localNotificationManager: LocalNotificationManager
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext, localNotificationManager: LocalNotificationManager) {
        self.viewContext = viewContext
        self.localNotificationManager = localNotificationManager
        
        super.init()
        refreshData()
        filterAllDate()
    }
    
    func refreshData() {
        selectedDate = Date().getMonth(for: currentMonth)
        fetchToDoItems()
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
            filterNoneRepeatingDate()
            break
        case "반복":
            filterRepeatingDate()
            break
        default:
            filterAllDate()
        }
    }

    private func fetchToDoItems(format: String = "alarmType == %@", argumentArray: [Any]? = ["시간"]) {
        let fetchRequest: NSFetchRequest<ToDo> = ToDo.fetchRequest()
        fetchRequest.predicate = NSPredicate(
            format: format,
            argumentArray: argumentArray
        )
        
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
            
            updateDateValuesAndMark(toDoItems: toDoItems)
            toDoItemsForMonth = toDoItems
        } catch {
            errorTitle = "할 일 가져오기 실패🥲"
            errorMessage = error.localizedDescription
            isShowingErrorAlert.toggle()
        }
    }
    
    private func updateDateValuesAndMark(toDoItems: [ToDo]){
        var days = selectedDate.getDatesInCurrentMonth().compactMap { date -> DateValue in
            let day = Calendar.current.component(.day, from: date)
            let hasMark = toDoItems.contains { toDo in
                if (toDo.alarmDate == date.getFormatDate()) && (toDo.isRepeat == false) {
                    return true
                } else {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let alarmDate = dateFormatter.date(from: toDo.alarmDate ?? "") ?? Date()
                    return (toDo.isRepeat) && (date >= alarmDate)
                }
            }
            return DateValue(day: day, date: date, hasMark: hasMark)
        }

        let firstWeekday = Calendar.current.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<(firstWeekday - 1) {
            days.insert(DateValue(day: -1, date: Date(), hasMark: false), at: 0)
        }

        dateValues = days
    }
    
    private func filterNoneRepeatingDate() {
        let filtered = toDoItemsForMonth.filter { toDo in
            return (toDo.alarmDate == selectedDate.getFormatDate()) && (toDo.isRepeat == false)
        }
        self.toDoItems = sortedToDoItems(toDoItems: filtered)
    }
    
    private func filterRepeatingDate() {
        let filtered = toDoItemsForMonth.filter { toDo in
            return (toDo.alarmDate ?? "" <= selectedDate.getFormatDate()) && (toDo.isRepeat == true)
        }
        self.toDoItems = sortedToDoItems(toDoItems: filtered)
    }
    
    private func filterAllDate() {
        let filtered =  toDoItemsForMonth.filter { toDo in
            let isTodayToDo = toDo.alarmDate == selectedDate.getFormatDate()
            let isRepeatToDo = (toDo.alarmDate ?? "" < selectedDate.getFormatDate()) && (toDo.isRepeat == true)

            return isTodayToDo || isRepeatToDo
        }
        self.toDoItems = sortedToDoItems(toDoItems: filtered)
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

extension TimeToDoListViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        guard let toDoItems = controller.fetchedObjects as? [ToDo] else {
            return
        }

        updateDateValuesAndMark(toDoItems: toDoItems)
        toDoItemsForMonth = toDoItems
        setFetchedResultsPredicate()
    }
}

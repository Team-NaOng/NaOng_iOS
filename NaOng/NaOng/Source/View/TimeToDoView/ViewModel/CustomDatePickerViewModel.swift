//
//  CustomDatePickerViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 12/20/23.
//

import Foundation
import CoreData

class CustomDatePickerViewModel: NSObject, ObservableObject, NSFetchedResultsControllerDelegate {
    @Published var selectedDate: Date = Date()
    @Published var currentMonth: Int = 0
    let days: [String] = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

    private(set) var toDoInCurrentMonth: [String] = []
    private(set) var dateValues: [DateValue] = []
    private var fetchedResultsController: NSFetchedResultsController<ToDo> = NSFetchedResultsController()
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
        
        super.init()
        fetchToDoItems(
            format: "alarmType == %@",
            argumentArray: ["시간"]
        )
        
        self.dateValues = getDatesInCurrentMonthWithPlaceholders()
    }
    
    func fetchDates() {
        self.dateValues = getDatesInCurrentMonthWithPlaceholders()
        selectedDate = Date().getMonth(for: currentMonth)
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

            toDoInCurrentMonth = toDoItems.compactMap({ $0.alarmTime?.getFormatDate() ?? "" })
        } catch {
            print("실패")
        }
    }
    
    private func getDatesInCurrentMonthWithPlaceholders() -> [DateValue] {
        let currentMonth = Date().getMonth(for: currentMonth)
        var days = currentMonth.getDatesInCurrentMonth().compactMap { date -> DateValue in
            let day = Calendar.current.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        let firstWeekday = Calendar.current.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<(firstWeekday - 1) {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }

        return days
    }
}

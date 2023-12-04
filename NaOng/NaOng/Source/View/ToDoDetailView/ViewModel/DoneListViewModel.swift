//
//  DoneListViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 12/3/23.
//

import Foundation
import CoreData

class DoneListViewModel: ObservableObject {
    @Published var showingList: Bool = false
    
    private(set) var doneList: [[String]] = []
    private let viewContext: NSManagedObjectContext
   
    
    init(viewContext: NSManagedObjectContext, toDoItem: ToDo) {
        self.viewContext = viewContext
        updateDoneList(toDoItem: toDoItem)
    }
    
    private func updateDoneList(toDoItem: ToDo) {
        guard let doneDateList = toDoItem.doneList else {
            self.doneList = []
            return
        }
        
        self.doneList = doneDateList.map { date in
            [date.getFormatDate("hh:mm"), date.getFormatDate("yyyy-MM-dd-E")]
        }
    }
}

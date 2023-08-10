//
//  ContentView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/05/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    /*
     해야할 일을 적어둔 다이어리가 살아 움직인다?!
     "내 이름 나옹.
     내가 너의 할일을 알려줄께!"
     */
    
    @Environment(\.managedObjectContext) var managedObjectContext
    
    var body: some View {
        let viewContext = ToDoCoreDataManager.shared.persistentContainer.viewContext
        ToDoListView(toDoListViewModel: ToDoListViewModel(viewContext: viewContext))
            .preferredColorScheme(.light)
            .task {
                //LocationService.shared.loadLocation()
            }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

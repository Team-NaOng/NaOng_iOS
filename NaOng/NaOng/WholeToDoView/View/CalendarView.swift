//
//  CalendarView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/08.
//

import SwiftUI
import Combine

struct CalendarView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject private var calendarViewModel: CalendarViewModel
    
    init(calendarViewModel: CalendarViewModel) {
        self.calendarViewModel = calendarViewModel
    }
    
    var body: some View {
        VStack {
            DatePicker(
                    "Start Date",
                    selection: $calendarViewModel.date,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(.gray)
                .onChange(of: $calendarViewModel.date.wrappedValue) { newValue in
                    calendarViewModel.fetchTodoItems()
                }
            
            List {
                ForEach($calendarViewModel.toDoItems) { item in
                    let viewModel = ToDoListItemViewModel(toDoItem: item.wrappedValue, viewContext: viewContext)
                    ToDoListItemView(toDoListItemViewModel: viewModel)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .overlay {
//                            NavigationLink {
//                                let toDoItemDetailViewModel = ToDoItemDetailViewModel(viewContext: viewContext, toDoItem: item.wrappedValue)
//                                ToDoItemDetailView(toDoItemDetailViewModel: toDoItemDetailViewModel)
//                            } label: {
//                                EmptyView()
//                            }
//                            .opacity(0)
                        }
                        .background(Color("secondary"))
                }
                .onDelete { indexSet in
                    withAnimation {
                        calendarViewModel.deleteItems(offsets: indexSet)
                    }
                }
            }
            .listStyle(.plain)
            .buttonStyle(.plain)
            .background(Color("secondary"))
            .frame(width: UIScreen.main.bounds.width - 50, height: 300)
        }
        .overlay {
            Button {
                print($calendarViewModel.date)
                calendarViewModel.showingToDoItemAddView = true
            } label: {
                ZStack {
                    Circle()
                        .frame(width: 70, height: 70)
                        .foregroundColor(Color("primary"))
                    
                    Image(systemName: "plus")
                        .font(.custom("Binggrae-Bold", size: 35))
                        .foregroundColor(.black)
                }
            }
            .frame(width: UIScreen.main.bounds.width - 50, height: UIScreen.main.bounds.height - 150, alignment: .bottomTrailing) // 버튼을 오른쪽 끝으로 위치시킴
            .fullScreenCover(isPresented: $calendarViewModel.showingToDoItemAddView) {
                let viewModel = ToDoItemAddViewModel(viewContext: viewContext)
                ToDoItemAddView(toDoItemAddViewModel: viewModel)
            }
        }
        .padding()
    }
}

//struct CalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        CalendarView()
//    }
//}

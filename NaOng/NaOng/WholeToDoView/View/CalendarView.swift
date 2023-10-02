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
        NavigationView {
            VStack {
                DatePicker(
                        "Start Date",
                        selection: $calendarViewModel.date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .tint(.gray)
                    .padding()
                
                Picker("보기 옵션", selection: $calendarViewModel.selectedViewOption) {
                    Text("전체")
                        .tag("전체")
                        .font(.custom("Binggrae", size: 15))
                    Text("위치")
                        .tag("위치")
                        .font(.custom("Binggrae", size: 15))
                    Text("시간")
                        .tag("시간")
                        .font(.custom("Binggrae", size: 15))
                    Text("반복")
                        .tag("반복")
                        .font(.custom("Binggrae", size: 15))
                }
                .pickerStyle(.navigationLink)
                .font(.custom("Binggrae", size: 15))
                .frame(width: UIScreen.main.bounds.width - 30)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .onChange(of: calendarViewModel.selectedViewOption) { newValue in
                    calendarViewModel.setFetchedResultsPredicate()
                }
                
                List {
                    ForEach($calendarViewModel.toDoItems) { item in
                        let localNotificationManager = LocalNotificationManager()
                        let viewModel = ToDoListItemViewModel(toDoItem: item.wrappedValue, viewContext: viewContext, localNotificationManager: localNotificationManager)
                        ToDoListItemView(toDoListItemViewModel: viewModel)
                            .listRowSeparator(.hidden)
                            .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                            .overlay {
                                NavigationLink {
                                    let toDoItemDetailViewModel = ToDoItemDetailViewModel(viewContext: viewContext, toDoItem: item.wrappedValue, localNotificationManager: localNotificationManager)
                                    ToDoItemDetailView(toDoItemDetailViewModel: toDoItemDetailViewModel)
                                } label: {
                                    EmptyView()
                                }
                                .opacity(0)
                            }
                            .background(Color("secondary"))
                    }
                    .onDelete { indexSet in
                        withAnimation {
                            calendarViewModel.deleteItems(offsets: indexSet)
                        }
                    }
                    
                    Rectangle()
                        .foregroundColor(Color("secondary"))
                        .frame(width: UIScreen.main.bounds.width, height: 90)
                        .listRowSeparator(.hidden)
                        .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
                .listStyle(.plain)
                .buttonStyle(.plain)
                .background(Color("secondary"))
                .frame(width: UIScreen.main.bounds.width)
            }
            .overlay {
                Button {
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
                .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height - 170, alignment: .bottomTrailing)
                .fullScreenCover(isPresented: $calendarViewModel.showingToDoItemAddView) {
                    let viewModel = ToDoItemAddViewModel(viewContext: viewContext)
                    ToDoItemAddView(toDoItemAddViewModel: viewModel)
                }
            }
        }
    }
}


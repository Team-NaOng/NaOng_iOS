//
//  CalendarView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/08.
//

import SwiftUI
import Combine

struct TimeToDoListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject private var timeToDoListViewModel: TimeToDoListViewModel
    
    init(timeToDoListViewModel: TimeToDoListViewModel) {
        self.timeToDoListViewModel = timeToDoListViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                        "Start Date",
                        selection: $timeToDoListViewModel.date,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.graphical)
                    .tint(.gray)
                    .onChange(of: $timeToDoListViewModel.date.wrappedValue) { newValue in
                        timeToDoListViewModel.setFetchedResultsPredicate()
                    }
                    .frame(width: UIScreen.main.bounds.width - 50)
                
                Picker("보기 옵션", selection: $timeToDoListViewModel.selectedViewOption) {
                    Text("전체")
                        .tag("전체")
                        .font(.custom("Binggrae", size: 15))
                    Text("한번")
                        .tag("한번")
                        .font(.custom("Binggrae", size: 15))
                    Text("반복")
                        .tag("반복")
                        .font(.custom("Binggrae", size: 15))
                }
                .pickerStyle(.navigationLink)
                .font(.custom("Binggrae", size: 15))
                .frame(width: UIScreen.main.bounds.width - 30)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
                .onChange(of: timeToDoListViewModel.selectedViewOption) { newValue in
                    timeToDoListViewModel.setFetchedResultsPredicate()
                }
                
                if $timeToDoListViewModel.toDoItems.count == 0 {
                    ZStack {
                        Text("할 일이 없어요. \n 오른쪽 하단의 버튼을 눌러 \n 시간 할 일을 추가해 보세요!")
                            .foregroundColor(.black)
                            .font(.custom("Binggrae", size: 20))
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    .frame(minWidth: UIScreen.main.bounds.width, maxHeight: .infinity)
                    .background(Color("secondary"))
                    .padding(0)
                } else {
                    List {
                        ForEach($timeToDoListViewModel.toDoItems) { item in
                            let localNotificationManager = LocalNotificationManager()
                            let viewModel = ToDoItemViewModel(toDoItem: item.wrappedValue, viewContext: viewContext, localNotificationManager: localNotificationManager)
                            ToDoItemView(toDoItemViewModel: viewModel)
                                .frame(width: UIScreen.main.bounds.width)
                                .listRowSeparator(.hidden)
                                .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                .overlay {
                                    NavigationLink {
                                        let toDoItemDetailViewModel = ToDoItemDetailViewModel(viewContext: viewContext, toDoItem: item.wrappedValue, localNotificationManager: localNotificationManager)
                                        TimeToDoItemDetailView(toDoItemDetailViewModel: toDoItemDetailViewModel)
                                    } label: {
                                        EmptyView()
                                    }
                                    .opacity(0)
                                }
                                .background(Color("secondary"))
                        }
                        .onDelete { indexSet in
                            withAnimation {
                                timeToDoListViewModel.deleteItems(offsets: indexSet)
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
            }
            .overlay {
                Button {
                    timeToDoListViewModel.showingToDoItemAddView = true
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
                .fullScreenCover(isPresented: $timeToDoListViewModel.showingToDoItemAddView) {
                    let viewModel = ToDoItemAddViewModel(
                        viewContext: viewContext,
                        localNotificationManager: timeToDoListViewModel.localNotificationManager,
                        alarmType: "시간",
                        alarmTime: timeToDoListViewModel.date)
                    TimeToDoItemAddView(toDoItemAddViewModel: viewModel)
                }
            }
            .alert(isPresented: $timeToDoListViewModel.showErrorAlert) {
                Alert(
                    title: Text(timeToDoListViewModel.errorTitle),
                    message: Text(timeToDoListViewModel.errorMessage),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
        .onAppear(perform: {
            timeToDoListViewModel.bind()
        })
    }
}


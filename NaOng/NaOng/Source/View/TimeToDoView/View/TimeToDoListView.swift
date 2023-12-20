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
    @ObservedObject private var alertViewModel = AlertViewModel()
    
    init(timeToDoListViewModel: TimeToDoListViewModel) {
        self.timeToDoListViewModel = timeToDoListViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                CustomDatePickerView(timeToDoListViewModel: timeToDoListViewModel)
                    .frame(width: UIScreen.main.bounds.width - 50)
                    .onChange(of: timeToDoListViewModel.currentMonth) { newValue in
                        timeToDoListViewModel.refreshData()
                        timeToDoListViewModel.setFetchedResultsPredicate()
                    }
                    .onChange(of: timeToDoListViewModel.selectedDate) { _ in
                        timeToDoListViewModel.setFetchedResultsPredicate()
                    }
                
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
                            .foregroundStyle(.black)
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
                            let viewModel = ToDoItemViewModel(toDoItem: item.wrappedValue, viewContext: viewContext, localNotificationManager: localNotificationManager,alertViewModel: alertViewModel)
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
                            .foregroundStyle(Color("secondary"))
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
                    timeToDoListViewModel.isShowingToDoItemAddView = true
                } label: {
                    ZStack {
                        Circle()
                            .frame(width: 70, height: 70)
                            .foregroundStyle(Color("primary"))
                        
                        Image(systemName: "plus")
                            .font(.custom("Binggrae-Bold", size: 35))
                            .foregroundStyle(.black)
                    }
                }
                .frame(width: UIScreen.main.bounds.width - 30, height: UIScreen.main.bounds.height - 170, alignment: .bottomTrailing)
                .fullScreenCover(isPresented: $timeToDoListViewModel.isShowingToDoItemAddView) {
                    let viewModel = ToDoItemAddViewModel(
                        viewContext: viewContext,
                        localNotificationManager: timeToDoListViewModel.localNotificationManager,
                        alarmType: "시간",
                        alarmTime: timeToDoListViewModel.selectedDate)
                    TimeToDoItemAddView(toDoItemAddViewModel: viewModel)
                }
            }
            .alert(isPresented: $alertViewModel.isShowingAlert) {
                Alert(
                    title: Text(alertViewModel.alertTitle),
                    message: Text(alertViewModel.alertMessage),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
}


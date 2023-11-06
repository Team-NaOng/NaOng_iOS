//
//  ToDoItemDetailView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/31.
//

import SwiftUI

struct ToDoItemDetailView: View {
    @Environment(\.managedObjectContext) var viewContext

    @ObservedObject private var toDoItemDetailViewModel: ToDoItemDetailViewModel
    
    init(toDoItemDetailViewModel: ToDoItemDetailViewModel) {
        self.toDoItemDetailViewModel = toDoItemDetailViewModel
    }
    
    var body: some View {
        VStack(spacing: 10) {
            ToDoViewFactory.makeToDoMoldView(
                content:
                    VStack(alignment: .leading) {
                        ToDoViewFactory.makeToDoTitle(title: "할 일 내용")
                        
                        ScrollView {
                            Text(toDoItemDetailViewModel.toDoItem.content ?? "")
                                .font(.custom("Binggrae", size: 15))
                                .frame(width: UIScreen.main.bounds.width - 100, alignment: .leading)
                                .padding(10)
                        }
                        .frame(height: 140)
                        .background(Color.white)
                        .cornerRadius(10)
                    },
                height: 200
            )

            ToDoViewFactory.makeToDoMoldView(
                content: ToDoViewFactory.makeToDoToggle(
                    isOn: .constant(toDoItemDetailViewModel.toDoItem.isRepeat),
                    title: "반복 여부")
            )
            
            ToDoViewFactory.makeToDoMoldView(
                content: ToDoViewFactory.makeToDoPicker(
                    title: "알림 타입",
                    selection:  .constant(toDoItemDetailViewModel.toDoItem.alarmType ?? "위치"))
            )
            
            ToDoViewFactory.makeToDoMoldView(
                content: ToDoViewFactory.makeToDoDatePicker(
                    selection: .constant(toDoItemDetailViewModel.toDoItem.alarmTime ?? Date()),
                    title: "알림 날짜",
                    displayedComponent: .date)
                .disabled(true)
            )
            
            if toDoItemDetailViewModel.toDoItem.alarmType == "위치" {
                ToDoViewFactory.makeToDoMoldView(
                    content:
                        VStack() {
                            Text("알림 위치 \n")
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            Text(toDoItemDetailViewModel.toDoItem.alarmLocationName ?? "")
                                .lineLimit(2)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                        }
                        .font(.custom("Binggrae", size: 15))
                        .frame(width: UIScreen.main.bounds.width - 80, alignment: .top),
                    height: 100
                )
            } else {
                ToDoViewFactory.makeToDoMoldView(
                    content: ToDoViewFactory.makeAlarmTimeView(
                        selection: .constant(toDoItemDetailViewModel.toDoItem.alarmTime ?? Date()),
                        title: "알림 시간",
                        displayedComponent: .hourAndMinute)
                )
                .disabled(true)
            }
            
            Spacer()
        }
        .padding()
        .navigationBarItems(
            trailing:
                Button(action: {
                    toDoItemDetailViewModel.showingToDoItemAddView = true
                }, label: {
                    Text("수정")
                })
                .frame(width: 50, height: 50)
                .fullScreenCover(isPresented: $toDoItemDetailViewModel.showingToDoItemAddView) {
                    let viewModel = ToDoItemAddViewModel(viewContext: viewContext, localNotificationManager: toDoItemDetailViewModel.localNotificationManager,
                        toDoItem: toDoItemDetailViewModel.toDoItem)
                    ToDoItemAddView(toDoItemAddViewModel: viewModel)
                }
        )
    }
}

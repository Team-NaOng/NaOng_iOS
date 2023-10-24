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
        VStack {
            ToDoViewFactory.makeToDoMoldView(
                content: ToDoViewFactory.makeToDoTextEditor(
                    title: "할 일 내용",
                    text: .constant(toDoItemDetailViewModel.toDoItem.content ?? "")),
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
            )
            
            if toDoItemDetailViewModel.toDoItem.alarmType == "위치" {
                ToDoViewFactory.makeToDoMoldView(
                    content:
                        VStack() {
                            Text("알림 위치 \n")
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                            // TODO: 수정
                            Text("알람 위치 들어갈 자리")
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
                    let viewModel = ToDoItemAddViewModel(viewContext: viewContext, localNotificationManager: toDoItemDetailViewModel.localNotificationManager)
                    ToDoItemAddView(toDoItemAddViewModel: viewModel)
                }
        )
    }
}

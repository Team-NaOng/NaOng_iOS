//
//  ToDoItemDetailView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/31.
//

import SwiftUI

struct ToDoItemDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var toDoItemDetailViewModel: ToDoItemDetailViewModel
    
    init(toDoItemDetailViewModel: ToDoItemDetailViewModel) {
        self.toDoItemDetailViewModel = toDoItemDetailViewModel
    }
    
    var body: some View {
        VStack {
            ToDoViewFactory.makeToDoMoldView(
                content: ToDoViewFactory.makeToDoTextEditor(
                    title: "할 일 내용",
                    text: $toDoItemDetailViewModel.content),
                height: 200
            )
            
            ToDoViewFactory.makeToDoMoldView(
                content: ToDoViewFactory.makeToDoDatePicker(
                    selection: $toDoItemDetailViewModel.alarmTime,
                    title: "진행 날짜",
                    displayedComponent: .date)
            )
            
            ToDoViewFactory.makeToDoMoldView(
                content: ToDoViewFactory.makeToDoToggle(
                    isOn: $toDoItemDetailViewModel.isRepeat,
                    title: "반복 여부")
            )
             
            ToDoViewFactory.makeToDoMoldView(
                content: ToDoViewFactory.makeToDoPicker(
                    title: "알림 타입",
                    selection: $toDoItemDetailViewModel.alarmType)
            )
            
            ToDoViewFactory.makeToDoMoldView(
                content: ToDoViewFactory.makeAlarmTimeView(
                    selection: $toDoItemDetailViewModel.alarmTime,
                    title: "알림 시간",
                    displayedComponent: .hourAndMinute)
            )
            
            Spacer()
        }
        .padding()
        .navigationBarItems(
            trailing:
                Button(action: {
                    toDoItemDetailViewModel.EditToDo()
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Text("저장")
                })
                .frame(width: 50, height: 50)
        )
    }
}

/*
struct ToDoItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoItemDetailView()
    }
}
*/

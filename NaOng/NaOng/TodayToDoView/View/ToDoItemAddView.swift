//
//  ToDoItemAddView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/06.
//

import SwiftUI

struct ToDoItemAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var toDoItemAddViewModel: ToDoItemAddViewModel
    
    init(toDoItemAddViewModel: ToDoItemAddViewModel) {
        self.toDoItemAddViewModel = toDoItemAddViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack() {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(Color("primary"))
                }
                .frame(width: UIScreen.main.bounds.width, alignment: .trailing)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 25))
                
                ToDoViewFactory.makeToDoTitle(
                    title: "할 일 추가하기",
                    fontName: "Binggrae-Bold",
                    fontSize: 30
                )
                .frame(width: UIScreen.main.bounds.width - 80,alignment: .leading)
                
                ScrollView {
                    ToDoViewFactory.makeToDoMoldView(
                        content: ToDoViewFactory.makeToDoTextEditor(
                            title: "할 일 내용",
                            text: $toDoItemAddViewModel.content),
                        height: 200
                    )
                    
                    //                ToDoViewFactory.makeToDoMoldView(
                    //                    content: ToDoViewFactory.makeToDoDatePicker(
                    //                        selection: $toDoItemAddViewModel.alarmTime,
                    //                        title: "진행 날짜",
                    //                        displayedComponent: .date)
                    //                )
                    //
                    ToDoViewFactory.makeToDoMoldView(
                        content: ToDoViewFactory.makeToDoToggle(
                            isOn: $toDoItemAddViewModel.isRepeat,
                            title: "반복 여부")
                    )
                    
                    ToDoViewFactory.makeToDoMoldView(
                        content: ToDoViewFactory.makeToDoPicker(
                            title: "알림 타입",
                            selection: $toDoItemAddViewModel.alarmType)
                    )
                    
                    if toDoItemAddViewModel.alarmType == "위치" {
                        ToDoViewFactory.makeToDoMoldView(
                            content: ToDoViewFactory.makeAlarmLocationView(
                                title: "알림 위치",
                                selectedLocation: toDoItemAddViewModel.location,
                                destination: LocationSelectionView(locationSelectionViewModel: LocationSelectionViewModel(viewContext: Location.viewContext)))
                        )
                    } else {
                        ToDoViewFactory.makeToDoMoldView(
                            content: ToDoViewFactory.makeAlarmTimeView(
                                selection: $toDoItemAddViewModel.alarmTime,
                                title: "알림 시간",
                                displayedComponent: [.hourAndMinute, .date])
                        )
                    }
                    
                    Spacer()
                    
                    Button {
                        toDoItemAddViewModel.addToDo()
                        dismiss()
                    } label: {
                        ToDoViewFactory.makeToDoMoldView(
                            content: ToDoViewFactory.makeToDoTitle(
                                title: "완료")
                            ,background: Color("primary")
                        )
                    }
                    .padding()
                }
            }
        }
    }
}

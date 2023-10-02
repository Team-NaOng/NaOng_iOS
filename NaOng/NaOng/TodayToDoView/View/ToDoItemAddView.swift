//
//  ToDoItemAddView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/06.
//

import SwiftUI


enum LocationViewStack {
    case first
    case second
    case third
}

struct ToDoItemAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var toDoItemAddViewModel: ToDoItemAddViewModel
    
    init(toDoItemAddViewModel: ToDoItemAddViewModel) {
        self.toDoItemAddViewModel = toDoItemAddViewModel
    }
    
    var body: some View {
        NavigationStack(path: $toDoItemAddViewModel.path) {
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
                    
                    ToDoViewFactory.makeToDoMoldView(
                        content: ToDoViewFactory.makeToDoDatePicker(
                            selection: $toDoItemAddViewModel.alarmTime,
                            title: "알림 날짜",
                            displayedComponent: .date)
                    )
                    
                    if toDoItemAddViewModel.alarmType == "위치" {
                        ToDoViewFactory.makeToDoMoldView(
                            content: Button {
                                toDoItemAddViewModel.addPath(.first)
                            } label: {
                                ToDoViewFactory.makeAlarmLocationView(
                                    title: "알람 위치",
                                    selectedLocation: toDoItemAddViewModel.locationInformation.locationName
                                )
                            }
                        )
                    } else {
                        ToDoViewFactory.makeToDoMoldView(
                            content: ToDoViewFactory.makeAlarmTimeView(
                                selection: $toDoItemAddViewModel.alarmTime,
                                title: "알림 시간",
                                displayedComponent: .hourAndMinute)
                        )
                    }
                    
                    Spacer()
                    
                    Button {
                        toDoItemAddViewModel.addToDo()
                        toDoItemAddViewModel.addLocation()
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
            .navigationDestination(for: LocationViewStack.self) { myStack in
                switch myStack {
                case .first:
                    let locationSelectionViewModel = LocationSelectionViewModel(viewContext: Location.viewContext)
                    LocationSelectionView(
                        locationSelectionViewModel: locationSelectionViewModel,
                        path: $toDoItemAddViewModel.path,
                        locationInformation: $toDoItemAddViewModel.locationInformation)
                case .second:
                    let locationSearchViewModel = LocationSearchViewModel()
                    LocationSearchView(
                        locationSearchViewModel: locationSearchViewModel,
                        path: $toDoItemAddViewModel.path,
                        locationInformation: $toDoItemAddViewModel.locationInformation)
                case .third:
                    let locationCheckViewModel = LocationCheckViewModel()
                    LocationCheckView(
                        locationCheckViewModel: locationCheckViewModel,
                        path: $toDoItemAddViewModel.path,
                        locationInformation: $toDoItemAddViewModel.locationInformation)
                }
            }
        }
    }
}

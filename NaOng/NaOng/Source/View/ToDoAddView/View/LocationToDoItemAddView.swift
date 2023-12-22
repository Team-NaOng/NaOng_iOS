//
//  LocationToDoItemAddView.swift
//  NaOng
//
//  Created by seohyeon park on 11/22/23.
//

import SwiftUI

enum LocationViewStack {
    case first
    case second
    case third
}

struct LocationToDoItemAddView: View {
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
                        .foregroundStyle(Color("primary"))
                }
                .frame(width: UIScreen.main.bounds.width, alignment: .trailing)
                .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 60))
                
                ToDoViewFactory.makeToDoTitle(
                    title: toDoItemAddViewModel.getToDoTitle(),
                    fontName: "Binggrae-Bold",
                    fontSize: 30
                )
                .frame(width: UIScreen.main.bounds.width - 60,alignment: .leading)
                
                ScrollView {
                    VStack(spacing: 10) {
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
                            content: Button {
                                toDoItemAddViewModel.addPath(.first)
                            } label: {
                                ToDoViewFactory.makeAlarmLocationView(
                                    title: "알람 위치",
                                    selectedLocation: toDoItemAddViewModel.locationInformation.locationName
                                )
                            }
                        )

                        Button {
                            if toDoItemAddViewModel.addEditToDo() {
                                toDoItemAddViewModel.addLocation()
                                dismiss()
                            }
                        } label: {
                            ToDoViewFactory.makeToDoMoldView(
                                content: ToDoViewFactory.makeToDoTitle(
                                    title: "완료")
                                ,background: Color("primary")
                            )
                        }
                        .padding()
                        .alert(isPresented: $toDoItemAddViewModel.isShowingErrorAlert) {
                            Alert(
                                title: Text(toDoItemAddViewModel.errorTitle),
                                message: Text(toDoItemAddViewModel.errorMessage),
                                dismissButton: .default(Text("확인"))
                            )
                        }
                    }
                }
                
                Spacer()
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

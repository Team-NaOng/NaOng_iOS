//
//  ToDoListItemView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/06/25.
//

import SwiftUI
import Combine

struct ToDoListItemView2: View {
    @ObservedObject private var toDoListItemViewModel: ToDoListItemViewModel
    @GestureState private var myOffset = CGSize.zero
    
    init(toDoListItemViewModel: ToDoListItemViewModel) {
        self.toDoListItemViewModel = toDoListItemViewModel
    }

    var body: some View {
        ZStack(alignment: .top) {
            // trash View
            HStack {
                Button {
                    print("오잉")
                } label: {
                    Image(systemName: "trash")
                        .font(.title)
                        .foregroundColor(.black)
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                
                Spacer()
            }
            .frame(width: UIScreen.main.bounds.width - 50, height: 80)
            .background(Color(.red))
            .offset(x: (UIScreen.main.bounds.width - 50) - abs(myOffset.width))
            
            // Item View
            HStack(alignment: .top) {
                Button {
                    toDoListItemViewModel.didTapDoneButton()
                } label: {
                    Image(toDoListItemViewModel.markerName)
                        .resizable()
                        .frame(width: 30, height: 30, alignment: .center)
                }
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))

                Text(toDoListItemViewModel.toDoItem.content ?? "")
                    .font(.custom("Binggrae", size: 15))
                    .strikethrough(toDoListItemViewModel.toDoItem.isDone)
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))
                    .frame(width: (UIScreen.main.bounds.width - 60) * 0.6 , height: 80, alignment: .topLeading)

                Text("01:00")
                    .font(.custom("Binggrae", size: 12))
                    .foregroundColor(.black)
                    .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
                    .frame(width: (UIScreen.main.bounds.width - 60) * 0.2 , height: 80, alignment: .topTrailing)
            }
            .background(Color(toDoListItemViewModel.backgroundColor))
            .offset(x: myOffset.width)
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 3)
        )
        .padding(10)
//        .gesture(DragGesture()
//            .updating($myOffset) { value, state, _ in
//                let deleteViewWidth = abs(value.translation.width)
//                let itemViewHalfWidth = (UIScreen.main.bounds.width - 50) / 2
//
//                if deleteViewWidth < itemViewHalfWidth {
//                    state = value.translation
//                } else if deleteViewWidth > itemViewHalfWidth {
//                    Task {
//                        withAnimation(.interactiveSpring()) {
//                            toDoListItemViewModel.deleteToDoItem()
//                        }
//                    }
//                }
//            }
//        )
//        .gesture(TapGesture()
//            .onEnded({ _ in
//            })
//        )
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            toDoListItemViewModel.setMarkerName()
            toDoListItemViewModel.setBackgroundColor()
        }
    }
}


struct ToDoListItemView2_Previews: PreviewProvider {
    static var previews: some View {
        let context = ToDoCoreDataManager.shared.persistentContainer.viewContext
        let toDo = ToDo(context: context)
        let toDoListItemViewModel = ToDoListItemViewModel(toDoItem: toDo)
        ToDoListItemView2(toDoListItemViewModel: toDoListItemViewModel)
    }
}


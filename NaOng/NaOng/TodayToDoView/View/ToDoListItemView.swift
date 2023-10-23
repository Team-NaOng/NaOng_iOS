//
//  ToDoListItemView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/06/25.
//

import SwiftUI

struct ToDoListItemView: View {
    @ObservedObject private var toDoListItemViewModel: ToDoListItemViewModel
    
    init(toDoListItemViewModel: ToDoListItemViewModel) {
        self.toDoListItemViewModel = toDoListItemViewModel
    }
    
    var body: some View {
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
            
            Text(toDoListItemViewModel.getDistinguishedAlarmInformation())
                .font(.custom("Binggrae", size: 12))
                .foregroundColor(.black)
                .padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 10))
                .frame(width: (UIScreen.main.bounds.width - 60) * 0.2 , height: 80, alignment: .topTrailing)
        }
        .background(Color(toDoListItemViewModel.backgroundColor))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.black, lineWidth: 3)
        )
        .padding(10)
        .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
            toDoListItemViewModel.setMarkerName()
            toDoListItemViewModel.setBackgroundColor()
        }
    }
}

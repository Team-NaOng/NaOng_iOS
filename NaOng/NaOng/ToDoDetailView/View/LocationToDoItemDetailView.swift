//
//  LocationToDoItemDetailView.swift
//  NaOng
//
//  Created by seohyeon park on 11/22/23.
//

import SwiftUI

struct LocationToDoItemDetailView: View {
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
                content:
                    HStack {
                        ToDoViewFactory.makeToDoTitle(title: "알림 타입")
                            .frame(width: (UIScreen.main.bounds.width - 90) / 2, alignment: .leading)
                        
                        Spacer()
                        
                        Text("위치")
                            .font(.custom("Binggrae", size: 15))
                            .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                            .background(Color(UIColor.systemGray4))
                            .cornerRadius(10)
                            
                    }
                    .frame(width: (UIScreen.main.bounds.width - 80))
            )
            
            ToDoViewFactory.makeToDoMoldView(
                content:
                    VStack(spacing: 0) {
                        Text("알림 위치")
                            .frame(width: UIScreen.main.bounds.width - 80, height: 30, alignment: .topLeading)

                        Text(toDoItemDetailViewModel.toDoItem.alarmLocationName ?? "")
                            .padding(10)
                            .lineLimit(2)
                            .frame(width: UIScreen.main.bounds.width - 80, height: 70, alignment: .topLeading)
                            .background(Color.white)
                            .cornerRadius(10)
                    }
                    .font(.custom("Binggrae", size: 15)),
                height: 120
            )

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
                    let viewModel = ToDoItemAddViewModel(
                        viewContext: viewContext,
                        localNotificationManager: toDoItemDetailViewModel.localNotificationManager,
                        toDoItem: toDoItemDetailViewModel.toDoItem,
                        alarmType: toDoItemDetailViewModel.toDoItem.alarmType ?? "시간")
                    
                    if toDoItemDetailViewModel.toDoItem.alarmType == "위치" {
                       LocationToDoItemAddView(toDoItemAddViewModel: viewModel)
                    }
                    //ToDoItemAddView(toDoItemAddViewModel: viewModel)
                }
        )
    }
}


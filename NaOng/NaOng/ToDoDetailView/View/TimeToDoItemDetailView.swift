//
//  TimeToDoItemDetailView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/31.
//

import SwiftUI

struct TimeToDoItemDetailView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject private var toDoItemDetailViewModel: ToDoItemDetailViewModel
    
    init(toDoItemDetailViewModel: ToDoItemDetailViewModel) {
        self.toDoItemDetailViewModel = toDoItemDetailViewModel
    }
    
    var body: some View {
        VStack(spacing: 15) {
            ToDoViewFactory.makeToDoDetailMoldView(
                title: "할일 목록",
                content:
                    ScrollView {
                        Text(toDoItemDetailViewModel.toDoItem.content ?? "")
                            .font(.custom("Binggrae", size: 15))
                            .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
                            .frame(width: UIScreen.main.bounds.width, alignment: .leading)
                    }
                    .frame(height: 140)
                    .background(Color("tertiary"))
            )

            ToDoViewFactory.makeToDoToggle(
                isOn: .constant(toDoItemDetailViewModel.toDoItem.isRepeat),
                title: "반복 여부",
                width: UIScreen.main.bounds.width - 30)
            .padding()
            .frame(width: (UIScreen.main.bounds.width), height: 50)
            .background(Color("primary").opacity(0.5))
            
            HStack {
                ToDoViewFactory.makeToDoTitle(title: "알림 타입")
                    .frame(width: (UIScreen.main.bounds.width - 90) / 2, alignment: .leading)
                
                Spacer()
                
                Text("시간")
                    .font(.custom("Binggrae", size: 15))
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .background(.white)
                    .cornerRadius(10)
                
            }
            .padding()
            .frame(width: (UIScreen.main.bounds.width), height: 50)
            .background(Color("primary").opacity(0.5))
            
            HStack {
                ToDoViewFactory.makeToDoTitle(title: "알림 날짜")
                    .frame(width: (UIScreen.main.bounds.width - 90) / 2, alignment: .leading)
                
                Spacer()
                
                Text(toDoItemDetailViewModel.toDoItem.alarmTime?.getFormatDate("yyyy-mm-dd-E") ?? "알 수 없음")
                    .font(.custom("Binggrae", size: 15))
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .background(.white)
                    .cornerRadius(10)
                
            }
            .padding()
            .frame(width: (UIScreen.main.bounds.width), height: 50)
            .background(Color("primary").opacity(0.5))

            HStack {
                ToDoViewFactory.makeToDoTitle(title: "알림 날짜")
                    .frame(width: (UIScreen.main.bounds.width - 90) / 2, alignment: .leading)
                
                Spacer()
                
                Text(toDoItemDetailViewModel.toDoItem.alarmTime?.getFormatDate("hh:mm") ?? "알 수 없음")
                    .font(.custom("Binggrae", size: 15))
                    .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
                    .background(.white)
                    .cornerRadius(10)
            }
            .padding()
            .frame(width: (UIScreen.main.bounds.width), height: 50)
            .background(Color("primary").opacity(0.5))

            DoneView()
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
                    TimeToDoItemAddView(toDoItemAddViewModel: viewModel)
                }
        )
    }
}

//
//  ToDoListView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/02.
//

import SwiftUI

struct ToDoListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject private var toDoListViewModel: ToDoListViewModel
    
    init(toDoListViewModel: ToDoListViewModel) {
        self.toDoListViewModel = toDoListViewModel
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("나가기 전에 생각했나옹?")
                    .foregroundColor(.black)
                    .font(.custom("Binggrae-Bold", size: 30))
                    .padding()
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: UIScreen.main.bounds.width - 30, height: 316)
                        .foregroundColor(Color("secondary"))
                    
                    if $toDoListViewModel.toDoItems.count == 0 {
                        Text("오늘 할 일이 없어요. \n 아래 고양이를 눌러 \n 할 일을 추가해 보세요!")
                            .foregroundColor(.black)
                            .font(.custom("Binggrae", size: 20))
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        List {
                            ForEach($toDoListViewModel.toDoItems) { item in
                                let localNotificationManager = LocalNotificationManager()
                                let viewModel = ToDoListItemViewModel(toDoItem: item.wrappedValue, viewContext: viewContext, localNotificationManager: localNotificationManager)
                                ToDoListItemView(toDoListItemViewModel: viewModel)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .overlay {
                                        NavigationLink {
                                            let toDoItemDetailViewModel = ToDoItemDetailViewModel(viewContext: viewContext, toDoItem: item.wrappedValue, localNotificationManager: LocalNotificationManager())
                                            ToDoItemDetailView(toDoItemDetailViewModel: toDoItemDetailViewModel)
                                        } label: {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                    }
                                    .background(Color("secondary"))
                            }
                            .onDelete { indexSet in
                                withAnimation {
                                    toDoListViewModel.deleteItems(offsets: indexSet)
                                }
                            }
                        }
                        .listStyle(.plain)
                        .buttonStyle(.plain)
                        .background(Color("secondary"))
                        .frame(width: UIScreen.main.bounds.width - 50, height: 300)
                    }
                }
                
                Button {
                    toDoListViewModel.showingToDoItemAddView = true
                } label: {
                    Image("toDoListImage1")
                        .resizable()
                        .scaledToFit()
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                }
                .fullScreenCover(isPresented: $toDoListViewModel.showingToDoItemAddView) {
                    let viewModel = ToDoItemAddViewModel(viewContext: viewContext)
                    ToDoItemAddView(toDoItemAddViewModel: viewModel)
                }
            }
            .background(
                Image("backgroundPinkImage")
            )
        }
    }
}

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
        
        UISegmentedControl.appearance().setTitleTextAttributes([.font : UIFont(name: "Binggrae", size: 15) as Any], for: .normal)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("나가기 전에 생각했나옹?")
                    .foregroundColor(.black)
                    .font(.custom("Binggrae-Bold", size: 30))
                    .padding()
                
                Picker("보기 옵션", selection: $toDoListViewModel.selectedViewOption) {
                    Text("전체")
                        .tag("전체")
                    Text("위치")
                        .tag("위치")
                    Text("시간")
                        .tag("시간")
                    Text("반복")
                        .tag("반복")
                }
                .pickerStyle(.segmented)
                .frame(width: UIScreen.main.bounds.width - 30)
                .onChange(of: toDoListViewModel.selectedViewOption) { newValue in
                    toDoListViewModel.setFetchedResultsPredicate()
                }
                
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
                                let viewModel = ToDoListItemViewModel(toDoItem: item.wrappedValue, viewContext: viewContext, localNotificationManager: toDoListViewModel.localNotificationManager)
                                ToDoListItemView(toDoListItemViewModel: viewModel)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .overlay {
                                        NavigationLink {
                                            let toDoItemDetailViewModel = ToDoItemDetailViewModel(viewContext: viewContext, toDoItem: item.wrappedValue, localNotificationManager: toDoListViewModel.localNotificationManager)
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
                    toDoListViewModel.addModel = ToDoItemAddViewModel(viewContext: viewContext, localNotificationManager: toDoListViewModel.localNotificationManager)
                } label: {
                    Image("toDoListImage1")
                        .resizable()
                        .scaledToFit()
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                }
                .fullScreenCover(isPresented: $toDoListViewModel.showingToDoItemAddView) {
                    toDoListViewModel.addModel = nil
                } content: {
                    if let viewModel = toDoListViewModel.addModel {
                        ToDoItemAddView(toDoItemAddViewModel: viewModel)
                    }
                }
            }
            .background(
                Image("backgroundPinkImage")
            )
            .alert(isPresented: $toDoListViewModel.showErrorAlert) {
                Alert(
                    title: Text(toDoListViewModel.errorTitle),
                    message: Text(toDoListViewModel.errorMessage),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
        .onAppear(perform: {
            toDoListViewModel.bind()
        })
    }
}

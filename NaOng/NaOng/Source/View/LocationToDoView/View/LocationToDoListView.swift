//
//  LocationToDoListView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/02.
//

import SwiftUI

struct LocationToDoListView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject private var locationToDoListViewModel: LocationToDoListViewModel
    @ObservedObject private var alertViewModel = AlertViewModel()
    
    init(locationToDoListViewModel: LocationToDoListViewModel) {
        self.locationToDoListViewModel = locationToDoListViewModel
        
        UISegmentedControl.appearance().setTitleTextAttributes([.font : UIFont(name: "Binggrae", size: 15) as Any], for: .normal)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Text("나가기 전에 생각했나옹?")
                    .foregroundStyle(.black)
                    .font(.custom("Binggrae-Bold", size: 30))
                    .padding()
                
                Picker("보기 옵션", selection: $locationToDoListViewModel.selectedViewOption) {
                    Text("전체")
                        .tag("전체")
                    Text("한번")
                        .tag("한번")
                    Text("반복")
                        .tag("반복")
                }
                .pickerStyle(.segmented)
                .frame(width: UIScreen.main.bounds.width - 30)
                .onChange(of: locationToDoListViewModel.selectedViewOption) { newValue in
                    locationToDoListViewModel.setFetchedResultsPredicate()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: UIScreen.main.bounds.width - 30, height: 316)
                        .foregroundStyle(Color("secondary"))
                    
                    if $locationToDoListViewModel.toDoItems.count == 0 {
                        Text("할 일이 없어요. \n 아래 고양이를 눌러 \n 위치 할 일을 추가해 보세요!")
                            .foregroundStyle(.black)
                            .font(.custom("Binggrae", size: 20))
                            .multilineTextAlignment(.center)
                            .padding()
                    } else {
                        List {
                            ForEach($locationToDoListViewModel.toDoItems) { item in
                                let viewModel = ToDoItemViewModel(toDoItem: item.wrappedValue, viewContext: viewContext, localNotificationManager: locationToDoListViewModel.localNotificationManager, alertViewModel: alertViewModel)
                                ToDoItemView(toDoItemViewModel: viewModel)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(.init(top: 0, leading: 0, bottom: 0, trailing: 0))
                                    .overlay {
                                        NavigationLink {
                                            let toDoItemDetailViewModel = ToDoItemDetailViewModel(viewContext: viewContext, toDoItem: item.wrappedValue, localNotificationManager: locationToDoListViewModel.localNotificationManager)
                                            LocationToDoItemDetailView(toDoItemDetailViewModel: toDoItemDetailViewModel)
                                        } label: {
                                            EmptyView()
                                        }
                                        .opacity(0)
                                    }
                                    .background(Color("secondary"))
                            }
                            .onDelete { indexSet in
                                withAnimation {
                                    locationToDoListViewModel.deleteItems(offsets: indexSet)
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
                    locationToDoListViewModel.isShowingToDoItemAddView = true
                    locationToDoListViewModel.addModel = ToDoItemAddViewModel(viewContext: viewContext, localNotificationManager: locationToDoListViewModel.localNotificationManager, alarmType: "위치")
                } label: {
                    Image("toDoListImage1")
                        .resizable()
                        .scaledToFit()
                        .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                }
                .fullScreenCover(isPresented: $locationToDoListViewModel.isShowingToDoItemAddView) {
                    locationToDoListViewModel.addModel = nil
                } content: {
                    if let viewModel = locationToDoListViewModel.addModel {
                        LocationToDoItemAddView(toDoItemAddViewModel: viewModel)
                    }
                }
            }
            .background(
                Image("backgroundPinkImage")
            )
            .alert(isPresented: $alertViewModel.isShowingAlert) {
                Alert(
                    title: Text(alertViewModel.alertTitle),
                    message: Text(alertViewModel.alertMessage),
                    dismissButton: .default(Text("확인"))
                )
            }
        }
    }
}

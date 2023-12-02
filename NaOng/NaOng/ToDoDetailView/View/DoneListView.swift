//
//  DoneListView.swift
//  NaOng
//
//  Created by seohyeon park on 12/3/23.
//

import SwiftUI

struct DoneListView: View {
    @ObservedObject private var doneListViewModel: DoneListViewModel

    init(doneListViewModel: DoneListViewModel) {
        self.doneListViewModel = doneListViewModel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ToDoViewFactory.makeToDoTitle(title: "완료 목록")

                Spacer()
                
                Button(action: {
                    withAnimation {
                        doneListViewModel.showingList.toggle()
                    }
                }, label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(doneListViewModel.showingList ? -90 : 0))
                        .animation(.easeInOut, value: doneListViewModel.showingList)
                        .foregroundStyle(.black)
                })
            }
            .padding()
            .background(Color("primary").opacity(0.5))
            .frame(width: (UIScreen.main.bounds.width))
            
            List {
                ForEach(0..<doneListViewModel.doneList.count, id: \.self) { index in
                    HStack {
                        Image("doneMarker", bundle: .main)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 20, height: 20)
                            .clipShape(.circle)
                        ToDoViewFactory.makeToDoTitle(title: "\(doneListViewModel.doneList[index][0]) 완료")

                        Spacer()
                        
                        ToDoViewFactory.makeToDoTitle(title: doneListViewModel.doneList[index][1])
                    }
                }
            }
            .listRowSpacing(10.0)
            .listStyle(.insetGrouped)
            .frame(width: UIScreen.main.bounds.width)
            .hideView(doneListViewModel.showingList)
        }
    }
}

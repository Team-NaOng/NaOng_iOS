//
//  DoneView.swift
//  NaOng
//
//  Created by seohyeon park on 12/3/23.
//

import SwiftUI

struct DoneView: View {
    @State private var isShow: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                ToDoViewFactory.makeToDoTitle(title: "완료 목록")

                Spacer()
                
                Button(action: {
                    withAnimation {
                        isShow.toggle()
                    }
                }, label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isShow ? -90 : 0))
                        .animation(.easeInOut, value: isShow)
                        .foregroundStyle(.black)
                })
            }
            .padding()
            .background(Color("primary").opacity(0.5))
            .frame(width: (UIScreen.main.bounds.width))
            
            DoneListView()
            .hideView(isShow)
        }
    }
}

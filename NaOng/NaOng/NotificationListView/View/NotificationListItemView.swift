//
//  NotificationListItemView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/13.
//

import SwiftUI

struct NotificationListItemView: View {
    var toDo: ToDo
    
    var body: some View {
        HStack(alignment: .top) {
            Image(toDo.alarmType == "위치" ? "locationMarker" : "timeMarker")
                .resizable()
                .scaledToFit()
                .frame(width:25)
            
            Text(toDo.content ?? "")
                .font(.custom("Binggrae", size: 15))
                .foregroundColor(.black)
                .frame(width: (UIScreen.main.bounds.width - 60) * 0.6 , height: 25, alignment: .topLeading)
            
            Spacer()
        }
        .padding(10)
        .background(Color("secondary"))
        .cornerRadius(5)
    }
}

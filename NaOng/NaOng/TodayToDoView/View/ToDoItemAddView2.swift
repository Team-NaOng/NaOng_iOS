//
//  ToDoItemAddView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/06.
//

import SwiftUI

struct ToDoItemAddView2: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @ObservedObject private var toDoItemAddViewModel: ToDoItemAddViewModel
    
    init(toDoItemAddViewModel: ToDoItemAddViewModel) {
        self.toDoItemAddViewModel = toDoItemAddViewModel
    }
    
    var body: some View {
        VStack() {
            Button {
                dismiss()
            } label: {
                Image(systemName: "x.circle")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(Color("primary"))
            }
            .frame(width: UIScreen.main.bounds.width, alignment: .trailing)
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 25))
            
            Text("할 일 추가하기")
                .foregroundColor(.black)
                .font(.custom("Binggrae-Bold", size: 30))
                .frame(width: UIScreen.main.bounds.width - 80,alignment: .leading)

            ZStack() {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 5)
                    .frame(width: UIScreen.main.bounds.width - 60, height: 200)
                    .background(Color("secondary"))
                
                VStack(alignment: .leading) {
                    Text("할 일 내용")
                        .font(.custom("Binggrae", size: 15))
                        .foregroundColor(.black)
                    
                    TextEditor(text: $toDoItemAddViewModel.content)
                        .frame(width: UIScreen.main.bounds.width - 80, height: 140)
                        .cornerRadius(10)
                }
            }
            .cornerRadius(10)
            
            ZStack() {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 5)
                    .frame(width: UIScreen.main.bounds.width - 60, height: 50)
                    .background(Color("secondary"))
                
                DatePicker(selection: $toDoItemAddViewModel.alarmTime, displayedComponents: [.date]) {
                    Text("진행 날짜")
                        .font(.custom("Binggrae", size: 15))
                        .foregroundColor(.black)
                }
                .frame(width: UIScreen.main.bounds.width - 80)
            }
            .cornerRadius(10)
            
            ZStack() {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 5)
                    .frame(width: UIScreen.main.bounds.width - 60, height: 50)
                    .background(Color("secondary"))
                
                Toggle(isOn: $toDoItemAddViewModel.isRepeat) {
                    Text("반복 여부")
                        .font(.custom("Binggrae", size: 15))
                        .foregroundColor(.black)
                }
                .frame(width: UIScreen.main.bounds.width - 80)
                .tint(Color("primary"))
            }
            .cornerRadius(10)
            
            ZStack() {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 5)
                    .frame(width: UIScreen.main.bounds.width - 60, height: 50)
                    .background(Color("secondary"))
                
                HStack {
                    Text("알림 타입")
                        .font(.custom("Binggrae", size: 15))
                        .foregroundColor(.black)
                        .frame(width: (UIScreen.main.bounds.width - 90) / 2, alignment: .leading)
                    
                    Picker("", selection: $toDoItemAddViewModel.alarmType) {
                        Text("위치").tag("위치")
                        Text("시간").tag("시간")
                    }
                    .pickerStyle(.segmented)
                    .frame(width: (UIScreen.main.bounds.width - 90) / 2, alignment: .trailing)
                }
                .frame(width: UIScreen.main.bounds.width - 80)
            }
            .cornerRadius(10)
            
            ZStack() {
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 5)
                    .frame(width: UIScreen.main.bounds.width - 60, height: 50)
                    .background(Color("secondary"))
                
                if toDoItemAddViewModel.alarmType == "위치" {
                    
                } else {
                    DatePicker(selection: $toDoItemAddViewModel.alarmTime, displayedComponents: [.hourAndMinute]) {
                        Text("알림 시간")
                            .font(.custom("Binggrae", size: 15))
                            .foregroundColor(.black)
                    }
                    .frame(width: UIScreen.main.bounds.width - 80)
                }
            }
            .cornerRadius(10)
            .padding(-3)
            .hideView(toDoItemAddViewModel.alarmType == "위치" ? true : false )
            
            Spacer()
            
            Button {
                toDoItemAddViewModel.addToDo()
                dismiss()
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .frame(width: UIScreen.main.bounds.width - 60, height: 50)
                        .foregroundColor(Color("primary"))
                    
                    Text("완료")
                        .font(.custom("Binggrae", size: 15))
                        .foregroundColor(.black)
                }
            }
            
            Spacer()
        }
    }
}

/*
struct ToDoItemAddView2_Previews: PreviewProvider {
    static var previews: some View {
        ToDoItemAddView2()
    }
}
*/

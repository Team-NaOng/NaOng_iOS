//
//  CustomDatePickerView.swift
//  NaOng
//
//  Created by seohyeon park on 12/20/23.
//

import SwiftUI

struct CustomDatePickerView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject private var customDatePickerViewModel: CustomDatePickerViewModel
    
    init(customDatePickerViewModel: CustomDatePickerViewModel) {
        self.customDatePickerViewModel = customDatePickerViewModel
    }
    
    var body: some View {
        VStack {
            HStack() {
                Text(customDatePickerViewModel.selectedDate.getFormatDate("yyyy MMMM", locale: "en_US"))
                    .font(.headline)
                
                Button(action: {
                    //TODO: 월 / 년 선택하는 picker 추가하기
                    
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .tint(.gray)
                })
                
                Spacer(minLength: 0)
                
                Button(action: {
                    withAnimation {
                        customDatePickerViewModel.currentMonth -= 1
                    }
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .tint(Color(UIColor.gray))
                })
                .frame(width: 25)
                
                Button(action: {
                    withAnimation {
                        customDatePickerViewModel.currentMonth += 1
                    }
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .tint(Color(UIColor.gray))
                })
                .frame(width: 25, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 10, leading: 5, bottom: 10, trailing: 5))
            
            HStack {
                ForEach(customDatePickerViewModel.days, id: \.self) { day in
                    Text(day)
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color(UIColor.lightGray))
                        .frame(maxWidth: .infinity)
                }
            }
            
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            LazyVGrid(columns: columns) {
                ForEach(customDatePickerViewModel.dateValues) { value in
                    DatesView(
                        value: value,
                        isSelected: value.date.isSameDay(as: customDatePickerViewModel.selectedDate),
                        isToday: value.date.isSameDay(as: Date())
                    )
                    .background(
                        Circle()
                            .fill(Color(UIColor.systemGray5))
                            .opacity(value.date.isSameDay(as: customDatePickerViewModel.selectedDate) ? 1 : 0)
                    )
                    .onTapGesture {
                        customDatePickerViewModel.selectedDate = value.date
                    }
                }
            }
            .onChange(of: customDatePickerViewModel.currentMonth) { newValue in
                customDatePickerViewModel.fetchDates()
            }
        }
    }
}

extension CustomDatePickerView {
    @ViewBuilder
    func DatesView(value: DateValue, isSelected: Bool, isToday: Bool) -> some View {
        VStack(spacing: 3) {
            if value.day != -1 {
                let isToDoInCurrentMonth = customDatePickerViewModel.toDoInCurrentMonth.contains(value.date.getFormatDate())
                Text("\(value.day)")
                    .font(isToday ? .headline : .body)
                    .foregroundStyle(isToday ? .black : .gray)
                    .frame(maxWidth: .infinity)
                
                Circle()
                    .fill(isToDoInCurrentMonth ? Color("primary") : isSelected ? Color(UIColor.systemGray5) : .white)
                    .frame(width: 8, height: 8)
            }
        }
        .frame(height: 30, alignment: .top)
        .padding(.vertical, 5)
    }
}


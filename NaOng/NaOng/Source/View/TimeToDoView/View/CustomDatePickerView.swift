//
//  CustomDatePickerView.swift
//  NaOng
//
//  Created by seohyeon park on 12/20/23.
//

import SwiftUI

struct CustomDatePickerView: View {
    @Environment(\.managedObjectContext) var viewContext
    @ObservedObject private var timeToDoListViewModel: TimeToDoListViewModel
    
    init(timeToDoListViewModel: TimeToDoListViewModel) {
        self.timeToDoListViewModel = timeToDoListViewModel
    }
    
    var body: some View {
        VStack {
            HStack() {
                Text(timeToDoListViewModel.selectedDate.getFormatDate("yyyy MMMM", locale: "en_US"))
                    .font(.headline)
                
                Button(action: {
                    timeToDoListViewModel.isPickerPresented.toggle()
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.body)
                        .tint(.gray)
                })
                
                Spacer(minLength: 0)
                
                Button(action: {
                    timeToDoListViewModel.decreaseMonth()
                }, label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .tint(Color(UIColor.gray))
                })
                .frame(width: 25)
                
                Button(action: {
                    timeToDoListViewModel.increaseMonth()
                }, label: {
                    Image(systemName: "chevron.right")
                        .font(.headline)
                        .tint(Color(UIColor.gray))
                })
                .frame(width: 25, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
            .padding(EdgeInsets(top: 20, leading: 5, bottom: 20, trailing: 5))
            
            if timeToDoListViewModel.isPickerPresented {
                let customWheelPickerViewModel = CustomWheelPickerViewModel(selectedDate: $timeToDoListViewModel.selectedDate)
                CustomWheelPickerView(customWheelPickerViewModel: customWheelPickerViewModel)
                .onDisappear(perform: {
                    customWheelPickerViewModel.setSelectedDate()
                })
                .onTapGesture {
                    timeToDoListViewModel.isPickerPresented.toggle()
                }
            } else {
                HStack {
                    ForEach(timeToDoListViewModel.days, id: \.self) { day in
                        Text(day)
                            .font(.footnote)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color(UIColor.lightGray))
                            .frame(maxWidth: .infinity)
                    }
                }
                
                let columns = Array(repeating: GridItem(.flexible()), count: 7)
                LazyVGrid(columns: columns) {
                    ForEach(timeToDoListViewModel.dateValues) { value in
                        DatesView(
                            value: value,
                            isSelected: value.date.isSameDay(as: timeToDoListViewModel.selectedDate),
                            isToday: value.date.isSameDay(as: Date())
                        )
                        .background(
                            Circle()
                                .fill(Color(UIColor.systemGray5))
                                .opacity(value.date.isSameDay(as: timeToDoListViewModel.selectedDate) ? 1 : 0)
                        )
                        .onTapGesture {
                            timeToDoListViewModel.selectedDate = value.date
                        }
                    }
                }
                .frame(height: 280)
            }
        }
    }
}

extension CustomDatePickerView {
    @ViewBuilder
    func DatesView(value: DateValue, isSelected: Bool, isToday: Bool) -> some View {
        VStack(spacing: 3) {
            if value.day != -1 {
                let isToDoInCurrentMonth = value.hasMark
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


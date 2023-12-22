//
//  CustomWheelPickerView.swift
//  NaOng
//
//  Created by seohyeon park on 12/23/23.
//

import SwiftUI

struct CustomWheelPickerView: View {
    @ObservedObject private var customWheelPickerViewModel: CustomWheelPickerViewModel
    init(customWheelPickerViewModel: CustomWheelPickerViewModel) {
        self.customWheelPickerViewModel = customWheelPickerViewModel
    }
    
    var body: some View {
        HStack(spacing: 0) {
            Picker("Month",selection: $customWheelPickerViewModel.currentMonth) {
                ForEach(customWheelPickerViewModel.months, id: \.self) { month in
                    Text(month)
                }
            }
            .pickerStyle(.wheel)
            .clipShape(.rect.offset(x: -16))
            .padding(.trailing, -16)
            
            Picker("Year",selection:  $customWheelPickerViewModel.currentYear) {
                ForEach(customWheelPickerViewModel.years, id: \.self) { year in
                    Text(String(year))
                }
            }
            .pickerStyle(.wheel)
            .clipShape(.rect.offset(x: 16))
            .padding(.leading, -16)
        }
        .padding()
    }
}

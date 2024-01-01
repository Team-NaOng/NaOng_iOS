//
//  CustomWheelPickerViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 12/23/23.
//

import Foundation
import SwiftUI

class CustomWheelPickerViewModel: NSObject, ObservableObject {
    @Published var currentMonth: String = ""
    @Published var currentYear: Int = 0
    @Binding private var selectedDate: Date
    private(set) var months: [String] = []
    private(set) var years: [Int] = []
    
    init(selectedDate: Binding<Date>) {
        _selectedDate = selectedDate
        super.init()
        setProperties()
    }
    
    func setSelectedDate(){
        let selectedDateWithWheel = "\(currentMonth) \(String(currentYear))"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        dateFormatter.locale = Locale(identifier: "en_GB")
        
        if let date = dateFormatter.date(from: selectedDateWithWheel) {
            selectedDate = date
        }
    }
    
    private func setProperties() {
        let year = Calendar.current.component(.year, from: Date())
        years = Array(stride(from: year, to: year + 10, by: 1))
        months = getMonths()
        currentMonth = months[Calendar.current.component(.month, from: selectedDate) - 1]
        currentYear = Calendar.current.component(.year, from: selectedDate)
    }
    
    private func getMonths() -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM"
        dateFormatter.locale = Locale(identifier: "en_GB")
        return dateFormatter.monthSymbols
    }
}

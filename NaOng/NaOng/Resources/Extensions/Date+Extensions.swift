//
//  Date+Extensions.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/11.
//

import Foundation

extension Date {
    func isSameDay(as otherDate: Date) -> Bool {
        return Calendar.current.isDate(self, inSameDayAs: otherDate)
    }

    func getFormatDate(_ dateFormat: String = "yyyy-MM-dd", locale: String = "ko_KR") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.locale = Locale(identifier: locale)
        return dateFormatter.string(from: self)
    }
    
    func getDatesInCurrentMonth() -> [Date] {
        let calendar = Calendar.current
        let startDate = calendar.date(from: calendar.dateComponents([.year,.month], from: self))!
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        return range.compactMap { day -> Date in
            calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
    
    func getMonth(for offset: Int) -> Date {
        return Calendar.current.date(byAdding: .month, value: offset, to: Date()) ?? Date()
    }
}

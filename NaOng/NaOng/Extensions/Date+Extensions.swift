//
//  Date+Extensions.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/11.
//

import Foundation

extension Date {
    func getFormatDate(_ dateFormat: String = "yyyy-MM-dd") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        return dateFormatter.string(from: self)
    }
}

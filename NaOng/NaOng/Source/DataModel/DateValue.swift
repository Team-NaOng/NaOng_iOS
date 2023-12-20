//
//  DateValue.swift
//  NaOng
//
//  Created by seohyeon park on 12/20/23.
//

import Foundation

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

//
//  View+Extensions.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/30.
//

import SwiftUI

extension View {
    @ViewBuilder func hideView(_ isHide: Bool) -> some View {
        if isHide {
            hidden()
        } else {
            self
        }
    }
}

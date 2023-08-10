//
//  UITextView+Extensions.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/11.
//

import UIKit

extension UITextView {
    @objc func didTapDoneButton() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

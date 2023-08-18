//
//  CustomNavigationBar.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/18.
//

import SwiftUI

struct CustomNavigationBar: ViewModifier {
    init(fontName: String, size: CGFloat) {
        guard let font = UIFont(name: fontName, size: size) else {
           return
        }
        UINavigationBar.appearance().titleTextAttributes = [.font: font]
    }

    func body(content: Content) -> some View {
        content
    }
}

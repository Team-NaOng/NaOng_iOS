//
//  DoneListView.swift
//  NaOng
//
//  Created by seohyeon park on 12/3/23.
//

import SwiftUI

struct DoneListView: View {
    var body: some View {
        List {
            ForEach(0..<40) { _ in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                    ToDoViewFactory.makeToDoTitle(title: "06:31 완료")

                    Spacer()

                    ToDoViewFactory.makeToDoTitle(title: "2023-12-02-토")
                }
            }
        }
        .listRowSpacing(10.0)
        .listStyle(.insetGrouped)
        .frame(width: UIScreen.main.bounds.width)
    }
}

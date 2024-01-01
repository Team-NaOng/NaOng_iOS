//
//  AlertViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 12/3/23.
//

import Combine

class AlertViewModel: ObservableObject {
    @Published var isShowingAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
}


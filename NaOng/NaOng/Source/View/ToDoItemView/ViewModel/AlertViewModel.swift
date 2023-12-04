//
//  AlertViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 12/3/23.
//

import Combine

class AlertViewModel: ObservableObject {
    @Published var showAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
}


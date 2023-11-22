//
//  SettingViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/18.
//

import Combine
import SwiftUI

class SettingViewModel: ObservableObject {
    @Published var authorizationStatus: String = ""
    @Published var isShowingNotificationAlert: Bool = false
    @Published var isShowingEmail: Bool = false
    @Published var isShowingEmailAlert: Bool = false

    private let localNotificationManager: LocalNotificationManager
    private var cancellables: Set<AnyCancellable> = []
    
    init(localNotificationManager: LocalNotificationManager) {
        self.localNotificationManager = localNotificationManager
        localNotificationManager.sendAuthorizationStatusEvent()
        getNotificationStatus()
    }

    func getNotificationStatus() {
        localNotificationManager.authorizationStatusPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                switch status {
                case .authorized:
                    self?.authorizationStatus = "ON"
                default:
                    self?.authorizationStatus = "OFF"
                }
            }
            .store(in: &cancellables)
    }
    
    func showNotificationAlert() {
        isShowingNotificationAlert = true
    }
    
    func showEmailView() {
        isShowingEmail = true
    }

    func showEmailAlert() {
        isShowingEmailAlert = true
    }
    
    func openMailAppStorePage() {
            if let mailAppStoreURL = URL(string: "https://apps.apple.com/us/app/mail/id1108187098"),
               UIApplication.shared.canOpenURL(mailAppStoreURL) {
                UIApplication.shared.open(mailAppStoreURL, options: [:], completionHandler: nil)
            }
        }
}

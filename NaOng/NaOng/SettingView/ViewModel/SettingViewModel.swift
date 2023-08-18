//
//  SettingViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/18.
//

import Foundation
import Combine
import UserNotifications

class SettingViewModel: ObservableObject {
    @Published var authorizationStatus: String = ""
    @Published var isShowingAlert: Bool = false
    
    private let localNotificationManager: LocalNotificationManager
    private var cancellables: Set<AnyCancellable> = []
    
    init(localNotificationManager: LocalNotificationManager) {
        self.localNotificationManager = localNotificationManager
        localNotificationManager.sendAuthorizationStatusEvent()
        getNotificationStatus()
    }

    func getNotificationStatus() {
        localNotificationManager.authorizationStatusPublisher
            .receive(on: DispatchQueue.main)
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
    
    func openSettings() {
        isShowingAlert = true
    }
}

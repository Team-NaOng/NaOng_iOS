//
//  SettingViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/18.
//

import Combine
import SwiftUI
import CoreData

class SettingViewModel: ObservableObject {
    @Published var authorizationStatus: String = ""
    @Published var isShowingNotificationAlert: Bool = false
    @Published var isShowingDeleteAlert: Bool = false
    @Published var isShowingEmail: Bool = false
    @Published var isShowingDeleteDoneAlert: Bool = false
    var alertTitle: String = ""
    var alertMessage: String = ""

    private let viewContext: NSManagedObjectContext
    private let localNotificationManager: LocalNotificationManager
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewContext: NSManagedObjectContext,localNotificationManager: LocalNotificationManager) {
        self.viewContext = viewContext
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
    
    func showDeleteAlert() {
        isShowingDeleteAlert = true
    }
    
    func showEmailView() {
        isShowingEmail = true
    }
    
    func deleteAllToDo() {
        do {
            try ToDo.deleteAll(viewContext: viewContext)
            alertTitle = "할일 삭제 완료"
            alertMessage = "모든 할 일이 삭제되었습니다."
        } catch {
            alertTitle = "할일 삭제 실패🥲"
            alertMessage = error.localizedDescription
        }
        
        isShowingDeleteDoneAlert.toggle()
        localNotificationManager.sendAllRemoveEvent()
    }
}

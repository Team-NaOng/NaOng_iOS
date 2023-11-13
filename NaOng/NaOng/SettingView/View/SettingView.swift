//
//  SettingView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/20.
//

import SwiftUI
import UIKit

struct SettingView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject private var settingViewModel: SettingViewModel
    
    init(settingViewModel: SettingViewModel) {
        self.settingViewModel = settingViewModel
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            
            Text("설정")
                .foregroundColor(.black)
                .font(.custom("Binggrae-Bold", size: 30))
            
            Button {
                settingViewModel.showNotificationAlert()
            } label: {
                HStack {
                    Image(systemName: "bell")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                    Text("알림 설정")
                        .font(.custom("Binggrae", size: 16))
                    
                    Spacer()
                    
                    Text(settingViewModel.authorizationStatus)
                        .font(.custom("Binggrae", size: 16))
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                }
            }
            .foregroundColor(.black)
            .alert("앱의 알림 설정으로 이동합니다.\n이동하는 화면에서 알림을 허용해 주세요.", isPresented: $settingViewModel.isShowingNotificationAlert) {
                Button("취소", role: .cancel) { }
                Button("확인", role: .destructive) {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            }
            
            Button {
                settingViewModel.showEmailView()
            } label: {
                HStack {
                    Image(systemName: "envelope")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                    Text("문의 하기")
                        .font(.custom("Binggrae", size: 16))
                }
                .foregroundColor(.black)
            }
            .sheet(isPresented: $settingViewModel.isShowingEmail) {
                MailView()
                .tint(.accentColor)
            }
            
            Spacer()
        }
        .padding()
    }
}


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
            Button {
                settingViewModel.openSettings()
            } label: {
                HStack {
                    Image(systemName: "bell")
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
            .alert("앱의 알림 설정으로 이동합니다.\n이동하는 화면에서 알림을 허용해 주세요.", isPresented: $settingViewModel.isShowingAlert) {

                Button("취소", role: .cancel) { }
                Button("확인", role: .destructive) {
                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsUrl)
                    }
                }
            }
            
            HStack {
                Image(systemName: "envelope")
                Text("문의 하기")
                    .font(.custom("Binggrae", size: 16))
            }
            
            Spacer()
        }
        .padding()
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.black)
                }
            }
        }
        .navigationTitle("설정")
        .applyCustomNavigationBar()
    }
}


struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        let localNotificationManager = LocalNotificationManager()
        let settingViewModel = SettingViewModel(localNotificationManager: localNotificationManager)
        SettingView(settingViewModel: settingViewModel)
    }
}


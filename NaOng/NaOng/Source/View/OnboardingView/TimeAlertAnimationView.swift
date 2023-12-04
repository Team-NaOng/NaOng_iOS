//
//  TimeAlertAnimationView.swift
//  NaOng
//
//  Created by seohyeon park on 12/4/23.
//

import SwiftUI
import Lottie

struct TimeAlertAnimationView: View {
    var body: some View {
        VStack(spacing:10) {
            ToDoViewFactory.makeToDoTitle(title: "시간 할 일", fontName: "Binggrae-Bold", fontSize: 30)

            ToDoViewFactory.makeToDoTitle(title: "시간 할 일을 생성하면 지정한 시간에\n알림을 받을 수 있습니다.\n반복 설정 시, 매일 지정한 시간에 알림이 전송됩니다.")
                .multilineTextAlignment(.center)
            
            Spacer()
            
            LottieView(animation: .named("TimeAlertAnimation"))
                .playing(loopMode: .loop)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            Spacer()
        }
        .padding(40)
    }
}

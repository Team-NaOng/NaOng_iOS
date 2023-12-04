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

            ToDoViewFactory.makeToDoTitle(title: "시간 할 일을 만들면 지정한 시간에\n알림을 받을 수 있어요.\n 반복을 하면 매일 지정한 시간에 알림이 와요.")
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

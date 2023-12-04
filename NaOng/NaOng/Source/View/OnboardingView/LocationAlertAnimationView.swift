//
//  LocationAlertAnimationView.swift
//  NaOng
//
//  Created by seohyeon park on 12/4/23.
//

import SwiftUI
import Lottie

struct LocationAlertAnimationView: View {
    var body: some View {
            VStack(spacing:10) {
                ToDoViewFactory.makeToDoTitle(title: "위치 할 일", fontName: "Binggrae-Bold", fontSize: 30)

                ToDoViewFactory.makeToDoTitle(title: "위치 할 일을 만들면 지정한 위치에서\n벗어나는 순간 알림을 받을 수 있어요.\n반복을 하면 위치를 벗어날 때마다 알림이 와요.")
                    .multilineTextAlignment(.center)
                
                Spacer()
                
                LottieView(animation: .named("LocationAlertAnimation"))
                    .playing(.fromFrame(220, toFrame: 300, loopMode: .loop))
                    .resizable()
                    .scaledToFit()
                    .frame(width: 300, height: 300)
                
                Spacer()
            }
            .padding(40)
    }
}

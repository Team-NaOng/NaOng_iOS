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

                ToDoViewFactory.makeToDoTitle(title: "위치 할 일을 생성하면 정해진 반경을 벗어나는 즉시 알림을 받을 수 있습니다.\n반복 설정 시, 위치를 벗어날 때마다 알림이 전송됩니다.")
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

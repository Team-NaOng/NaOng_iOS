//
//  FinishAnimationView.swift
//  NaOng
//
//  Created by seohyeon park on 12/4/23.
//

import SwiftUI
import Lottie

struct FinishAnimationView: View {
    @AppStorage("isOnboarding") var isOnboarding: Bool?
    var body: some View {
        VStack(spacing:10) {
            ToDoViewFactory.makeToDoTitle(title: "할 일 등록", fontName: "Binggrae-Bold", fontSize: 30)

            ToDoViewFactory.makeToDoTitle(title: "모든 설명이 끝났어요!\n그럼 이제 할 일을 만들러 가볼까요?")
                .multilineTextAlignment(.center)

            Spacer()

            LottieView(animation: .named("FinishAnimation"))
                .playing(loopMode: .loop)
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            
            Spacer()
            
            Button(action: {
                isOnboarding = false
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color("secondary"))
                        .frame(width: 300, height: 60)
                    
                    ToDoViewFactory.makeToDoTitle(title: "확인", fontColor: .blue)
                }
            })
        }
        .padding(40)
    }
}

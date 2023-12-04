//
//  SwipeAnimationView.swift
//  NaOng
//
//  Created by seohyeon park on 12/4/23.
//

import SwiftUI
import Lottie

struct SwipeAnimationView: View {
    var body: some View {
        VStack(spacing:10) {
            ToDoViewFactory.makeToDoTitle(title: "할 일 삭제", fontName: "Binggrae-Bold", fontSize: 30)

            ToDoViewFactory.makeToDoTitle(title: "할 일을 왼쪽으로 밀면 삭제할 수 있습니다.")
                .multilineTextAlignment(.center)
            
            Spacer()
            
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color("secondary"))
                    .frame(width: 300, height: 100)
                
                VStack {
                    Spacer()
                    
                    LottieView(animation: .named("SwipeAnimation"))
                        .playing(loopMode: .loop)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .frame(width: 300, height: 100)
                }
                .frame(width: 300, height: 160)
            }
            
            Spacer()
        }
        .padding(40)
    }
}

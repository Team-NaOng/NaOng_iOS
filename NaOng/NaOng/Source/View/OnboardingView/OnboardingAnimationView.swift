//
//  OnboardingAnimationView.swift
//  NaOng
//
//  Created by seohyeon park on 12/3/23.
//

import SwiftUI
import Lottie

struct OnboardingAnimationView: View {
    var body: some View {
        TabView {
            LocationAlertAnimationView()
            TimeAlertAnimationView()
            SwipeAnimationView()
            FinishAnimationView()
        }
        .tabViewStyle(PageTabViewStyle())
        .padding(.vertical, 20)
        .background(Color("onboardingColor"))
    }
}

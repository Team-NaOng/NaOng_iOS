//
//  SettingView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/07/20.
//

import SwiftUI

struct SettingView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 30) {
                NavigationLink {
                    NotificationSettingView()
                } label: {
                    HStack {
                        Image(systemName: "bell")
                        Text("알림 설정")
                            .font(.custom("Binggrae", size: 16))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.plain)


                NavigationLink {
                    LocationSettingView()
                } label: {
                    HStack {
                        Image(systemName: "map")
                        Text("위치 설정")
                            .font(.custom("Binggrae", size: 16))
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                }
                .buttonStyle(.plain)
                
                HStack {
                    Image(systemName: "envelope")
                    Text("문의 하기")
                        .font(.custom("Binggrae", size: 16))
                }
            }
            .padding()
            .navigationTitle("설정")
        }
    }
}


struct LocationSettingView: View {
    var body: some View {
        Text("위치 설정")
    }
}

struct SettingView_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
    }
}

struct SpecialNavBar: ViewModifier {

    init() {
        UINavigationBar.appearance().largeTitleTextAttributes = [.font: UIFont(name: "Binggrae", size: 30)!]
    }

    func body(content: Content) -> some View {
        content
    }

}

extension View {

    func specialNavBar() -> some View {
        self.modifier(SpecialNavBar())
    }

}

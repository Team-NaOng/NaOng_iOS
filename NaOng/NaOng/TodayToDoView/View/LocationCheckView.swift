//
//  LocationCheckView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import SwiftUI

struct LocationCheckView: View {
    @Binding var path: [LocationViewStack]

    @State var draw: Bool = false
    var body: some View {
        VStack {
            KakaoMapView(draw: $draw).onAppear(perform: {
                self.draw = true
            }).onDisappear(perform: {
                self.draw = false
            }).frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(alignment: .leading) {
                Text("주소")
                    .font(.custom("Binggrae-Bold", size: 20))
                    .padding()

                Button {
                    path.removeAll()
                } label: {
                    Text("이 위치로 설정")
                        .font(.custom("Binggrae", size: 15))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("primary"))
                        .cornerRadius(5)
                        .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 150)
            .background(Color("secondary"))
        }
    }
}

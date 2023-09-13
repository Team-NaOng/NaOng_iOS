//
//  LocationCheckView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import SwiftUI

struct LocationCheckView: View {
    @State var draw: Bool = false
    var body: some View {
        KakaoMapView(draw: $draw).onAppear(perform: {
            self.draw = true
        }).onDisappear(perform: {
            self.draw = false
        }).frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}

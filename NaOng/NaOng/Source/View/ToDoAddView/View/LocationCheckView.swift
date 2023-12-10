//
//  LocationCheckView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import SwiftUI

struct LocationCheckView: View {
    @ObservedObject private var locationCheckViewModel: LocationCheckViewModel
    
    @Binding var path: [LocationViewStack]
    @Binding var locationInformation: LocationInformation

    init(locationCheckViewModel: LocationCheckViewModel, path: Binding<[LocationViewStack]>, locationInformation: Binding<LocationInformation>) {
        self.locationCheckViewModel = locationCheckViewModel
        _path = path
        _locationInformation = locationInformation
    }

    var body: some View {
        VStack {
            KakaoMapView()
            
            VStack(alignment: .leading) {
                Text(locationCheckViewModel.currentLocationInformation.locationName)
                    .font(.custom("Binggrae-Bold", size: 20))
                    .padding()

                Button {
                    path.removeAll()
                    locationInformation = locationCheckViewModel.currentLocationInformation
                } label: {
                    Text("이 위치로 설정")
                        .font(.custom("Binggrae", size: 15))
                        .foregroundStyle(.black)
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

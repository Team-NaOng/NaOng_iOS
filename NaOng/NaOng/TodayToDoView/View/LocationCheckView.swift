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
    @Binding var location: String
    @Binding var coordinates: Coordinates
    
    init(locationCheckViewModel: LocationCheckViewModel, path: Binding<[LocationViewStack]>, location: Binding<String>, coordinates: Binding<Coordinates>) {
        self.locationCheckViewModel = locationCheckViewModel
        _path = path
        _location = location
        _coordinates = coordinates
    }

    var body: some View {
        VStack {
            KakaoMapView(draw: $locationCheckViewModel.draw).onAppear(perform: {
                locationCheckViewModel.draw = true
            }).onDisappear(perform: {
                locationCheckViewModel.draw = false
            }).frame(maxWidth: .infinity, maxHeight: .infinity)
            
            VStack(alignment: .leading) {
                Text(locationCheckViewModel.currentLocation)
                    .font(.custom("Binggrae-Bold", size: 20))
                    .padding()

                Button {
                    path.removeAll()
                    location = locationCheckViewModel.currentLocation
                    coordinates = locationCheckViewModel.currentCoordinate
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

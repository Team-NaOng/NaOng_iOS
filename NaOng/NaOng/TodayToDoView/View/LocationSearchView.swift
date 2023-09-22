//
//  LocationSearchView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/04.
//

import SwiftUI

struct LocationSearchView: View {
    @ObservedObject private var locationSearchViewModel: LocationSearchViewModel

    @Binding var path: [LocationViewStack]
    @Binding var locationInformation: LocationInformation
    
    init(locationSearchViewModel: LocationSearchViewModel, path: Binding<[LocationViewStack]>, locationInformation: Binding<LocationInformation>) {
        self.locationSearchViewModel = locationSearchViewModel
        _path = path
        _locationInformation = locationInformation
    }
    
    var body: some View {
        VStack {
            ToDoViewFactory.makeToDoMoldView(
                content: ToDoViewFactory.makeToDoTextField(
                    title: "지번, 도로명, 건물명으로 검색",
                    text: $locationSearchViewModel.keyword),
                lineWidth: 2,
                width: UIScreen.main.bounds.width - 20,
                height: 40
            )
            .onSubmit {
                locationSearchViewModel.searchLocation()
            }

            if locationSearchViewModel.locationInformations.count > 0 {
                List(0..<locationSearchViewModel.locationInformations.count, id: \.self) { index in
                    VStack(alignment: .leading) {
                        Text(locationSearchViewModel.locationInformations[index].locationName)
                            .bold()
                        Text(locationSearchViewModel.locationInformations[index].locationAddress)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .onAppear {
                        if index == (locationSearchViewModel.locationInformations.count - 1) {
                            locationSearchViewModel.scroll()
                        }
                    }
                    .onTapGesture {
                        path.removeAll()
                        locationInformation = locationSearchViewModel.locationInformations[index]
                    }
                }
            } else {
                Text(locationSearchViewModel.announcement)
                Spacer()
            }
        }
    }
}

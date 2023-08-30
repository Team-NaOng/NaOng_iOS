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
    @Binding var location: String
    
    init(locationSearchViewModel: LocationSearchViewModel, path: Binding<[LocationViewStack]>, location: Binding<String>) {
        self.locationSearchViewModel = locationSearchViewModel
        _path = path
        _location = location
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
                print(locationSearchViewModel.roadNameAddress.count)
            }
            
            List(0..<locationSearchViewModel.roadNameAddress.count, id: \.self) { index in
                Text(locationSearchViewModel.roadNameAddress[index].roadAddrPart1)
                    .padding()
                    .onAppear {
                        if index == (locationSearchViewModel.roadNameAddress.count - 1) {
                            locationSearchViewModel.scroll()
                        }
                    }
                    .onTapGesture {
                        path.removeAll()
                        location = locationSearchViewModel.roadNameAddress[index].roadAddrPart1
                    }
            }
        }
    }
}

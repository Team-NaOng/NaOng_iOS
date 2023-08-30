//
//  LocationSelectionView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/02.
//

import SwiftUI

struct LocationSelectionView: View {
    @ObservedObject private var locationSelectionViewModel: LocationSelectionViewModel
    @Binding var path: [LocationViewStack]
    
    init(locationSelectionViewModel: LocationSelectionViewModel, path: Binding<[LocationViewStack]>) {
        self.locationSelectionViewModel = locationSelectionViewModel
        _path = path
    }
    
    var body: some View {
        VStack {
            Button {
                path.append(.second)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(Color("secondary"))
                    
                    HStack {
                        Image(systemName: "magnifyingglass")
                        
                        Text("지번, 도로명, 건물명으로 검색")
                    }
                }
                .frame(height: 40)
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            
            Button {
                path.append(.third)
            } label: {
                HStack {
                    Image(systemName: "paperplane.circle")
                    
                    Text("현재 위치로 설정")
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                }
                .frame(height: 40)
            }
            .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            
            List {
                ForEach(locationSelectionViewModel.locations) { location in
                    HStack {
                        Image("mapIcon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 20, height: 20)
                        Text(location.address ?? "")
                        
                        Spacer()
                        
                        Image(systemName: "checkmark")
                    }
                }
                .onDelete { indexSet in
                    withAnimation {
                        locationSelectionViewModel.deleteItems(offsets: indexSet)
                    }
                }
            }
            .listStyle(.grouped)
        }
        .navigationTitle("주소 설정")
        .navigationBarItems(trailing: EditButton())
        .foregroundColor(.black)
    }
}

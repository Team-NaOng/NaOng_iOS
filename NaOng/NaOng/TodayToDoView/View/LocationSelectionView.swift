//
//  LocationSelectionView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/02.
//

import SwiftUI

struct LocationSelectionView: View {
    @ObservedObject private var locationSelectionViewModel: LocationSelectionViewModel
    
    init(locationSelectionViewModel: LocationSelectionViewModel) {
        self.locationSelectionViewModel = locationSelectionViewModel
    }
    
    var body: some View {
        VStack {
            NavigationLink {
                let locationSearchViewModel = LocationSearchViewModel()
                LocationSearchView(locationSearchViewModel: locationSearchViewModel)
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
            
            NavigationLink {
                LocationCheckView()
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

struct LocationSelectionView_Previews: PreviewProvider {
    static var previews: some View {
        let viewContext = Location.viewContext
        let locationSelectionViewModel = LocationSelectionViewModel(viewContext: viewContext)
        LocationSelectionView(locationSelectionViewModel: locationSelectionViewModel)
    }
}

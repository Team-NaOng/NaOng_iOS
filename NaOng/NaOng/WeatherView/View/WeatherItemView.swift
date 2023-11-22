//
//  WeatherItemView.swift
//  NaOng
//
//  Created by seohyeon park on 11/23/23.
//

import SwiftUI
import PhotosUI

struct WeatherItemView: View {
    let imageState: ImageState
    let profileName: String
    
    init(imageState: ImageState, profileName: String) {
        self.imageState = imageState
        self.profileName = profileName
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 5) {
            WeatherProfileImageView(imageState: imageState)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(profileName)
                    .font(.custom("Binggrae", size: 15))
                
                HStack(alignment:.bottom) {
                    Text("날씨")
                        .font(.custom("Binggrae", size: 15))
                        .padding()
                        .background(Color("primary"))
                        .clipShape(
                            .rect(
                                topLeadingRadius: 0,
                                bottomLeadingRadius: 15,
                                bottomTrailingRadius: 15,
                                topTrailingRadius: 15
                            )
                        )
                    
                    Text(Date().getFormatDate("a hh:mm"))
                        .font(.custom("Binggrae", size: 10))
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

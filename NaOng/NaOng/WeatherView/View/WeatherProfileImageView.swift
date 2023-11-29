//
//  WeatherProfileImageView.swift
//  NaOng
//
//  Created by seohyeon park on 11/23/23.
//

import SwiftUI

struct WeatherProfileImageView: View {
    let imageState: ImageState
    
    var body: some View {
        switch imageState {
        case .success(let image):
            image
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(.circle)
        case .failure:
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
        case .loading:
            ProgressView()
        case .loaded:
            if let data = UserDefaults.standard.data(forKey: "weatherViewProfileImage"),
               let image = UIImage(data: data) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(.circle)
            } else {
                Image("profile", bundle: .main)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(.circle)
            }
        }
    }
}

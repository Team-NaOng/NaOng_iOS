//
//  WeatherViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 11/23/23.
//

import SwiftUI
import PhotosUI
import CoreTransferable

enum ImageState {
    case success(Image)
    case failure(Error)
    case loading(Progress)
    case loaded
}

enum TransferError: Error {
    case importFailed
}

class WeatherViewModel: ObservableObject {
    @Published private(set) var imageState: ImageState
    @Published var profileName = UserDefaults.standard.string(forKey: "weatherViewProfileName") ?? "나옹"
    @Published var isShowingPhotosPicker = false
    @Published var isShowingProfileNameEditAlert = false
    @Published var imageSelection: PhotosPickerItem? = nil {
        didSet {
            if let imageSelection {
                let progress = loadTransferable(from: imageSelection)
                imageState = .loading(progress)
            } else {
                imageState = .loaded
            }
        }
    }
    
    init(imageState: ImageState) {
        self.imageState = imageState
    }
    
    func showPhotosPicker() {
        isShowingPhotosPicker.toggle()
    }
    
    func showProfileNameEditAlert() {
        isShowingProfileNameEditAlert.toggle()
    }
    
    func submit() {
        let name = profileName.trimmingCharacters(in: .whitespaces)
        UserDefaults.standard.setValue(name, forKey: "weatherViewProfileName")
    }
    
    func verifyProfileName() -> Bool {
        if profileName.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        
        return false
    }
    
    func setupBasicProfileImage() {
        UserDefaults.standard.removeObject(forKey: "weatherViewProfileImage")
        imageState = .loaded
    }
    
    private func loadTransferable(from imageSelection: PhotosPickerItem) -> Progress {
        return imageSelection.loadTransferable(type: ProfileImage.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.imageSelection else {
                    print("Failed to get the selected item.")
                    return
                }
                switch result {
                case .success(let profileImage?):
                    self.imageState = .success(profileImage.image)
                case .success(nil):
                    self.imageState = .loaded
                case .failure(let error):
                    self.imageState = .failure(error)
                }
            }
        }
    }
    
    struct ProfileImage: Transferable {
        let image: Image
        
        static var transferRepresentation: some TransferRepresentation {
            DataRepresentation(importedContentType: .image) { data in
                guard let uiImage = UIImage(data: data) else {
                    throw TransferError.importFailed
                }
                UserDefaults.standard.setValue(data, forKey: "weatherViewProfileImage")
                let image = Image(uiImage: uiImage)
                return ProfileImage(image: image)
            }
        }
    }
}

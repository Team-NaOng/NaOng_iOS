//
//  WeatherViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 11/23/23.
//

import SwiftUI
import PhotosUI
import CoreTransferable
import Combine

enum ImageState {
    case success(Image)
    case failure(Error)
    case loading(Progress)
    case loaded
}

enum TransferError: Error {
    case importFailed
}

class WeatherViewModel: ObservableObject, GeoDataService {
    // MARK: 프로필 이미지 관련 프로퍼티
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
    
    // MARK: 데이터 관련 프로퍼티
    @Published var currentLocation: String?
    @Published var currentDustyInformation: Item?
    @Published var currentWeatherInformation: OpenWeather?
    private var cancellables: Set<AnyCancellable> = []
    
    // MARK: init
    init(imageState: ImageState) {
        self.imageState = imageState
    }
    
    // MARK: 프로필 관련 메서드
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
    
    // MARK: 데이터 관련 메서드
    func setUpCurrentLocation() {
        let coordinate = LocationService.shared.getLocation()
        guard let urlRequest = getKakaoLocalGeoURLRequest(coordinate: coordinate) else {
            return
        }

        NetworkManager.fetchData(from: urlRequest, responseType: KakaoLocal.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] kakaoLocal in
                self?.currentLocation = kakaoLocal.documents.first?.address?.region2DepthName
                let stationName = kakaoLocal.documents.first?.address?.region3DepthName
                
                self?.setUpCurrentDustyInformation(stationName: stationName)
            })
            .store(in: &cancellables)
    }
    
    private func setUpCurrentDustyInformation(stationName: String?) {
        guard let stationName = stationName,
        let urlRequest = getDustMeasurementRequest(stationName: stationName) else {
            return
        }
        
        NetworkManager.fetchData(from: urlRequest, responseType: AirKorea.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] airKorea in
                self?.currentDustyInformation = airKorea.response.body.items?.first
            })
            .store(in: &cancellables)
    }
    
    private func getDustMeasurementRequest(stationName: String) -> URLRequest? {
        guard let serviceKey = Bundle.main.publicDataPortalKey else {
            return nil
        }
        return URLRequestBuilder()
            .setHost("apis.data.go.kr")
            .setPath("/B552584/ArpltnInforInqireSvc/getMsrstnAcctoRltmMesureDnsty")
            .addQueryItem(name: "serviceKey", value: serviceKey)
            .addQueryItem(name: "returnType", value: "json")
            .addQueryItem(name: "numOfRows", value: "100")
            .addQueryItem(name: "pageNo", value: "1")
            .addQueryItem(name: "stationName", value: stationName)
            .addQueryItem(name: "dataTerm", value: "DAILY")
            .addQueryItem(name: "ver", value: "1.3")
            .build()
    }
    
    func setUpWeather() {
        let coordinate = LocationService.shared.getLocation()
        guard let urlRequest = getWeatherRequest(coordinate: coordinate) else {
            return
        }

        NetworkManager.fetchData(from: urlRequest, responseType: OpenWeather.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] openWeather in
                self?.currentWeatherInformation = openWeather
            })
            .store(in: &cancellables)
    }
    
    private func getWeatherRequest(coordinate: Coordinates) -> URLRequest? {
        guard let apiId = Bundle.main.openWeatherKey else {
            return nil
        }
        return URLRequestBuilder()
            .setHost("api.openweathermap.org")
            .setPath("/data/2.5/weather")
            .addQueryItem(name: "lat", value: "\(coordinate.lat)")
            .addQueryItem(name: "lon", value: "\(coordinate.lon)")
            .addQueryItem(name: "appid", value: apiId)
            .addQueryItem(name: "mode", value: "json")
            .addQueryItem(name: "units", value: "metric")
            .build()
    }
}

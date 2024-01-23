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
import os.log

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
    @Published var profileName: String = UserDefaults.standard.string(forKey: UserDefaultsKey.weatherViewProfileName) ?? "나옹"
    @Published var isShowingPhotosPicker: Bool = false
    @Published var isShowingProfileNameEditAlert: Bool = false
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
    @Published var isLoading: Bool = true
    var contents: [String] = [String]()
    var currentLocation: String?
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
        UserDefaults.standard.setValue(name, forKey: UserDefaultsKey.weatherViewProfileName)
    }
    
    func verifyProfileName() -> Bool {
        if profileName.trimmingCharacters(in: .whitespaces).isEmpty {
            return true
        }
        
        return false
    }
    
    func setupBasicProfileImage() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKey.weatherViewProfileImage)
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
                UserDefaults.standard.setValue(data, forKey: UserDefaultsKey.weatherViewProfileImage)
                let image = Image(uiImage: uiImage)
                return ProfileImage(image: image)
            }
        }
    }
    
    // MARK: -
    // MARK: 데이터 관련 메서드
    @MainActor
    func setUpMessage() async {
        let coordinate = LocationService.shared.getValidCoordinate()
        let weatherServiceManager = getWeatherServiceManager(coordinate)
        
        async let weatherMessages = getWeatherMessages(weatherServiceManager: weatherServiceManager)
        async let kakaoDistrict = getKakaoLocalDistrict(for: coordinate)
        
        let dustMessages = await getDustMessages(for: kakaoDistrict)
        let combinedMessages = await combineMessages(weather: weatherMessages, dust: dustMessages)
        
        if !combinedMessages.isEmpty {
            contents += combinedMessages
        }

        setCurrentLocation(await kakaoDistrict)
        isLoading = false
    }
    
    private func getWeatherServiceManager(_ coordinate: Coordinates ) -> WeatherServiceManager {
        let location = CLLocation(latitude: coordinate.lat, longitude: coordinate.lon)
        return WeatherServiceManager(location: location)
    }

    private func getWeatherMessages(weatherServiceManager: WeatherServiceManager) async -> [String]? {
        if let todayWeatherInfo = await weatherServiceManager.getWeather() {
            return generateCurrentWeatherMessages(from: todayWeatherInfo, weatherServiceManager: weatherServiceManager) +
                   generateWeatherAdviceMessages(from: todayWeatherInfo, weatherServiceManager: weatherServiceManager)
        }
        return nil
    }
    
    private func generateCurrentWeatherMessages(from todayWeatherInfo: WeatherServiceManager.TodayWeatherInfo, weatherServiceManager: WeatherServiceManager) -> [String] {
        var messages: [String] = []

        if let conditionMessage = weatherServiceManager.generateCurrentWeatherMessage(for: todayWeatherInfo.condition) {
            messages.append(conditionMessage)
        }

        if let temperatureMessage = weatherServiceManager.generateCurrentTemperatureMessage(currentTemperature: todayWeatherInfo.currentTemperature) {
            messages.append(temperatureMessage)
        }

        if let summaryTemperatureMessage = weatherServiceManager.generateSummaryTemperatureMessage(highTemperature: todayWeatherInfo.highTemperature, lowTemperature: todayWeatherInfo.lowTemperature) {
            messages.append(summaryTemperatureMessage)
        }
        
        if let hourlyForecastsMessage = weatherServiceManager.generateHourlyForecastMessage(hourlyForecasts: todayWeatherInfo.hourlyForecasts) {
            messages.append(hourlyForecastsMessage)
        }

        if let sunrise = todayWeatherInfo.sunrise,
           let sunset = todayWeatherInfo.sunset,
           let sunriseSunsetMessage = weatherServiceManager.generateSunriseSunsetMessage(sunrise: sunrise.getFormatDate("HH:mm"), sunset: sunset.getFormatDate("HH:mm")) {
            messages.append(sunriseSunsetMessage)
        }

        return messages
    }
    
    private func generateWeatherAdviceMessages(from todayWeatherInfo: WeatherServiceManager.TodayWeatherInfo, weatherServiceManager: WeatherServiceManager) -> [String] {
        var messages = [String]()

        if let uvMessage = weatherServiceManager.generateUVMessage(uv: todayWeatherInfo.uv) {
            messages.append(uvMessage)
        }
        
        if let weatherMessage = weatherServiceManager.generateWeatherAdviceMessage(for: todayWeatherInfo.condition) {
            messages.append(weatherMessage)
        }

        return messages
    }

    private func getDustMessages(for kakaoLocalDistrict: KakaoLocalDistrict?) async -> [String]? {
        guard let kakaoLocalDistrict = kakaoLocalDistrict else {
            return nil
        }
        
        do {
            let dustServiceManager = DustServiceManager()
            let dustData = try await dustServiceManager.getDustData(kakaoLocalDistrict)
            let cityName = kakaoLocalDistrict.documents.first?.region2DepthName.components(separatedBy: " ").first
            let item = dustServiceManager.getDustItem(items: dustData.response?.body?.items, cityName: cityName)
            return dustServiceManager.generateCurrentDustMessage(item: item)
        } catch {
            print(error)
            return nil
        }
    }

    private func getKakaoLocalDistrict(for coordinate: Coordinates) async -> KakaoLocalDistrict? {
        guard let urlRequest = getKakaoLocalGeoURLRequest(coordinate: coordinate) else {
            return nil
        }
        
        return try? await getKakaoLocal(urlRequest)
    }
    
    private func getKakaoLocal(_ urlRequest: URLRequest) async throws -> KakaoLocalDistrict {
        do {
            let data = try await NetworkManager.performRequest(urlRequest: urlRequest)
            return try NetworkManager.performDecoding(data, responseType: KakaoLocalDistrict.self)
        } catch {
            throw error
        }
    }
    
    private func combineMessages(weather: [String]?, dust: [String]?) async -> [String] {
        return [weather, dust].compactMap { $0 }.flatMap { $0 }
    }

    private func setCurrentLocation(_ kakaoDistrict: KakaoLocalDistrict?) {
        guard let document = kakaoDistrict?.documents.first else {
            return
        }

        currentLocation = document.region2DepthName.isEmpty ? document.addressName : document.region2DepthName
    }
}

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
    func setUpMessage() async {
        let coordinate = getValidCoordinate()
        let weatherServiceManager = getWeatherServiceManager(coordinate)
        
        if let todayWeatherInfo = await weatherServiceManager.getWeather() {
            contents = generateCurrentWeatherMessages(from: todayWeatherInfo, weatherServiceManager: weatherServiceManager)
            contents += generateWeatherAdviceMessages(from: todayWeatherInfo, weatherServiceManager: weatherServiceManager)
        }
        
        guard let urlRequest = getKakaoLocalGeoURLRequest(coordinate: coordinate) else {
            return
        }

        fetchDustData(dustPublisher: getDustPublisherWithCurrentLocation(urlRequest))
    }
    
    private func getValidCoordinate() -> Coordinates {
        var coordinate = LocationService.shared.getLocation()
        if isCoordinateInKorea(coordinate) == false {
            coordinate = Coordinates(lat: 37.49806749166401, lon: 127.02801316172545)
        }
        
        return coordinate
    }
    
    private func isCoordinateInKorea(_ coordinate: Coordinates) -> Bool {
        return (33...39).contains(coordinate.lat) && (125...132).contains(coordinate.lon)
    }
    
    private func getWeatherServiceManager(_ coordinate: Coordinates ) -> WeatherServiceManager {
        let location = CLLocation(latitude: coordinate.lat, longitude: coordinate.lon)
        return WeatherServiceManager(location: location)
    }

    private func getDustPublisherWithCurrentLocation(_ urlRequest: URLRequest) -> AnyPublisher<AirKorea, Error> {
        return NetworkManager.fetchData(from: urlRequest, responseType: KakaoLocal.self)
            .tryMap { [weak self] kakaoLocal in
                guard let self = self else {
                    throw NetworkError.invalidResponse
                }

                var stationName: String?
                if kakaoLocal.documents.first?.address?.region1DepthName == "서울" {
                    self.currentLocation = kakaoLocal.documents.first?.address?.region3DepthName
                    stationName = kakaoLocal.documents.first?.address?.region2DepthName
                } else {
                    self.currentLocation = kakaoLocal.documents.first?.address?.region2DepthName
                    stationName = kakaoLocal.documents.first?.address?.region3DepthName
                }

                return stationName
            }
            .flatMap { [weak self] stationName in
                if let stationName = stationName,
                   let urlRequest = self?.getDustMeasurementRequest(stationName: stationName) {
                    return NetworkManager.fetchData(from: urlRequest, responseType: AirKorea.self)
                }

                return Empty(completeImmediately: true).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
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
    
    private func setupWeatherInfoMessage(todayWetherInfo: WeatherServiceManager.TodayWeatherInfo) {
        
    }
    
    private func fetchDustData(dustPublisher: AnyPublisher<AirKorea, Error>?) {
        guard let dustPublisher = dustPublisher else {
            return
        }
        
        dustPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .finished:
                    break
                case .failure(let failure):
                    self?.isLoading = false
                    let osLog = OSLog(subsystem: "Seohyeon.NaOng", category: "Weather")
                    let log = Logger(osLog)
                    log.log(level: .error, "미세먼지와 날씨를 가져올 수 없습니다. Error Message: \(failure)")
                }
            }, receiveValue: { [weak self] dustResponse in
                if let items = dustResponse.response?.body?.items,
                   let message = self?.generateCurrentDustMessage(item: items.first).joined(separator: "\n") {
                    self?.contents.append(message)
                }
                self?.isLoading = false
            })
            .store(in: &cancellables)
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
    
    private func generateCurrentDustMessage(item: Item?) -> [String] {
        guard let item = item else {
            return [String]()
        }

        let fineDust = getDustGradeIcon(grade: item.pm10Grade1h ?? "1")
        let ultraFineDust = getDustGradeIcon(grade: item.pm25Grade1h ?? "1")
        let message = "\(fineDust[1]) 미세먼지: \(fineDust[0])\n\(ultraFineDust[1]) 초미세먼지: \(ultraFineDust[0])"
        return [message]
    }
    
    private func getDustGradeIcon(grade: String) -> [String] {
        switch grade {
        case "1":
            return ["좋음", "😍"]
        case "2":
            return ["보통","🙂"]
        case "3":
            return ["나쁨","😡"]
        default:
            return ["매우나쁨","🤬"]
        }
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
}

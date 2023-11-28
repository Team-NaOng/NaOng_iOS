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
    @Published var contents: [String] = [String]()
    var currentLocation: String?
//    var currentDustyInformation: Item?
//    var currentWeatherInformation: OpenWeather?
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
    
    // MARK: -
    // MARK: 데이터 관련 메서드
    func setUpCurrentLocation() {
        // let coordinate = LocationService.shared.getLocation()
        let coordinate = Coordinates(lat: 37.3914266, lon: 126.9534928)
        guard let urlRequest = getKakaoLocalGeoURLRequest(coordinate: coordinate) else {
            return
        }

        NetworkManager.fetchData(from: urlRequest, responseType: KakaoLocal.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let failure):
                    print(failure)
                }
            }, receiveValue: { [weak self] kakaoLocal in
                self?.currentLocation = kakaoLocal.documents.first?.address?.region2DepthName
                let stationName = kakaoLocal.documents.first?.address?.region3DepthName
                
                let dustPublisher = self?.getDustPublisher(stationName: stationName)
                let weatherPublisher = self?.getWeatherPublisher(coordinate: coordinate)
                self?.executeAsyncOperations(dustPublisher: dustPublisher, weatherPublisher: weatherPublisher)
            })
            .store(in: &cancellables)
    }
    
    private func getDustPublisher(stationName: String?) -> AnyPublisher<AirKorea, Error>? {
        guard let stationName = stationName,
        let urlRequest = getDustMeasurementRequest(stationName: stationName) else {
            return nil
        }
    
        return NetworkManager.fetchData(from: urlRequest, responseType: AirKorea.self)
    }
    
    private func getWeatherPublisher(coordinate: Coordinates) -> AnyPublisher<OpenWeather, Error>? {
        guard let urlRequest = getWeatherRequest(coordinate: coordinate) else {
            return nil
        }
    
        return NetworkManager.fetchData(from: urlRequest, responseType: OpenWeather.self)
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
    
    private func executeAsyncOperations(dustPublisher: AnyPublisher<AirKorea, Error>?, weatherPublisher: AnyPublisher<OpenWeather, Error>?) {
            guard let dustPublisher = dustPublisher,
            let weatherPublisher = weatherPublisher else {
                return
            }
            
            Publishers.Zip(dustPublisher, weatherPublisher)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { result in
                    switch result {
                    case .finished:
                        break
                    case .failure(let failure):
                        print(failure)
                    }
                }, receiveValue: { [weak self] dustResponse, weatherResponse in
                    let currentTemperatureMessage = self?.addCurrentTemperatureMessage(currentWeatherInformation: weatherResponse)
                    let currentDustMessage = self?.addCurrentDustMessage(item: dustResponse.response?.body?.items?.first)
                    let adviceMessage = self?.addAdviceMessage(
                        weatherState: weatherResponse.weather?.first?.main,
                        item: dustResponse.response?.body?.items?.first)

                    self?.contents = (currentTemperatureMessage ?? [String]()) + (currentDustMessage ?? [String]()) + (adviceMessage ?? [String]())
                })
                .store(in: &cancellables)
        }
    
    private func addCurrentTemperatureMessage(currentWeatherInformation: OpenWeather?) -> [String] {
        var messages = [String]()
        var message: String = "현재 날씨: "
        switch currentWeatherInformation?.weather?.first?.id {
        case 200,201,202,230,231,232:
            message += "⛈️ 비와 천둥번개"
            break
        case 210,211,212,221:
            message += "🌩️ 뇌우"
            break
        case 300,301,302,310,311,312,313,314,321,500,501,502,503,504,511,520,521,522,531:
            message += "🌧️ 비옴"
            break
        case 600,601,602,611,612,613,615,616,620,621,622:
            message += "❄️ 눈옴"
            break
        case 800:
            message += "☀️ 맑음"
            break
        case 801:
            message += "🌤️ 대체로 맑음"
            break
        case 802:
            message += "⛅️ 대체로 흐림"
            break
        case 803:
            message += "🌥️ 구름 많음"
            break
        case 804:
            message += "☁️ 흐림"
            break
        case 731, 751, 761, 762:
            message += "🌪️ 모래먼지"
            break
        case 771:
            message += "🌪️ 돌풍"
            break
        default:
            message += "🌪️ 안개"
            break
        }

        let currentTemperature = Int(round(currentWeatherInformation?.main?.temp ?? 0))
        message += " \(currentTemperature)℃"
        messages.append(message)

        let maximumTemperature = Int(round(currentWeatherInformation?.main?.tempMax ?? 0))
        let minimumTemperature = Int(round(currentWeatherInformation?.main?.tempMin ?? 0))
        message = "최고 온도: \(maximumTemperature)℃\n최저 온도: \(minimumTemperature)℃"
        messages.append(message)
        
        let sunrise = convertUnixTimeToCurrentTime(unixTime: TimeInterval(currentWeatherInformation?.sys?.sunrise ?? 0))
        let sunset = convertUnixTimeToCurrentTime(unixTime: TimeInterval(currentWeatherInformation?.sys?.sunset ?? 0))
        message = "☀️ 일출 시간: \(sunrise)\n🌙 일몰 시간: \(sunset)"
        messages.append(message)
        
        return messages
    }
    
    private func convertUnixTimeToCurrentTime(unixTime: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let formattedDate = dateFormatter.string(from: date)
        return formattedDate
    }
    
    private func addCurrentDustMessage(item: Item?) -> [String] {
        guard let item = item else {
            return [String]()
        }

        let fineDust = getIcon(grade: item.pm10Grade1h ?? "1")
        let ultraFineDust = getIcon(grade: item.pm25Grade1h ?? "1")
        let message = "\(fineDust[1]) 미세먼지: \(fineDust[0])\n\(ultraFineDust[1]) 초미세먼지: \(ultraFineDust[0])"
        return [message]
    }
    
    private func getIcon(grade: String) -> [String] {
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
    
    private func addAdviceMessage(weatherState: String?,item: Item?) -> [String] {
        var messages = [String]()
        guard let weatherState = weatherState,
              let item = item else {
            return [String]()
        }
        
        switch weatherState {
        case "Thunderstorm":
            messages.append("천둥번개가 칠 때는 되도록 실내로 이동하세요.")
            break
        case "Drizzle", "Rain":
            messages.append("나가기 전에 우산 챙겼나요?")
            break
        case "Snow":
            messages.append("눈이 오면 도로가 미끄러울 수 있으니 주의하세요.")
            break
        case "Clear":
            messages.append("당신의 미소처럼 맑은 하늘을 보며 한숨 돌리는 건 어떠세요?")
            break
        case "Clouds":
            messages.append("오늘 하늘을 보면 행운의 구름을 찾을 수 있을지도 몰라요!")
            break
        default:
            break
        }

        let fineDustGrade = Int(item.pm10Grade1h ?? "1") ?? 1
        let ultraFineDustGrade = Int(item.pm25Grade1h ?? "1") ?? 1
        if (fineDustGrade > 2) || (ultraFineDustGrade > 2) {
            messages.append("나가기 전에 마스크 챙겼나요? 😷")
        }
        
        return messages
    }
}

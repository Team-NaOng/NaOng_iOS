//
//  LocationCheckViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/09/15.
//

import Foundation
import KakaoMapsSDK

@MainActor
class LocationCheckViewModel: NSObject, ObservableObject {
    @Published var draw: Bool = true
    @Published var currentLocation: String = ""
    @Published var currentCoordinate: Coordinates = Coordinates(lat: 0.0, lon: 0.0)

    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMapPoint(_:)),
            name: Notification.Name("MapPointNotification"),
            object: nil)

        setCurrentLocation(coordinate: LocationService.shared.getLocation())
    }
    
    @objc func handleMapPoint(_ notification: Notification) {
        if let position = notification.object as? MapPoint {
            let coordinate = Coordinates(
                lat: position.wgsCoord.latitude,
                lon: position.wgsCoord.longitude)
            
            setCurrentLocation(coordinate: coordinate)
        }
    }
    
    private func setCurrentLocation(coordinate: Coordinates) {
        Task {
            guard let urlRequest = getKakaoLocalGeoURLRequest(coordinate: coordinate),
                  let documents = await performKakaoLocalRequest(urlRequest) else {
                return
            }
            
            if let roadAddress = documents.first?.roadAddress?.addressName{
                currentLocation = roadAddress
            } else if let address = documents.first?.address?.addressName {
                currentLocation = address
            }
            
            currentCoordinate = coordinate
        }
    }
    
    private func getKakaoLocalGeoURLRequest(coordinate: Coordinates) -> URLRequest? {
        return URLRequestBuilder()
            .setHost("dapi.kakao.com")
            .setPath("/v2/local/geo/coord2address.json")
            .addQueryItem(name: "x", value: String(coordinate.lon))
            .addQueryItem(name: "y", value: String(coordinate.lat))
            .addHeader(key: "Authorization", value: "KakaoAK 54412f054c336a5a856d29cc91bfffcc")
            .build()
    }
    
    private func performKakaoLocalRequest(_ urlRequest: URLRequest) async -> [Document]? {
        do {
            let response: KakaoLocal = try await NetworkManager.performRequest(
                urlRequest: urlRequest,
                responseType: KakaoLocal.self)
            
            return response.documents
        } catch {
            return nil
        }
    }
}

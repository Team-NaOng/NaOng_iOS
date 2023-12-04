//
//  LocationCheckViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/09/15.
//

import Foundation
import KakaoMapsSDK

@MainActor
class LocationCheckViewModel: NSObject, ObservableObject, GeoDataService {
    @Published var draw: Bool = true
    @Published var currentLocationInformation: LocationInformation = LocationInformation(locationName: "", locationAddress: "", locationRoadAddress: "", locationCoordinates: Coordinates(lat: 0.0, lon: 0.0))

    override init() {
        super.init()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleMapPoint(_:)),
            name: Notification.Name("MapPointNotification"),
            object: nil)

        setCurrentLocationInformation(coordinate: LocationService.shared.getLocation())
    }
    
    @objc func handleMapPoint(_ notification: Notification) {
        if let position = notification.object as? MapPoint {
            let coordinate = Coordinates(
                lat: position.wgsCoord.latitude,
                lon: position.wgsCoord.longitude)
            
            setCurrentLocationInformation(coordinate: coordinate)
        }
    }
    
    private func setCurrentLocationInformation(coordinate: Coordinates) {
        Task {
            guard let urlRequest = getKakaoLocalGeoURLRequest(coordinate: coordinate),
                  let documents = await performKakaoLocalRequest(urlRequest) else {
                return
            }

            var roadAddress = documents.first?.roadAddress?.addressName ?? ""
            if roadAddress.isEmpty {
                roadAddress = documents.first?.address?.addressName ?? "위치를 가져올 수 없습니다."
            }
            
            var buildingName = documents.first?.roadAddress?.buildingName ?? ""
            if buildingName.isEmpty {
                buildingName = roadAddress
            }

            let locationInfo = LocationInformation(
                locationName: buildingName,
                locationAddress: documents.first?.address?.addressName ?? roadAddress,
                locationRoadAddress: roadAddress,
                locationCoordinates: coordinate)
            currentLocationInformation = locationInfo
        }
    }
}

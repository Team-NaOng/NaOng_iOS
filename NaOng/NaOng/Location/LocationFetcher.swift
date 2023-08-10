//
//  LocationFetcher.swift
//  NaOng
//
//  Created by seohyeon park on 2023/06/13.
//

import CoreLocation

class LocationFetcher {
    /**
     위도와 경도로 현재 위치를 가져오는 커스텀 메서드

     - Parameter coordinate: 위도와 경도
     - Parameter localeIdentifier: Locale 식별자 ("Ko-kr"가 기본값)

     - Throws: 위치 요청에 실패할 경우 `CLError(.geocodeFoundNoResult)`를 던집니다.

     - Returns: 위도와 경도에 대한 주소가 담긴 `CLPlacemark`를 반환합니다.
     */
    func getLocation(coordinate: Coordinates, localeIdentifier: String = "Ko-kr") async throws -> CLPlacemark {
        let location = CLLocation(latitude: coordinate.lat, longitude: coordinate.lon)
        let geocoder = CLGeocoder()
        let locale = Locale(identifier: localeIdentifier)
        
        guard let placemark = try await geocoder.reverseGeocodeLocation(location).first else {
            throw CLError(.geocodeFoundNoResult)
        }
        
        return placemark
    }
}

struct Coordinates: Decodable {
    let lat,lon : Double
}

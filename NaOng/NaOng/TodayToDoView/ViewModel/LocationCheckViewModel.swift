//
//  LocationCheckViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/09/15.
//

import Foundation

@MainActor
class LocationCheckViewModel: NSObject, ObservableObject {
    @Published var draw: Bool = true
    @Published var currentLocation: String = ""

    override init() {
        super.init()
        
        Task {
            guard let urlRequest = getKakaoLocalGeoURLRequest(),
                  let documents = await performKakaoLocalRequest(urlRequest),
                  let address = documents.first?.roadAddress.addressName else {
                currentLocation = "위치 불러오기 실패"
                      return
            }
            
            currentLocation = address
        }
    }
    
    private func getKakaoLocalGeoURLRequest() -> URLRequest? {
        let coordinate = LocationService.shared.getLocation()
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

//
//  GeoDataService.swift
//  NaOng
//
//  Created by seohyeon park on 11/27/23.
//

import Foundation

protocol GeoDataService { 
    func getKakaoLocalGeoURLRequest(coordinate: Coordinates) -> URLRequest?
    func performKakaoLocalRequest(_ urlRequest: URLRequest) async -> [Document]?
}

extension GeoDataService { 
    func getKakaoLocalGeoURLRequest(coordinate: Coordinates) -> URLRequest? {
        return URLRequestBuilder()
            .setHost("dapi.kakao.com")
            .setPath("/v2/local/geo/coord2regioncode.json")
            .addQueryItem(name: "x", value: String(coordinate.lon))
            .addQueryItem(name: "y", value: String(coordinate.lat))
            .addHeader(key: "Authorization", value: "KakaoAK 54412f054c336a5a856d29cc91bfffcc")
            .build()
    }
    
    func performKakaoLocalRequest(_ urlRequest: URLRequest) async -> [Document]? {
        do {
            let response = try await NetworkManager.performRequest(
                urlRequest: urlRequest)
            let data = try NetworkManager.performDecoding(response, responseType: KakaoLocal.self)
            
            return data.documents
        } catch {
            return nil
        }
    }
}

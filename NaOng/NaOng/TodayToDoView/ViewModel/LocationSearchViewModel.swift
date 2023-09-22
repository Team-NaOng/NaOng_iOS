//
//  LocationSearchViewModel.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/25.
//

import Foundation
import Combine

@MainActor
class LocationSearchViewModel: NSObject, ObservableObject {
    @Published var keyword: String = ""
    @Published var locationInformations: [LocationInformation] = []
    @Published var announcement: String = ""
    private var meta: Meta?
    private var currentPage: Int = 1

    func searchLocation() {
        clearAPIData()

        Task {
           if let kakaoLocalKeyword = await fetchKakaoData(using: getKakaoLocalKeywordURLRequest(), responseType: KakaoLocalKeyword.self) {
                handleKakaoData(kakaoLocalKeyword)
            }
        }
    }
    
    func scroll() {
        currentPage += 1

        guard let meta = self.meta,
              meta.isEnd == false,
              let urlRequest = getKakaoLocalKeywordURLRequest(page: currentPage) else {
            return
        }
        
        Task {
            if let kakaoLocalKeyword = await performKakaoRequest(urlRequest, responseType: KakaoLocalKeyword.self) {
                handleKakaoData(kakaoLocalKeyword)
            }
        }
    }
    
    private func clearAPIData() {
        locationInformations = []
        meta = nil
        currentPage = 1
    }
    
    private func fetchKakaoData(using request: URLRequest?, responseType: KakaoAPIResult.Type) async -> KakaoAPIResult? {
        guard let urlRequest = request else {
            return nil
        }

        return await performKakaoRequest(urlRequest, responseType: responseType)
    }
    
    private func performKakaoRequest(_ request: URLRequest, responseType: KakaoAPIResult.Type) async -> KakaoAPIResult? {
        do {
            let response = try await NetworkManager.performRequest(urlRequest: request)
            let data = try NetworkManager.performDecoding(response, responseType: responseType)
            return data
        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    private func getKakaoLocalKeywordURLRequest(page: Int = 1) -> URLRequest? {
        return URLRequestBuilder()
            .setHost("dapi.kakao.com")
            .setPath("/v2/local/search/keyword")
            .addQueryItem(name: "query", value: keyword)
            .addQueryItem(name: "page", value: String(page))
            .addHeader(key: "Authorization", value: "KakaoAK 54412f054c336a5a856d29cc91bfffcc")
            .build()
    }
    
    private func handleKakaoData(_ data: KakaoAPIResult) {
        if let kakaoLocalKeyword = data as? KakaoLocalKeyword,
           let count = kakaoLocalKeyword.meta.totalCount,
           count > 0 {
            meta = kakaoLocalKeyword.meta
            AddLocationInformationWithKakaoLocalKeyword(kakaoLocalKeyword.documents)
        } else {
            announcement = "검색 결과가 없습니다."
        }
    }

    private func AddLocationInformationWithKakaoLocalKeyword(_ documents: [KeywordDocument]) {
        documents.forEach { document in
            var roadAddressName = document.roadAddressName ?? ""
            
            if roadAddressName == "" {
                roadAddressName = document.addressName ?? "위치를 가져올 수 없습니다."
            }
            
            let longitude = Double(document.x ?? "0.0") ?? 0.0
            let latitude = Double(document.y ?? "0.0") ?? 0.0
            let locationInfo = LocationInformation(
                locationName: document.placeName ?? roadAddressName,
                locationAddress: document.addressName ??  roadAddressName,
                locationRoadAddress: roadAddressName,
                locationCoordinates: Coordinates(lat: latitude, lon: longitude))
            locationInformations.append(locationInfo)
        }
    }
}

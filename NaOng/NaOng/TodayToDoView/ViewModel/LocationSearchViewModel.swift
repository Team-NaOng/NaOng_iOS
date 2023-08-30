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
    @Published var documents: [Document] = []
    private var meta: Meta?
    private var currentPage: Int = 1

    func searchLocation() {
        clearAPIData()

        guard let urlRequest = getKakaoLocalURLRequest() else {
            return
        }
        
        performKakaoLocalRequest(urlRequest)
    }
    
    func scroll() {
        currentPage += 1

        guard let meta = self.meta,
              meta.isEnd == false,
              let urlRequest = getKakaoLocalURLRequest(page: currentPage) else {
            return
        }

        performKakaoLocalRequest(urlRequest)
    }
    
    private func clearAPIData() {
        documents = []
        meta = nil
        currentPage = 1
    }
    
    private func getKakaoLocalURLRequest(page: Int = 1, size: Int = 30) -> URLRequest? {
        return URLRequestBuilder()
            .setHost("dapi.kakao.com")
            .setPath("/v2/local/search/address.json")
            .addQueryItem(name: "query", value: keyword)
            .addQueryItem(name: "page", value: String(page))
            .addQueryItem(name: "size", value: String(size))
            .addHeader(key: "Authorization", value: "KakaoAK 54412f054c336a5a856d29cc91bfffcc")
            .build()
    }
    
    private func performKakaoLocalRequest(_ urlRequest: URLRequest) {
        Task {
            do {
                let response: KakaoLocal = try await NetworkManager.performRequest(
                    urlRequest: urlRequest,
                    responseType: KakaoLocal.self)
                
                meta = response.meta
                documents.append(contentsOf: response.documents)
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

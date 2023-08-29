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
    @Published var roadNameAddress: [Juso] = []
    
    private var currentPage: Int = 1
    private var lastIndex: Int = 1
    
    func searchLocation() {
        roadNameAddress = []
        
        let urlBuilder = URLRequestBuilder()
            .addQueryItem(name: "currentPage", value: "\(currentPage)")
            .addQueryItem(name: "countPerPage", value: "10")
            .addQueryItem(name: "keyword", value: keyword)
            .setBasicQueryItems()
            .build()
        
        guard let urlRequest = urlBuilder else {
            return
        }
        
        Task {
            do {
                let response: RoadNameAddress = try await NetworkManager.performRequest(urlRequest: urlRequest, responseType: RoadNameAddress.self)
                
                let juso = response.results.juso
                if juso.isEmpty == false {
                    roadNameAddress = juso
                }
                
                let totalCount = Int(response.results.common.totalCount) ?? 0
                lastIndex = (totalCount / 10) + 1
                
            } catch {
                print("Error: \(error)")
            }
        }
    }
    
    func scroll() {
        currentPage += 1
        
        if (lastIndex > 1) && (lastIndex >= currentPage) {
            let urlBuilder = URLRequestBuilder()
                .addQueryItem(name: "currentPage", value: "\(currentPage)")
                .addQueryItem(name: "countPerPage", value: "10")
                .addQueryItem(name: "keyword", value: keyword)
                .setBasicQueryItems()
                .build()
            
            guard let urlRequest = urlBuilder else {
                return
            }
            
            Task {
                do {
                    let response: RoadNameAddress = try await NetworkManager.performRequest(urlRequest: urlRequest, responseType: RoadNameAddress.self)
                    
                    let juso = response.results.juso
                    if juso.isEmpty == false {
                        roadNameAddress.append(contentsOf: juso)
                    }
                    
                    print(currentPage, lastIndex)
                    
                } catch {
                    print("Error: \(error)")
                }
            }
        }
    }
}

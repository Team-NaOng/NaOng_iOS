//
//  NetworkManager.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/24.
//

import Foundation
import Combine

class NetworkManager {
    static func performRequest(urlRequest: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }

        return data
    }
    
    static func performDecoding<T: Decodable>(_ data: Data, responseType: T.Type) throws -> T {
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.dataDecodingFailed
        }
    }
}

//
//  NetworkManager.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/24.
//

import Foundation

class NetworkManager {
    static func performRequest<T: Decodable>(urlRequest: URLRequest, responseType: T.Type) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: urlRequest)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decodedResponse = try JSONDecoder().decode(T.self, from: data)
            return decodedResponse
        } catch {
            throw NetworkError.dataDecodingFailed
        }
    }
}

//
//  URLRequestBuilder.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/24.
//

import Foundation

class URLRequestBuilder {
    private var scheme: String = "https"
    private var host: String = ""
    private var path: String = ""
    private var httpMethod: String = "GET"
    private var queryItems: [URLQueryItem] = []
    private var header: [String : String] = [:]

    func setHost(_ host: String) -> URLRequestBuilder {
        self.host = host
        return self
    }

    func setPath(_ path: String) -> URLRequestBuilder {
        self.path = path
        return self
    }
    
    func setHTTPMethod(_ method: String) -> URLRequestBuilder {
        self.httpMethod = method
        return self
    }

    func addQueryItem(name: String, value: String) -> URLRequestBuilder {
        self.queryItems.append(URLQueryItem(name: name, value: value))
        return self
    }
    
    func addHeader(key: String, value: String) -> URLRequestBuilder {
        self.header[key] = value
        return self
    }

    func build() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        
        if queryItems.isEmpty == false {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        
        if header.isEmpty == false {
            header.forEach { key, value in
                request.addValue(value, forHTTPHeaderField: key)
            }
        }
        
        return request
    }
}

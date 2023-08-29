//
//  URLRequestBuilder.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/24.
//

import Foundation

class URLRequestBuilder {
    private var scheme: String = "https"
    private var host: String = "business.juso.go.kr"
    private var path: String = "/addrlink/addrLinkApi.do"
    private var queryItems: [URLQueryItem] = []
    private var httpMethod: String = "GET"

    func setHost(_ host: String) -> URLRequestBuilder {
        self.host = host
        return self
    }

    func setPath(_ path: String) -> URLRequestBuilder {
        self.path = path
        return self
    }
    
    func setBasicQueryItems() -> URLRequestBuilder {
        let basicQueryItems: [URLQueryItem] = [
            URLQueryItem(name: "confmKey", value: "U01TX0FVVEgyMDIzMDgyNDE0NTIzMjExNDA0NTA="),
            URLQueryItem(name: "firstSort", value: "road"),
            URLQueryItem(name: "resultType", value: "json")
        ]
        
        basicQueryItems.forEach { item in
            self.queryItems.append(item)
        }
        return self
    }

    func addQueryItem(name: String, value: String) -> URLRequestBuilder {
        self.queryItems.append(URLQueryItem(name: name, value: value))
        return self
    }

    func setHTTPMethod(_ method: String) -> URLRequestBuilder {
        self.httpMethod = method
        return self
    }

    func build() -> URLRequest? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        return request
    }
}

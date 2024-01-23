//
//  DustServiceManager.swift
//  NaOng
//
//  Created by seohyeon park on 1/23/24.
//

import Foundation

public class DustServiceManager {
    func getDustData(_ district: KakaoLocalDistrict) async throws -> AirKorea {
        guard let sidoName = convertToAirKoreaSidoName(from: district.documents.first?.region1DepthName),
              let urlRequest = getDustMeasurementRequest(sidoName: sidoName) else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let data = try await NetworkManager.performRequest(urlRequest: urlRequest)
            return try NetworkManager.performDecoding(data, responseType: AirKorea.self)
        } catch {
            throw error
        }
    }
    
    func getDustItem(items: [Item]?, cityName: String?) -> Item? {
        guard let items = items, !items.isEmpty else {
            return nil
        }
        
        if let cityName = cityName, !cityName.isEmpty {
            return items.filter { $0.cityName == cityName }.map { $0 }.first
        }
        
        return items.first
    }
    
    func generateCurrentDustMessage(item: Item?) -> [String]? {
        guard let item = item,
              let fineDust = getFineDustGradeInformation(pm10Value: item.pm10Value ?? ""),
              let ultraFineDust = getUltraFineDustGradeInformation(pm25Value: item.pm25Value ?? "")else {
            return nil
        }

        var messages = [String]()
        messages.append("\(fineDust.emoji) 미세먼지: \(fineDust.description)\n\(ultraFineDust.emoji) 초미세먼지: \(ultraFineDust.description)")
        
        if let pm10Value = Int(item.pm10Value ?? ""),
           let pm25Value = Int(item.pm25Value ?? ""),
           (pm10Value > 80) || (pm25Value > 35) {
            messages.append("나가기 전에 마스크 챙기세요! 😷")
        }

        return messages
    }
    
    private func convertToAirKoreaSidoName(from kakaoSidoName: String?) -> String? {
        guard let sido = kakaoSidoName else { return nil }
        switch sido {
        case "서울특별시":
            return "서울"
        case "부산광역시":
            return "부산"
        case "대구광역시":
            return "대구"
        case "인천광역시":
            return "인천"
        case "광주광역시":
            return "광주"
        case "대전광역시":
            return "대전"
        case "울산광역시":
            return "울산"
        case "경기도":
            return "경기"
        case "강원특별자치도":
            return "강원"
        case "충청북도":
            return "충북"
        case "충청남도":
            return "충남"
        case "전북특별자치도":
            return "전북"
        case "전라남도":
            return "전남"
        case "경상북도":
            return "경북"
        case "경상남도":
            return "경남"
        case "제주특별자치도":
            return "제주"
        case "세종특별자치시":
            return "세종"
        default:
            return sido
        }
    }

    private func getDustMeasurementRequest(sidoName: String) -> URLRequest? {
        guard let serviceKey = Bundle.main.publicDataPortalKey else {
            return nil
        }
        return URLRequestBuilder()
            .setHost("apis.data.go.kr")
            .setPath("/B552584/ArpltnStatsSvc/getCtprvnMesureSidoLIst")
            .addQueryItem(name: "serviceKey", value: serviceKey)
            .addQueryItem(name: "returnType", value: "json")
            .addQueryItem(name: "numOfRows", value: "100")
            .addQueryItem(name: "pageNo", value: "1")
            .addQueryItem(name: "sidoName", value: sidoName)
            .addQueryItem(name: "searchCondition", value: "Hour")
            .build()
    }
    
    private func getFineDustGradeInformation(pm10Value: String) -> (emoji: String, description: String)? {
        guard let value = Int(pm10Value) else {
            return nil
        }
        
        switch value {
        case 0...30:
            return ("😍", "좋음")
        case 31...80:
            return ("🙂", "보통")
        case 81...150:
            return ("😡", "나쁨")
        default:
            return ("🤬", "매우나쁨")
        }
    }

    private func getUltraFineDustGradeInformation(pm25Value: String) -> (emoji: String, description: String)? {
        guard let value = Int(pm25Value) else {
            return nil
        }
        
        switch value {
        case 0...15:
            return ("😍", "좋음")
        case 16...35:
            return ("🙂", "보통")
        case 36...75:
            return ("😡", "나쁨")
        default:
            return ("🤬", "매우나쁨")
        }
    }
}

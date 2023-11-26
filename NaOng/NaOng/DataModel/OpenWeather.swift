//
//  OpenWeather.swift
//  NaOng
//
//  Created by seohyeon park on 11/27/23.
//

import Foundation

// MARK: - OpenWeather
/**
 - base: 내부 매개변수
 - visibility: 가시성, 미터 (최대 10km)
 - dt: 데이터 계산 시간
 - timezone:  UTC에서 초 단위로 이동
 - id: 도시 ID
 - name: 도시 이름
 - cod: HTTP 상태 코드
*/
struct OpenWeather: Decodable {
    let coord: Coordinates?
    let weather: [Weather]?
    let base: String?
    let main: Main?
    let visibility: Int?
    let wind: Wind?
    let clouds: Clouds?
    let rain: Rain?
//    let snow: Snow?
//    let dt: Int?
//    let sys: Sys?
//    let timezone: Int?
//    let id: Int?
//    let name: String?
//    let cod: Int?
}

// MARK: - Weather
/**
 - id:  날씨 상태 ID
 - main: 날씨 매개 변수 그룹(비, 눈 구름 등)
 - .description: 그룹 내의 날씨 상태
 - icon: 날씨 아이콘 ID
*/
struct Weather: Decodable {
    let id: Int?
    let main: String?
    let description: String?
    let icon: String?
}

// MARK: - Main
/**
 - temp: 현재 온도
 - feelsLike: 체감 온도
 - pressure: 해수면의 대기압, hPa
 - humidity: 습도, %
 - tempMin: 현재 최저 온도
 - tempMax: 현재 최고 온도
 - seaLevel: 해수면의 대기압, hPa
 - grndLevel: 지면 대기압, hPa
*/
struct Main: Decodable {
    let temp: Double?
    let feelsLike: Double?
    let pressure: Int?
    let humidity: Int?
    let tempMin: Double?
    let tempMax: Double?
    let seaLevel: Int?
    let grndLevel: Int?

    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case pressure
        case humidity
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
    }
}

// MARK: - Wind
/**
 - speed: 풍속
 - deg: 풍향, 도(기상학)
 - gust: 돌풍
*/
struct Wind: Decodable {
    let speed: Double?
    let deg: Int?
    let gust: Double?
}

// MARK: - Clouds
/**
 - all: 흐림 정도, %
*/
struct Clouds: Decodable {
    let all: Int?
}

// MARK: - Rain
/**
 - the1h: 지난 1시간 동안의 강우량, mm
 - the3h: 지난 3시간 동안의 강우량, mm.
*/
struct Rain: Decodable {
    let the1h: Double?
    let the3h: Double?

    enum CodingKeys: String, CodingKey {
        case the1h = "1h"
        case the3h = "3h"
    }
}

// MARK: - Snow
/**
 - the1h: 지난 1시간 동안의 적설량, mm
 - the3h: 지난 3시간 동안의 적설량, mm.
*/
struct Snow: Decodable {
    let the1h: Double?
    let the3h: Double?

    enum CodingKeys: String, CodingKey {
        case the1h = "1h"
        case the3h = "3h"
    }
}

// MARK: - Sys
/**
 - type: 내부 매개 변수
 - id: 내부 매개 변수
 - message: 내부 매개 변수
 - country: 국가 코드
 - sunrise: 일출 시간
 - sunset: 일몰 시간
*/
struct Sys: Decodable {
    let type: Int?
    let id: Int?
    let message: String?
    let country: String?
    let sunrise: Int?
    let sunset: Int?
}

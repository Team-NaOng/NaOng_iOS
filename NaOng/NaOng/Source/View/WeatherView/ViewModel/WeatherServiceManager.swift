//
//  WeatherServiceManager.swift
//  NaOng
//
//  Created by seohyeon park on 1/5/24.
//

import Foundation
import CoreLocation
import WeatherKit

public class WeatherServiceManager {
    private var location: CLLocation?
    
    public init(location: CLLocation? = nil) {
        self.location = location
    }
    
    public func getWeather() async -> TodayWeatherInfo? {
        do {
            guard let location = location else {
                return nil
            }
            
            let weather = try await WeatherService.shared.weather(for: location)
            let todayWeather = weather.dailyForecast.forecast.first
            let currentDate = Date()
            let twentyFourHoursLater = Calendar.current.date(byAdding: .hour, value: 24, to: Date()) ?? Date()
            let hourlyForecasts = weather.hourlyForecast
                .filter {
                    currentDate <= $0.date && $0.date <= twentyFourHoursLater
                }.map {
                    HourlyForecast(
                        time: $0.date.getFormatDate("HH"),
                        condition: $0.condition,
                        temperature: $0.temperature.value
                    )
                }

            return TodayWeatherInfo(
                condition: weather.currentWeather.condition,
                currentTemperature: weather.currentWeather.temperature.value,
                highTemperature: todayWeather?.highTemperature.value,
                lowTemperature: todayWeather?.lowTemperature.value,
                sunrise: todayWeather?.sun.sunrise,
                sunset: todayWeather?.sun.sunset,
                uv: todayWeather?.uvIndex,
                hourlyForecasts: hourlyForecasts
            )
        } catch {
            return nil
        }
    }
    
    public func mappingCondition(for condition: WeatherCondition?) -> (emoji: String, description: String)? {
        guard let condition = condition else { return nil }
        let conditionMappings: [WeatherCondition: (emoji: String, description: String)] = [
            .blowingDust: ("🌪️", "먼지 및 모래폭풍"),
            .clear: ("☀️", "맑음"),
            .cloudy: ("☁️", "흐림"),
            .foggy: ("☁️", "안개"),
            .haze: ("☁️", "안개"),
            .mostlyClear: ("🌤️", "구름 조금"),
            .mostlyCloudy: ("⛅️", "대체로 흐림"),
            .partlyCloudy: ("🌤️", "부분적으로 흐림"),
            .smoky: ("💨", "연기"),
            .breezy: ("🍃", "산들바람"),
            .windy: ("🌬️", "바람"),
            .drizzle: ("🌧️", "이슬비"),
            .heavyRain: ("🌧️", "폭우"),
            .isolatedThunderstorms: ("🌩️", "뇌우"),
            .rain: ("🌧️", "비"),
            .sunShowers: ("🌦️", "비"),
            .scatteredThunderstorms: ("🌩️", "많은 뇌우"),
            .strongStorms: ("🌩️", "강한 뇌우"),
            .thunderstorms: ("🌩️", "뇌우"),
            .frigid: ("🥶", "몹시 추움"),
            .hail: ("🌨️", "우박"),
            .hot: ("🥵", "몹시 더움"),
            .flurries: ("❄️", "일시적 눈보라"),
            .sleet: ("❄️", "진눈깨비"),
            .snow: ("❄️", "눈"),
            .sunFlurries: ("❄️", "일시적 눈보라"),
            .wintryMix: ("❄️", "눈비"),
            .blizzard: ("❄️", "눈보라"),
            .blowingSnow: ("❄️", "눈"),
            .freezingDrizzle: ("🌨️", "어는 이슬비"),
            .freezingRain: ("🌨️", "얼어붙는 비"),
            .heavySnow: ("❄️", "폭설"),
            .hurricane: ("🌪️", "폭풍"),
            .tropicalStorm: ("🌪️", "열대 폭풍")
        ]

        return conditionMappings[condition]
    }
    
    public func generateCurrentWeatherMessage(for condition: WeatherCondition?) -> String? {
        guard let mappingCondition = mappingCondition(for: condition) else {
            return nil
        }
        return "현재 날씨: \(mappingCondition.emoji) \(mappingCondition.description)"
    }
    
    public func generateCurrentTemperatureMessage(currentTemperature: Double?) -> String? {
        guard let currentTemperature = currentTemperature else { return nil }
        return "현재 온도: \(round(currentTemperature))°C"
    }

    public func generateSummaryTemperatureMessage(highTemperature: Double?, lowTemperature: Double?) -> String? {
        guard let highTemperature = highTemperature, let lowTemperature = lowTemperature else { return nil }
        return "오늘 최고 온도: \(round(highTemperature))°C \n오늘 최저 온도: \(round(lowTemperature))°C"
    }

    public func generateSunriseSunsetMessage(sunrise: String?, sunset: String?) -> String? {
        guard let sunrise = sunrise, let sunset = sunset else { return nil }
        return "☀️ 일출 시간: \(sunrise)\n🌙 일몰 시간: \(sunset)"
    }
    
    public func generateUVMessage(uv: UVIndex?) -> String? {
        guard let uvValue = uv?.value else { return nil }

        switch uvValue {
        case 11...:
            return "자외선 지수 위험등급입니다. 가급적 실내에 머무르세요."
        case 8...10:
            return "자외선 지수가 매우 높습니다. 한낮에는 외출을 자제해 주세요."
        case 6...7:
            return "자외선 지수가 높습니다. 자외선 차단제와 양산 등을 챙겨주세요."
        case 3...5:
            return "자외선 지수가 보통입니다. 모자와 선글라스를 챙겨주세요."
        default:
            return nil
        }
    }
    
    public func generateHourlyForecastMessage(hourlyForecasts: [HourlyForecast]?) -> String? {
        guard let hourlyForecasts = hourlyForecasts else { return nil }
        var resultMessage = "시간별 날씨"

        hourlyForecasts.forEach {
            if let conditionMapping = mappingCondition(for: $0.condition) {
                let currentWeatherEmoji = conditionMapping.emoji
                let temperatureString = round($0.temperature)
                resultMessage += "\n\(currentWeatherEmoji) \($0.time)시:  \(temperatureString)°C"
            }
        }

        return resultMessage
    }
    
    public func generateWeatherAdviceMessage(for condition: WeatherCondition?) -> String? {
        guard let currentWeatherEmoji = mappingCondition(for: condition)?.emoji else {
            return nil
        }
        
        switch currentWeatherEmoji {
        case "🌪️":
            return "오늘은 되도록 집에 머무르세요. 🥺"
        case "☀️":
            return "당신의 미소처럼 맑은 하늘을 보며 한숨 돌리는 건 어떠세요? ☺️"
        case "🌧️", "🌨️", "🌦️":
            return "나가기 전에 우산 챙겼나요? ☂️"
        case "❄️":
            return "눈이 오면 도로가 미끄러울 수 있으니 주의하세요. ☃️"
        case "🥶":
            return "날이 너무 추우니 따뜻하게 입고 외출하세요! 🧤"
        case "🥵":
            return "열사병이 올 수 있으니 수분을 충분히 섭취해 주세요! 🥤"
        case "🌩️":
            return "천둥번개가 칠 때는 되도록 실내로 이동하세요. ⚡️"
        default:
            return nil
        }
    }
    
    public struct TodayWeatherInfo {
        let condition: WeatherCondition?
        let currentTemperature: Double?
        let highTemperature: Double?
        let lowTemperature: Double?
        let sunrise: Date?
        let sunset: Date?
        let uv: UVIndex?
        let hourlyForecasts: [HourlyForecast]?
    }
    
    public struct HourlyForecast {
        let time: String
        let condition: WeatherCondition
        let temperature: Double
    }
}

//
//  Bundle+Extensions.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/23.
//

import Foundation
import os.log

extension Bundle {
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleName") as? String ?? "앱의 이름을 확인할 수 없습니다."
    }

    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "앱의 버전을 확인할 수 없습니다."
    }
    
    var publicDataPortalKey: String? {
        guard let path = Bundle.main.path(forResource: "APIKey", ofType: "plist"),
              let data = try? Data(contentsOf: URL(filePath: path)),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
              let key = plist["PublicDataPortalKey"] else {
            let osLog = OSLog(subsystem: "Seohyeon.NaOng", category: "APIKey")
            let log = Logger(osLog)
            log.log(level: .error, "공공 데이터 포털 APIKey를 찾을 수 없습니다.")
            return nil
        }
        
        return key
    }
    
    var openWeatherKey: String? {
        guard let path = Bundle.main.path(forResource: "APIKey", ofType: "plist"),
              let data = try? Data(contentsOf: URL(filePath: path)),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
              let key = plist["OpenWeatherKey"] else {
            let osLog = OSLog(subsystem: "Seohyeon.NaOng", category: "APIKey")
            let log = Logger(osLog)
            log.log(level: .error, "OpenWeather APIKey를 찾을 수 없습니다.")
            return nil
        }
        
        return key
    }
}

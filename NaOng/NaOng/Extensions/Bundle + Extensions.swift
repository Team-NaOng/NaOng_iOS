//
//  Bundle + Extensions.swift
//  NaOng
//
//  Created by seohyeon park on 11/27/23.
//

import Foundation
import os.log

extension Bundle {
    var publicDataPortalKey: String? {
        guard let path = Bundle.main.path(forResource: "APIKey", ofType: "plist"),
              let data = try? Data(contentsOf: URL(filePath: path)),
              let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: String],
              let key = plist["PublicDataPortalKey"] else {
            let osLog = OSLog(subsystem: "Seohyeon.NaOng", category: "APIKey")
            let log = Logger(osLog)
            log.log(level: .error, "APIKey를 찾을 수 없습니다.")
            return nil
        }
        
        return key
    }
}

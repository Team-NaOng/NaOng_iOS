//
//  Bundle+Extensions.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/23.
//

import Foundation

extension Bundle {
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleName") as? String ?? "앱의 이름을 확인할 수 없습니다."
    }

    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "앱의 버전을 확인할 수 없습니다."
    }
}

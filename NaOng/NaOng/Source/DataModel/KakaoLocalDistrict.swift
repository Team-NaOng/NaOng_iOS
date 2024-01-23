//
//  KakaoLocalDistrict.swift
//  NaOng
//
//  Created by seohyeon park on 1/23/24.
//

// MARK: - KakaoLocalDistrict
struct KakaoLocalDistrict: Decodable {
    let meta: Meta
    let documents: [DistrictDocument]
}

// MARK: - DistrictDocument
struct DistrictDocument: Decodable {
    let regionType, code, addressName, region1DepthName: String
    let region2DepthName, region3DepthName, region4DepthName: String
    let x, y: Double

    enum CodingKeys: String, CodingKey {
        case regionType = "region_type"
        case code
        case addressName = "address_name"
        case region1DepthName = "region_1depth_name"
        case region2DepthName = "region_2depth_name"
        case region3DepthName = "region_3depth_name"
        case region4DepthName = "region_4depth_name"
        case x, y
    }
}

//
//  KakaoLocalKeyword.swift
//  NaOng
//
//  Created by seohyeon park on 2023/09/22.
//

import Foundation

struct KakaoLocalKeyword: Decodable, KakaoAPIResult {
    let documents: [KeywordDocument]
    let meta: Meta
}

// MARK: - KeywordDocument
/**
 - id: 장소 ID
 - placeName:  장소명, 업체명
 - categoryName: 카테고리 이름
 - categoryGroupCode: 중요 카테고리만 그룹핑한 카테고리 그룹 코드
 - categoryGroupName: 중요 카테고리만 그룹핑한 카테고리 그룹명
 - phone: 전화번호
 - addressName:  전체 지번 주소
 - roadAddressName: 전체 도로명 주소
 - x: X 좌표값, 경위도인 경우 longitude (경도)
 - y: Y 좌표값, 경위도인 경우 latitude(위도)
 - placeUrl: 장소 상세페이지 URL
 - distance: 중심좌표까지의 거리 (단, x,y 파라미터를 준 경우에만 존재), 단위 meter
 */
struct KeywordDocument: Decodable {
    let id: String?
    let placeName: String?
    let categoryName: String?
    let categoryGroupCode: String?
    let categoryGroupName: String?
    let phone: String?
    let addressName: String?
    let roadAddressName: String?
    let x: String?
    let y: String?
    let placeURL: String?
    let distance: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case placeName = "place_name"
        case categoryName = "category_name"
        case categoryGroupCode = "category_group_code"
        case categoryGroupName = "category_group_name"
        case phone
        case addressName = "address_name"
        case roadAddressName = "road_address_name"
        case x
        case y
        case placeURL = "place_url"
        case distance
    }
}

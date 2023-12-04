//
//  KakaoLocal.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/31.
//

import Foundation

// MARK: - KakaoLocal
struct KakaoLocal: Decodable {
    let documents: [Document]
    let meta: Meta
}

// MARK: - Document
/**
 - addressName: 전체 지번 주소 또는 전체 도로명 주소. 입력에 따라 결정됨
 - addressType: address_name의 값의 타입(Type). REGION(지명), ROAD(도로명), REGION_ADDR(지번 주소), ROAD_ADDR (도로명 주소) 중 하나
 - x: X 좌표값, 경위도인 경우 longitude (경도)
 - y: Y 좌표값, 경위도인 경우 latitude (위도)
 - address: 지번주소 상세 정보
 - roadAddress: 도로명주소 상세 정보
*/
struct Document: Decodable {
    let addressName: String?
    let addressType: String?
    let x: String?
    let y: String?
    let address: Address?
    let roadAddress: RoadAddress?

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case addressType = "address_type"
        case x
        case y
        case address
        case roadAddress = "road_address"
    }
}

// MARK: - Address
/**
 - addressName: 전체 지번 주소
 - region1DepthName: 지역 1 Depth, 시도 단위
 - region2DepthName: 지역 2 Depth, 구 단위
 - region3DepthName: 지역 3 Depth, 동 단위
 - region3DepthHName: 지역 3 Depth, 행정동 명칭
 - hCode: 행정 코드
 - bCode: 법정 코드
 - mountainYn: 산 여부, Y 또는 N
 - mainAddressNo: 지번 주번지
 - subAddressNo: 지번 부번지, 없을 경우 ""
 - x: X 좌표값, 경위도인 경우 longitude (경도)
 - y: Y 좌표값, 경위도인 경우 latitude (위도)
*/
struct Address: Decodable {
    let addressName: String?
    let region1DepthName: String?
    let region2DepthName: String?
    let region3DepthName: String?
    let region3DepthHName: String?
    let hCode: String?
    let bCode: String?
    let mountainYn: String?
    let mainAddressNo: String?
    let subAddressNo: String?
    let x: String?
    let y: String?

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case region1DepthName = "region_1depth_name"
        case region2DepthName = "region_2depth_name"
        case region3DepthName = "region_3depth_name"
        case region3DepthHName = "region_3depth_h_name"
        case hCode = "h_code"
        case bCode = "b_code"
        case mountainYn = "mountain_yn"
        case mainAddressNo = "main_address_no"
        case subAddressNo = "sub_address_no"
        case x
        case y
    }
}

// MARK: - RoadAddress
/**
 - addressName: 전체 도로명 주소
 - region1DepthName: 지역명 1
 - region2DepthName: 지역명 2
 - region3DepthName: 지역명 3
 - roadName: 도로명
 - undergroundYn: 지하 여부, Y 또는 N
 - mainBuildingNo: 건물 본번
 - subBuildingNo: 건물 부번, 없을 경우 ""
 - buildingName: 건물 이름
 - zoneNo: 우편번호(5자리)
 - x: X 좌표값, 경위도인 경우 longitude (경도)
 - y: Y 좌표값, 경위도인 경우 latitude (위도)
*/
struct RoadAddress: Decodable {
    let addressName: String?
    let region1DepthName: String?
    let region2DepthName: String?
    let region3DepthName: String?
    let roadName: String?
    let undergroundYn: String?
    let mainBuildingNo: String?
    let subBuildingNo: String?
    let buildingName: String?
    let zoneNo: String?
    let x: String?
    let y: String?

    enum CodingKeys: String, CodingKey {
        case addressName = "address_name"
        case region1DepthName = "region_1depth_name"
        case region2DepthName = "region_2depth_name"
        case region3DepthName = "region_3depth_name"
        case roadName = "road_name"
        case undergroundYn = "underground_yn"
        case mainBuildingNo = "main_building_no"
        case subBuildingNo = "sub_building_no"
        case buildingName = "building_name"
        case zoneNo = "zone_no"
        case x
        case y
    }
}

// MARK: - Meta
/**
 - totalCount: 검색어에 검색된 문서 수
 - pageableCount: total_count 중 노출 가능 문서 수, 최대 45
 - isEnd: 현재 페이지가 마지막 페이지인지 여부, 값이 false면 page를 증가시켜 다음 페이지를 요청할 수 있음
*/
struct Meta: Decodable {
    let totalCount: Int?
    let pageableCount: Int?
    let isEnd: Bool?
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case pageableCount = "pageable_count"
        case isEnd = "is_end"
    }
}

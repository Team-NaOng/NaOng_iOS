//
//  RoadNameAddress.swift
//  NaOng
//
//  Created by seohyeon park on 2023/08/24.
//


// MARK: - RoadNameAddress
struct RoadNameAddress: Codable {
    let results: Results
}

// MARK: - Results
struct Results: Codable {
    let common: Common
    let juso: [Juso]
}

// MARK: - Common
/**
 - totalCount: 총 검색 데이터 수
 - currentPage: 페이지 번호
 - countPerPage: 페이지당 출력할 결과 Row 수
 - errorCode: 에러코드 (정상 작동 시 0)
 - errorMessage: 에러 메세지 (정상 작동 시 "정상")
*/
struct Common: Codable {
    let totalCount: String
    let currentPage: String
    let countPerPage: String
    let errorCode: String
    let errorMessage: String
}

// MARK: - Juso
/**
 - roadAddr: 전체 도로명주소
 - roadAddrPart1: 도로명주소(참고항목 제외)
 - roadAddrPart2: 도로명주소 참고항복
 - jibunAddr: 지번 정보
 - engAddr: 도로명주소(영문)
 - zipNo: 우편번호
 - admCd: 행정구역코드
 - rnMgtSn: 도로명코드
 - bdMgtSn: 건물관리번호
 - detBdNmList: 상세건물명
 - bdNm: 건물명
 - bdKdcd: 공동주택여부 (1:공동주택, 0: 비공동주택)
 - siNm: 시도명
 - sggNm: 시군구명
 - emdNm: 읍면동명
 - liNm: 법정리명
 - Rn: 도로명
 - udrtYn: 지하여부 (0:지상, 1:지하)
 - buldMnnm: 건물본번
 - buldSlno: 건물부번 (부번이 없는 경우 0)
 - mtYn: 산여부 (0:대지, 1:산)
 - lnbrMnnm: 지번본번(번지)
 - lnbrSlno: 지번부번(호) (부번이 없는 경우 0)
 - emdNo: 읍면동일련번호
 */
struct Juso: Codable, Hashable {
    let roadAddr: String
    let roadAddrPart1: String
    let roadAddrPart2: String
    let jibunAddr: String
    let engAddr: String
    let zipNo: String
    let admCd: String
    let rnMgtSn: String
    let bdMgtSn: String
    let detBdNmList: String
    let bdNm: String
    let bdKdcd: String
    let siNm: String
    let sggNm: String
    let emdNm: String
    let liNm: String
    let rn: String
    let udrtYn: String
    let buldMnnm: String
    let buldSlno: String
    let mtYn: String
    let lnbrMnnm: String
    let lnbrSlno: String
    let emdNo: String
}

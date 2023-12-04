//
//  AirKorea.swift
//  NaOng
//
//  Created by seohyeon park on 11/27/23.
//

import Foundation

// MARK: - AirKorea
struct AirKorea: Decodable {
    let response: Response?
}

// MARK: - Response
struct Response: Decodable {
    let header: Header?
    let body: Body?
}

// MARK: - Header
/**
 - resultCode:  결과코드
 - resultMsg: 결과메세지
*/
struct Header: Decodable {
    let resultCode: String?
    let resultMsg: String?
}

// MARK: - Body
/**
 - numOfRows:  한 페이지 결과 수
 - pageNo: 페이지 번호
 - totalCount:  전체 결과 수
 - items: 목록
*/
struct Body: Decodable {
    let numOfRows: Int?
    let pageNo: Int?
    let totalCount: Int?
    let items: [Item]?
}

// MARK: - Item
/**
 - dataTime:  오염도측정 (연-월-일 시간: 분)
 - stationName: 측정소 이름
 - stationCode:  측정소 코드 값
 - mangName: 측정망 정보 (도시대기, 도로변대기, 국가배경농도, 교외대기, 항만)
 - so2Value: 아황산가스 농도 (단위 : ppm)
 - coValue: 일산화탄소 농도 (단위 : ppm)
 - o3Value: 오존 농도 (단위 : ppm)
 - no2Value: 이산화질소 농도 (단위 : ppm)
 - pm10Value: 미세먼지(PM10) 농도 (단위 : ㎍/㎥)
 - pm10Value24: 미세먼지(PM10) 24시간예측이동농도 (단위 : ㎍/㎥)
 - pm25Value: 미세먼지(PM2.5)  농도 (단위 : ㎍/㎥)
 - pm25Value24: 미세먼지(PM2.5) 24시간예측이동농도 (단위 : ㎍/㎥)
 - khaiValue: 통합대기환경수치
 - khaiGrade: 통합대기환경지수
 - so2Grade: 아황산가스 지수
 - coGrade: 일산화탄소 지수
 - o3Grade: 오존 지수
 - no2Grade: 이산화질소 지수
 - pm10Grade: 미세먼지(PM10) 24시간 등급자료
 - pm25Grade: 미세먼지(PM2.5) 24시간 등급자료
 - pm10Grade1h: 미세먼지(PM10) 1시간 등급자료
 - pm25Grade1h: 미세먼지(PM2.5) 1시간 등급자료
 - so2Flag: 아항산가스 측정자료 상태정보 (점검및교정,장비점검,자료이상,통신장애)
 - coFlag: 일산화탄소 측정자료 상태정보 (점검및교정,장비점검,자료이상,통신장애)
 - o3Flag: 오존 측정자료 상태정보 (점검및교정,장비점검,자료이상,통신장애)
 - no2Flag: 이산화질소 측정자료 상태정보 (점검및교정,장비점검,자료이상,통신장애)
 - pm10Flag: 미세먼지(PM10) 측정자료 상태정보 (점검및교정,장비점검,자료이상,통신장애)
 - pm25Flag: 미세먼지(PM2.5) 측정자료 상태정보 (점검및교정,장비점검,자료이상,통신장애)
*/
struct Item: Decodable {
    let dataTime: String?
    let stationName: String?
    let stationCode: String?
    let mangName: String?
    let so2Value: String?
    let coValue: String?
    let o3Value: String?
    let no2Value: String?
    let pm10Value: String?
    let pm10Value24: String?
    let pm25Value: String?
    let pm25Value24: String?
    let khaiValue: String?
    let khaiGrade: String?
    let so2Grade: String?
    let coGrade: String?
    let o3Grade: String?
    let no2Grade: String?
    let pm10Grade: String?
    let pm25Grade: String?
    let pm10Grade1h: String?
    let pm25Grade1h: String?
    let so2Flag: String?
    let coFlag: String?
    let o3Flag: String?
    let no2Flag: String?
    let pm10Flag: String?
    let pm25Flag: String?
}

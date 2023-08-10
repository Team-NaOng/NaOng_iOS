//
//  LocationService.swift
//  NaOng
//
//  Created by seohyeon park on 2023/06/03.
//

import CoreLocation
import SwiftUI
 
class LocationService: NSObject {
    static let shared = LocationService()
    private var locationManager: CLLocationManager?
    @AppStorage("userLatitude") private var latitude: Double = 0
    @AppStorage("userLongitude") private var longitude: Double = 0

    private override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func loadLocation() {
        locationManager?.requestAlwaysAuthorization()
    }
    
    func getLocation() -> Coordinates {
        let lat = latitude
        let lon = longitude
        return Coordinates(lat: lat, lon: lon)
    }
    
    func getCircularRegion(
        latitude: Double,
        longitude: Double,
        radius: Double = 50.0,
        identifier: String
    ) -> CLCircularRegion {
        let center = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
        let circularRegion = CLCircularRegion(
            center: center,
            radius: radius,
            identifier: identifier)
        circularRegion.notifyOnEntry = true
        circularRegion.notifyOnExit = false
        return circularRegion
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) || (status == .authorizedAlways)  {
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        print(latitude, longitude)

        //locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("위치 업데이트 에러: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
        }
    }
}

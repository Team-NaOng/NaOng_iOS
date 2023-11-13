//
//  LocationService.swift
//  NaOng
//
//  Created by seohyeon park on 2023/06/03.
//

import CoreLocation
import os.log
 
class LocationService: NSObject {
    static let shared = LocationService()
    private var locationManager: CLLocationManager?
    private var latitude: Double = 0
    private var longitude: Double = 0

    private override init() {
        super.init()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
    }
    
    func loadLocation() {
        locationManager?.requestWhenInUseAuthorization()
    }
    
    func getLocation() -> Coordinates {
        let lat = latitude
        let lon = longitude
        return Coordinates(lat: lat, lon: lon)
    }
    
    func getCircularRegion(
        latitude: Double,
        longitude: Double,
        radius: Double = 30.0,
        identifier: String
    ) -> CLCircularRegion {
        let center = CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
        let circularRegion = CLCircularRegion(
            center: center,
            radius: radius,
            identifier: identifier)
        circularRegion.notifyOnEntry = false
        circularRegion.notifyOnExit = true
        return circularRegion
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedWhenInUse) {
            locationManager?.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude

        locationManager?.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let osLog = OSLog(subsystem: "Seohyeon.NaOng", category: "Location")
        let log = Logger(osLog)
        log.log(level: .error, "Location Update Error: \(error.localizedDescription)")
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        default:
            manager.stopUpdatingLocation()
        }
    }
}

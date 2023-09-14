//
//  KakaoMapView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/09/08.
//

import SwiftUI
import KakaoMapsSDK

struct KakaoMapView: UIViewRepresentable {
    @Binding var draw: Bool

    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view: KMViewContainer = KMViewContainer()
        view.sizeToFit()
        context.coordinator.createController(view)
        context.coordinator.controller?.initEngine()
        
        return view
    }
    
    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        if draw {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                context.coordinator.controller?.startEngine()
                context.coordinator.controller?.startRendering()
            }
        }
        else {
            context.coordinator.controller?.stopRendering()
            context.coordinator.controller?.stopEngine()
        }
    }
    
    func makeCoordinator() -> KakaoMapCoordinator {
        return KakaoMapCoordinator()
    }
    
    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
        
    }
    
    class KakaoMapCoordinator: NSObject, MapControllerDelegate {
        var controller: KMController?
        var first: Bool
        
        private var _mapTapEventHandler: DisposableEventHandler?
        
        override init() {
            first = true
            super.init()
        }
        
        deinit {
            _mapTapEventHandler?.dispose()
        }
        
        func createController(_ view: KMViewContainer) {
            controller = KMController(viewContainer: view)
            controller?.delegate = self
        }
        
        func addViews() {
            let defaultPosition: MapPoint = MapPoint(longitude: 127.108678, latitude: 37.402001)
            let mapviewInfo: MapviewInfo = MapviewInfo(viewName: "mapview", viewInfoName: "map", defaultPosition: defaultPosition, defaultLevel: 7)
            
            guard controller?.addView(mapviewInfo) == Result.OK,
                  let mapView = controller?.getView("mapview") as? KakaoMap else {
                return
            }
            
            _mapTapEventHandler = mapView.addMapTappedEventHandler(target: self) { [weak self] coordinator in
                return { param in
                    self?.mapDidTapped(param)
                }
            }
        }
        
        func containerDidResized(_ size: CGSize) {
            guard let mapView: KakaoMap = controller?.getView("mapview") as? KakaoMap else {
                return
            }
            
            mapView.viewRect = CGRect(origin: CGPoint(x: 0.0, y: 0.0), size: size)
            
            if first {
                let currentCoordinates = LocationService.shared.getLocation()
                let cameraUpdate: CameraUpdate = CameraUpdate.make(target: MapPoint(longitude: currentCoordinates.lon, latitude: currentCoordinates.lat), zoomLevel: 18, rotation: 1.7, tilt: 0.0, mapView: mapView)
                mapView.moveCamera(cameraUpdate)
                first = false
            }
        }
        
        func mapDidTapped(_ param: ViewInteractionEventParam) {
            guard let mapView = param.view as? KakaoMap else {
                return
            }
            
            let position = mapView.getPosition(param.point)
            
            print("❗️: \( position.wgsCoord.latitude), \(position.wgsCoord.latitude)")
        }
    }
}

//
//  KakaoMapView.swift
//  NaOng
//
//  Created by seohyeon park on 2023/09/08.
//

import SwiftUI
import KakaoMapsSDK
import Combine

struct KakaoMapView: UIViewRepresentable {
    func makeUIView(context: Self.Context) -> KMViewContainer {
        let view: KMViewContainer = KMViewContainer()
        view.sizeToFit()
        context.coordinator.createController(view)
        context.coordinator.controller?.initEngine()

        return view
    }
    
    func updateUIView(_ uiView: KMViewContainer, context: Self.Context) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            context.coordinator.controller?.startEngine()
            context.coordinator.controller?.startRendering()
        }
    }
    
    func makeCoordinator() -> KakaoMapCoordinator {
        return KakaoMapCoordinator()
    }
    
    static func dismantleUIView(_ uiView: KMViewContainer, coordinator: KakaoMapCoordinator) {
        coordinator.controller?.stopRendering()
        coordinator.controller?.stopEngine()
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
                let cameraUpdate: CameraUpdate = CameraUpdate.make(target: MapPoint(longitude: currentCoordinates.lon, latitude: currentCoordinates.lat), zoomLevel: 18, rotation: 0.0, tilt: 0.0, mapView: mapView)
                mapView.moveCamera(cameraUpdate)
                first = false
            }
            
            let manager = mapView.getLabelManager()
            let position = MapPoint(
                longitude: LocationService.shared.getLocation().lon,
                latitude: LocationService.shared.getLocation().lat)

            createLabelLayer(manager)
            createPoiStyle(manager)
            createPois(manager, position)
        }
        
        func mapDidTapped(_ param: ViewInteractionEventParam) {
            guard let mapView = param.view as? KakaoMap else {
                return
            }
            
            let position = mapView.getPosition(param.point)
            
            NotificationCenter.default.post(
                name: Notification.Name("MapPointNotification"),
                object: position)
            
            let manager = mapView.getLabelManager()
            hideAllPois(manager)
            createPoiStyle(manager)
            createPois(manager, position)
        }
        
        private func createLabelLayer(_ manager: LabelManager) {
            let layerOption = LabelLayerOptions(
                layerID: "PoiLayer",
                competitionType: .none,
                competitionUnit: .poi,
                orderType: .rank,
                zOrder: 10001)
            let _ = manager.addLabelLayer(option: layerOption)
        }
        
        private func createPoiStyle(_ manager: LabelManager) {
            let pinImage = UIImage(named: "pin")
            let resizedImage = pinImage?.resize(targetSize: CGSize(width: 50.0, height: 50.0))
            
            let iconStyle = PoiIconStyle(symbol: resizedImage, anchorPoint: CGPoint(x: 0.5, y: 1.0))
            let perLevelStyle = PerLevelPoiStyle(iconStyle: iconStyle, level: 0)
            let poiStyle = PoiStyle(styleID: "customStyle1", styles: [perLevelStyle])
            manager.addPoiStyle(poiStyle)
        }
        
        private func createPois(_ manager: LabelManager, _ mapPoint: MapPoint) {
            let layer = manager.getLabelLayer(layerID: "PoiLayer")
            let poiOption = PoiOptions(styleID: "customStyle1")
            poiOption.transformType = .decal
            
            let poi = layer?.addPoi(
                option: poiOption,
                at: mapPoint
            )
            poi?.show()
        }
        
        private func hideAllPois(_ manager: LabelManager) {
            let layer = manager.getLabelLayer(layerID: "PoiLayer")
            layer?.hideAllPois()
        }
    }
}

//
//  NMapViewController.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/6/24.
//

import SwiftUI
import UIKit
import NMapsMap

class NMapViewController: UIViewController {
    
    var places: [Place] = []
    var currentPlace: Place?
    var onPlaceSelected: ((Place) -> Void)?
    
    private var mapView: NMFMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = NMFMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
        
        mapView.logoAlign = .rightTop
        
        // 마커 추가
        addMarkersToMap()
    }
    
    func addMarkersToMap() {
        // 장소에 마커 추가
        for place in places {
            let marker = NMFMarker()
            // marker.iconImage = NMFOverlayImage(name: "marker_icon")
            marker.position = NMGLatLng(lat: place.latitude, lng: place.longitude)
            marker.mapView = mapView
            marker.touchHandler = { [weak self] _ in
                guard let self = self else { return false }
                self.currentPlace = place
                self.onPlaceSelected?(place)
                self.moveToPlace(place: place)
                return true
            }
        }
        
        // 초기 지도 중심 이동
        if let currentPlace = currentPlace {
            moveToPlace(place: currentPlace)
        }
    }
    
    func moveToPlace(place: Place) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: place.latitude, lng: place.longitude))
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
}

struct NMapViewControllerRepresentable: UIViewControllerRepresentable {
    var places: [Place]
    var currentPlace: Place?
    
    func makeUIViewController(context: Context) -> NMapViewController {
        let viewController = NMapViewController()
        viewController.places = places
        viewController.currentPlace = currentPlace
        viewController.onPlaceSelected = { place in
            context.coordinator.parent.currentPlace = place
        }
        context.coordinator.viewController = viewController
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: NMapViewController, context: Context) {
        uiViewController.places = places
        uiViewController.currentPlace = currentPlace
        uiViewController.addMarkersToMap()
        
        if let currentPlace = currentPlace {
            uiViewController.moveToPlace(place: currentPlace)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    class Coordinator: NSObject {
        var parent: NMapViewControllerRepresentable
        var viewController: NMapViewController?
        
        init(parent: NMapViewControllerRepresentable) {
            self.parent = parent
        }
    }
}

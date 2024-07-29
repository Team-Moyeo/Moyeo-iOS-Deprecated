import UIKit
import NMapsMap
import SwiftUI

class NMapViewController: UIViewController {
    var places: [Place] = []
    var selectedPlace: Place?
    
    private var mapView: NMFMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView = NMFMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
        
        // 마커 추가
        addMarkersToMap()
    }
    
    func addMarkersToMap() {
        // 기존 마커 제거
//        mapView.clear()
        
        // 장소에 마커 추가
        for place in places {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: place.latitude, lng: place.longitude)
            marker.mapView = mapView
            marker.touchHandler = { _ in
                print("Marker tapped at position: \(place.name)")
                return true
            }
        }
        
        // 지도 중심 이동
        if let selectedPlace = selectedPlace {
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: selectedPlace.latitude, lng: selectedPlace.longitude))
            mapView.moveCamera(cameraUpdate)
        }
    }
}

struct NMapViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var places: [Place]
    @Binding var selectedPlace: Place? // 선택된 장소 추가
    
    func makeUIViewController(context: Context) -> NMapViewController {
        let viewController = NMapViewController()
        return viewController
    }

    func updateUIViewController(_ uiViewController: NMapViewController, context: Context) {
        uiViewController.places = places
        uiViewController.selectedPlace = selectedPlace // 선택된 장소 업데이트
        uiViewController.addMarkersToMap()
    }
}

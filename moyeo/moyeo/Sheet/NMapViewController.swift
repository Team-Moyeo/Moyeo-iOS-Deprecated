import SwiftUI
import UIKit
import NMapsMap

class NMapViewController: UIViewController {
    var places: [Place] = []
    var selectedPlace: Place?
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
//            marker.iconImage = NMFOverlayImage(name: "marker_icon")
            marker.position = NMGLatLng(lat: place.latitude, lng: place.longitude)
            marker.mapView = mapView
            marker.touchHandler = { [weak self] _ in
                guard let self = self else { return false }
                self.selectedPlace = place
                self.onPlaceSelected?(place)
                self.moveToPlace(place: place)
                return true
            }
        }
        
        // 초기 지도 중심 이동
        if let selectedPlace = selectedPlace {
            moveToPlace(place: selectedPlace)
        }
    }
    
    func moveToPlace(place: Place) {
        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: place.latitude, lng: place.longitude))
        cameraUpdate.animation = .easeIn
        mapView.moveCamera(cameraUpdate)
    }
//    
//    func updateMap(for place: Place) {
//        // 지도 중심 이동
//        let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: place.latitude, lng: place.longitude))
//        mapView.moveCamera(cameraUpdate)
//        
//        // 마커 추가
//        addMarkersToMap()
//    }
}

struct NMapViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var places: [Place]
    @Binding var selectedPlace: Place?
    
    func makeUIViewController(context: Context) -> NMapViewController {
        let viewController = NMapViewController()
        viewController.places = places
        viewController.selectedPlace = selectedPlace
        viewController.onPlaceSelected = { place in
            self.selectedPlace = place
        }
        context.coordinator.viewController = viewController
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: NMapViewController, context: Context) {
        uiViewController.places = places
        uiViewController.selectedPlace = selectedPlace
        uiViewController.addMarkersToMap()
        
//        // 선택된 장소에 대한 지도 업데이트
//        if let selectedPlace = selectedPlace {
//            uiViewController.updateMap(for: selectedPlace)
//        }
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

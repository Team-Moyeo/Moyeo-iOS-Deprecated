import UIKit
import NMapsMap
import SwiftUI

class NMapViewController: UIViewController {
    var places: [Place] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let mapView = NMFMapView(frame: self.view.bounds)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view.addSubview(mapView)
        
        // 맵 관련 속성 설정
//        mapView.showScaleBar = true
//        mapView.showZoomControls = true
//        mapView.showLocationButton = false
        
        // 마커 추가
        addMarkersToMap(mapView: mapView)
    }
    
    func addMarkersToMap(mapView: NMFMapView) {
        for place in places {
            let marker = NMFMarker()
            marker.position = NMGLatLng(lat: place.latitude, lng: place.longitude)
            marker.mapView = mapView
            marker.touchHandler = { _ in
                print("Marker tapped at position: \(place.name)")
                return true
            }
        }
    }
}


struct NMapViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var places: [Place]
    
    func makeUIViewController(context: Context) -> NMapViewController {
        let viewController = NMapViewController()
        viewController.places = places
        return viewController
    }

    func updateUIViewController(_ uiViewController: NMapViewController, context: Context) {
        uiViewController.places = places
        if let mapView = uiViewController.view.subviews.first(where: { $0 is NMFMapView }) as? NMFMapView {
            uiViewController.addMarkersToMap(mapView: mapView)
        }
    }
}

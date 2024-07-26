import SwiftUI

struct SearchResponse: Codable {
    let items: [PlaceResponse]
}

struct PlaceResponse: Codable {
    let title: String
    let roadAddress: String
    let mapx: String
    let mapy: String
}

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let roadAddress: String
    let latitude: Double
    let longitude: Double
}

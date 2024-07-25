import SwiftUI
import NMapsMap

struct TempPlaceSearchView: View {
    @State private var searchQuery: String = ""
    @State private var places: [Place] = [] // 장소 데이터를 저장할 배열
    
    var body: some View {
        VStack {
            TextField("Search for places", text: $searchQuery, onCommit: {
                searchPlaces(query: searchQuery)
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
            
            // 검색 결과 리스트
            List(places) { place in
                Text(place.name)
            }
            
            NMapViewControllerRepresentable(places: $places)
                .edgesIgnoringSafeArea(.all)
        }
    }
    
    private func searchPlaces(query: String) {
        // 여기에 검색 API를 호출하여 places 배열을 업데이트하는 로직을 추가합니다.
        // 예를 들어, 네이버 장소 검색 API를 호출할 수 있습니다.
    }
}

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
}

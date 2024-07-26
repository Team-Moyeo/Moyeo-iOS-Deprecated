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
                VStack(alignment: .leading) {
                    Text(place.name) // Title
                        .font(.headline)
                    Text(place.roadAddress) // Road Address
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            
            NMapViewControllerRepresentable(places: $places)
                .edgesIgnoringSafeArea(.all)
        }
    }
    private func searchPlaces(query: String) {
        guard let url = URL(string: "https://openapi.naver.com/v1/search/local.json?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&display=10") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("7CXqtGiq5s7GYBdQji6l", forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue("CDIp_3N75c", forHTTPHeaderField: "X-Naver-Client-Secret")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let items = json["items"] as? [[String: Any]] {
                    let places = items.compactMap { item -> Place? in
                        guard let name = item["title"] as? String,
                              let latitude = item["mapy"] as? String,
                              let longitude = item["mapx"] as? String,
                              let roadAddress = item["roadAddress"] as? String else { return nil }
                        return Place(name: name, roadAddress: roadAddress, latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0)
                    }
                    DispatchQueue.main.async {
                        self.places = places
                    }
                }
            } catch {
                print("JSON parsing error: \(error)")
            }
        }.resume()
    }

    
    
}

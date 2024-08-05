import SwiftUI
import NMapsMap

// 지도 보이는 뷰
struct PlaceSearchView: View {
    @State private var searchQuery: String = ""
    @State private var places: [Place] = [] // 장소 데이터를 저장할 배열
    @State private var showSearchResults: Bool = false
    @State private var selectedPlace: Place? // 선택한 장소 저장
    
    @State private var meetingId: String = "12345"
    @State private var memberId: String = "54321"
    @Binding var isPresentingPlaceSearchView: Bool
    
    var body: some View {
        NavigationStack {
            VStack {
                // 장소 검색 텍스트 필드 & 검색 및 취소 버튼
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        TextField("장소를 검색하세요", text: $searchQuery, onCommit: {
                            searchPlaces(query: searchQuery) // 아래 extension쪽에 있음
                        })
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 7)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.leading)
                    
                    Button(action: {
                        UIApplication.shared.endEditing(true)
                        if showSearchResults {
                            showSearchResults = false
                        } else {
                            searchPlaces(query: searchQuery)
                            showSearchResults = true
                        }
                    }) {
                        Text(showSearchResults ? "취소" : "검색")
                            .padding(.trailing)
//                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                // 검색 버튼을 눌렀을 경우 리스트 뷰를 띄운다.
                if showSearchResults {
                    placeSearchListView() // 아래 extension쪽에 있음
                } else {
                    GeometryReader { geometry in
                        ZStack {
                            // 취소 버튼을 눌렀을 경우 다시 맵뷰를 띄운다
                            NMapViewControllerRepresentable(places: $places, selectedPlace: $selectedPlace)
                                .edgesIgnoringSafeArea(.all)
                        }
                    }
                }
            }
        }
        .navigationTitle("새로운 장소 추가")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// 검색 결과 리스트뷰
extension PlaceSearchView {
    @ViewBuilder
    func placeSearchListView() -> some View {
        List(places) { place in
            NavigationLink(
                destination: PlaceAddView(
                    place: Place(
//                        id: place.id,
                        name: place.name,
                        roadAddress: place.roadAddress,
                        latitude: place.latitude,
                        longitude: place.longitude,
                        memberId: memberId,
                        meetingId: meetingId),
                    places: $places,
                    selectedPlace: $selectedPlace, isPresentingPlaceSearchView: $isPresentingPlaceSearchView
                ),
                label: {
                    VStack(alignment: .leading) {
                        Text(place.name)
                            .font(.headline)
                        Text(place.roadAddress)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                })
        }
    }
}

// API 요청 및 JSON 파일 가공 함수
extension PlaceSearchView {
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
                        return Place(
//                            id: UUID(),
                            name: name,
                            roadAddress: roadAddress,
                            latitude: Double(latitude)! / 1e7,
                            longitude: Double(longitude)! / 1e7,
                            memberId: memberId,
                            meetingId: meetingId
                        )
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
extension UIApplication {
    func endEditing(_ force: Bool) {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

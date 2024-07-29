import SwiftUI
import NMapsMap

// 지도 보이는 뷰
struct TempPlaceSearchView: View {
    @State private var searchQuery: String = ""
    @State private var places: [Place] = [] // 장소 데이터를 저장할 배열
    @State private var showSearchResults: Bool = false
    @State private var selectedPlace: Place? // 선택한 장소 저장
    
    var body: some View {
        VStack {
            // 상단 제목 텍스트
            Text("새로운 장소 추가")
                .font(.system(size: 17))
                .bold()
                .padding()
            
            // 장소 검색 텍스트 필드 & 검색 및 취소 버튼
            HStack{
                TextField("장소를 검색하세요", text: $searchQuery, onCommit: {
                    searchPlaces(query: searchQuery)
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading)
                
                Button(action: {
                    if showSearchResults {
                        showSearchResults = false
                    } else {
                        searchPlaces(query: searchQuery)
                        showSearchResults = true
                    }
                }) {
                    Text(showSearchResults ? "취소" : "검색")
                        .padding(.trailing)
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                }
            }
            // 검색 버튼을 눌렀을 경우 리스트 뷰를 띄운다.
            if showSearchResults{
                placeSearchListView()
            } else {
                // 취소 버튼을 눌렀을 경우 다시 맵뷰를 띄운다
                NMapViewControllerRepresentable(places: $places, selectedPlace: $selectedPlace)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}

// 검색 결과 리스트뷰
extension TempPlaceSearchView {
    @ViewBuilder
    func placeSearchListView() -> some View {
        List(places) { place in
            VStack(alignment: .leading) {
                Text(place.name)
                    .font(.headline)
                Text(place.roadAddress)
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            .onTapGesture {
                selectedPlace = place
                showSearchResults = false
            }
        }
    }
}

// API 요청 및 JASON 파일 가공 함수
extension TempPlaceSearchView {
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

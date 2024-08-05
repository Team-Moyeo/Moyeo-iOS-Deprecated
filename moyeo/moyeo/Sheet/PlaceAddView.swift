import SwiftUI
import NMapsMap

struct PlaceAddView: View {
    var place: Place
    @Binding var places: [Place]
    @Binding var selectedPlace: Place?
    
    @State private var mapViewController: NMapViewController? = nil
    @Binding var isPresentingPlaceSearchView: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // NMapViewControllerRepresentable를 통해 지도를 표시
                NMapViewControllerRepresentable(places: $places, selectedPlace: $selectedPlace)
                    .edgesIgnoringSafeArea([.leading, .bottom, .trailing])
                    .onAppear {
                        // 지도와 정보창 업데이트
                        selectedPlace = place
                        mapViewController?.moveToPlace(place: place)
                    }
                VStack{
                    Spacer()
                    // 정보창
                    if selectedPlace != nil {
                        infoWindow(geometry: geometry)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .navigationTitle("새로운 장소 추가") // PlaceAddView의 네비게이션 타이틀 추가
        .navigationBarTitleDisplayMode(.inline) // 타이틀을 작게 표시
    }
}
extension PlaceAddView {
    @ViewBuilder
    func infoWindow(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(selectedPlace?.name ?? "")
                .font(.headline)
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .padding(.top, 10)
            Text(selectedPlace?.roadAddress ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: {
                isPresentingPlaceSearchView.toggle()
                if let selectedPlace = selectedPlace {
                    postPlace(place: selectedPlace) { success in
                        if success {
                            places.append(selectedPlace)
                        } else {
                            print("Failed to add place")
                        }
                    }
                }
                              
            }) {
                Text("추가하기")
                    .font(.body)
                    .bold()
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.06)
                    .background(Color.myDD8686)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: geometry.size.width)
        .ignoresSafeArea(.all)
    }
    
    func postPlace(place: Place, completion: @escaping (Bool) -> Void) {
        let urlString = "https://5techcdong.store/meetings/\(place.meetingId)/place"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(false)
            return
        }

        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(place)
            request.httpBody = jsonData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error posting data: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    completion(false)
                    return
                }
                
                completion(true)
            }.resume()
        } catch {
            print("Error encoding data: \(error.localizedDescription)")
            completion(false)
        }
    }
}

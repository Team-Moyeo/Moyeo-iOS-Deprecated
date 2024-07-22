import SwiftUI

struct TempPlaceSearchView: View {
    @State private var keyword = ""
    @State private var places = [Place]()
    private let naverMapService = NaverMapService()

    var body: some View {
        NavigationView {
            VStack {
                TextField("검색어를 입력하세요", text: $keyword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button("검색") {
                    naverMapService.searchPlace(keyword: keyword) { places in
                        self.places = places
                    }
                }
                .padding()

                List(places) { place in
                    VStack(alignment: .leading) {
                        Text(place.name)
                            .font(.headline)
                        Text(place.address)
                            .font(.subheadline)
                    }
                }
            }
            .navigationTitle("가게 검색")
        }
    }
}

//@main
//struct MyApp: App {
//    var body: some Scene {
//        WindowGroup {
//            TempPlaceSearchView()
//        }
//    }
//}

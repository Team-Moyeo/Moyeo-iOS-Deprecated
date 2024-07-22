import Foundation

struct Place: Identifiable {
    let id = UUID()
    let name: String
    let address: String
}

class NaverMapService {
    private let clientID = "vtjhtr895t"
    private let clientSecret = "OrYPE4bgx88t90JkSJAUQaN5OztmofH7xW5yhg1c"
    
    func searchPlace(keyword: String, completion: @escaping ([Place]) -> Void) {
        let urlString = "https://naveropenapi.apigw.ntruss.com/map-place/v1/search?query=\(keyword)&coordinate=127.1054328,37.3595963"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
        request.addValue(clientID, forHTTPHeaderField: "X-NCP-APIGW-API-KEY-ID")
        request.addValue(clientSecret, forHTTPHeaderField: "X-NCP-APIGW-API-KEY")
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else { return }
            do {
                // JSON 데이터 파싱
                let result = try JSONDecoder().decode(SearchResult.self, from: data)
                let places = result.places.map { Place(name: $0.name, address: $0.roadAddress) }
                DispatchQueue.main.async {
                    completion(places)
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
}

struct SearchResult: Decodable {
    let places: [PlaceData]
    
    struct PlaceData: Decodable {
        let name: String
        let roadAddress: String
    }
}

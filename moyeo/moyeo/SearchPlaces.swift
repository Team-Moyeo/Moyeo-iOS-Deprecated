import Foundation

func searchPlaces(query: String, completion: @escaping ([Place]) -> Void) {
    let apiKey = "YOUR_API_KEY" // 네이버 API 키
    let urlString = "https://openapi.naver.com/v1/search/local.json?query=\(query)&display=10" // 예시 URL
    guard let url = URL(string: urlString) else { return }
    
    var request = URLRequest(url: url)
    request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data, error == nil else {
            print("Error: \(error?.localizedDescription ?? "Unknown error")")
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let items = json["items"] as? [[String: Any]] {
                let places = items.compactMap { item -> Place? in
                    guard let name = item["title"] as? String,
                          let latitude = item["mapy"] as? String,
                          let longitude = item["mapx"] as? String else { return nil }
                    return Place(name: name, latitude: Double(latitude) ?? 0.0, longitude: Double(longitude) ?? 0.0)
                }
                completion(places)
            }
        } catch {
            print("Error parsing JSON: \(error.localizedDescription)")
        }
    }
    
    task.resume()
}

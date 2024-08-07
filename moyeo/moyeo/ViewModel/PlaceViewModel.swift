//
//  PlaceViewModel.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/6/24.
//

import Foundation

@Observable
class PlaceViewModel {
    var searchQuery: String = ""
    var places: [Place] = []
    var showSearchResults: Bool = false
    var selectedPlace: Place?
    var isPresentingPlaceSearchView: Bool = false
    
    private var meetingId: String
    private var memberId: String
    
    init(meetingId: String, memberId: String) {
        self.meetingId = meetingId
        self.memberId = memberId
    }
}

extension PlaceViewModel {
    /// API 요청 및 JSON 파일 가공 함수
    func searchPlaces() async {
        guard let url = URL(string: "https://openapi.naver.com/v1/search/local.json?query=\(searchQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&display=10") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("7CXqtGiq5s7GYBdQji6l", forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue("CDIp_3N75c", forHTTPHeaderField: "X-Naver-Client-Secret")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
            let places = searchResponse.items.compactMap { item -> Place? in
                guard let latitude = Double(item.mapy),
                      let longitude = Double(item.mapx) else { return nil }
                return Place(
                    name: item.title,
                    roadAddress: item.roadAddress,
                    latitude: latitude / 1e7,
                    longitude: longitude / 1e7,
                    memberId: self.memberId,
                    meetingId: self.meetingId
                )
            }
            DispatchQueue.main.async {
                self.places = places
            }
            
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    func postPlace() async -> Bool {
        guard let place = selectedPlace else { return false }
        let urlString = "https://5techcdong.store/meetings/\(place.meetingId)/place"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let jsonData = try JSONEncoder().encode(place)
            request.httpBody = jsonData
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return false
            }
            
            DispatchQueue.main.async {
                self.places.append(place)
            }
            return true
            
        } catch {
            print("Error posting data: \(error)")
            return false
        }
    }
}

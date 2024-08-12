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
    var currentPlace: Place?
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
        
        guard let naverClientId = Bundle.main.object(forInfoDictionaryKey: "XNaverClientId") as? String else { return }
        guard let naverClientSecret = Bundle.main.object(forInfoDictionaryKey: "XNaverClientSecret") as? String else { return }
        
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(naverClientId, forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(naverClientSecret, forHTTPHeaderField: "X-Naver-Client-Secret")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let searchResponse = try JSONDecoder().decode(SearchResponse.self, from: data)
            let places = searchResponse.items.compactMap { item -> Place? in
                guard let latitude = Double(item.mapy),
                      let longitude = Double(item.mapx) else { return nil }

                return Place(
                    name: stripHTMLTags(from: item.title),
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
    
    func postPlace() async throws -> Bool {
        guard let selectedPlace = currentPlace else { return false }
        
        guard let url = URL(string: APIEndpoints.basicURLString(path: .places)) else {
            print("Invalid URL")
            return false
        }
        
        let accessToken = try SignInInfo.shared.readToken(.access)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let title = selectedPlace.name
        let address = selectedPlace.roadAddress
        let latitude = selectedPlace.latitude
        let longitude = selectedPlace.longitude
        
        let body: [String: Any] = [
            "title": title,
            "address": address,
            "latitude": latitude,
            "longitude": longitude
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
            
            let (data, httpResponse) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = httpResponse as? HTTPURLResponse,
               !(200..<300).contains(httpResponse.statusCode) {
                print("🐻‍❄️Error: \(httpResponse.statusCode) badRequest")
            }
            
            DispatchQueue.main.async {
                self.places.append(selectedPlace)
                print(self.places)
            }
            return true
            
        } catch {
            print("Error posting data: \(error)")
            return false
        }
    }
    
    func stripHTMLTags(from string: String) -> String {
        // 정규식 패턴으로 HTML 태그를 매칭합니다.
        let regexPattern = "<[^>]+>"
        
        // 정규식을 사용해 HTML 태그를 빈 문자열로 대체합니다.
        if let regex = try? NSRegularExpression(pattern: regexPattern, options: .caseInsensitive) {
            let range = NSRange(location: 0, length: string.utf16.count)
            let cleanedString = regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: "")
            return cleanedString
        } else {
            // 정규식 생성에 실패한 경우, 원본 문자열을 반환합니다.
            return string
        }
    }
}

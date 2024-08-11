//
//  CreateMeetingViewModel.swift
//  moyeo
//
//  Created by Woowon Kang on 8/10/24.
//

import Foundation
import AuthenticationServices

class CreateMeetingViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var startDate: String = ""
    @Published var endDate: String = ""
    @Published var startTime: String = ""
    @Published var endTime: String = ""
    @Published var fixedTimes: [String]?
    @Published var places: [Place] = []
    @Published var fixedPlace: PlaceInfo?
    @Published var deadline: String = ""
    
}

extension CreateMeetingViewModel {
    
    @MainActor
        func createMeeting() async {
            let requestPayload = prepareRequestPayload()
            
            guard let url = URL(string: APIEndpoints.basicURLString(path: .meetings)) else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")

            do {
                let accessToken = try SignInInfo.shared.readToken(.access)
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                request.httpBody = try JSONSerialization.data(withJSONObject: requestPayload, options: [])
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    print("Invalid response")
                    return
                }
                
                if httpResponse.statusCode == 200 {
                    print("Meeting created successfully")
                } else {
                    // Print status code and response body for debugging
                    print("Failed to create meeting. Status code: \(httpResponse.statusCode)")
                    let responseBody = String(data: data, encoding: .utf8) ?? "No response body"
                    print("Response body: \(responseBody)")
                }
                
            } catch {
                print("Error creating meeting: \(error.localizedDescription)")
            }
        }
    
    
    
    func prepareRequestPayload() -> [String: Any] {
        var payload: [String: Any] = [
            "title": title,
            "deadline": deadline
        ]
        
        if !startDate.isEmpty {
            payload["startDate"] = startDate
        }
        
        if !endDate.isEmpty {
            payload["endDate"] = endDate
        }
        
        if !startTime.isEmpty {
            payload["startTime"] = startTime
        }
        
        if !endTime.isEmpty {
            payload["endTime"] = endTime
        }
        
        if let fixedTimes = fixedTimes, !fixedTimes.isEmpty {
            payload["fixedTimes"] = fixedTimes
        }
        
        if let fixedPlace = fixedPlace {
            payload["fixedPlace"] = [
                "title": fixedPlace.title,
                "address": fixedPlace.address,
                "latitude": fixedPlace.latitude,
                "longitude": fixedPlace.longitude
            ]
        }
        
        if !places.isEmpty {
            payload["candidatePlaces"] = places.map { place in
                [
                    "title": place.name,
                    "address": place.roadAddress,
                    "latitude": place.latitude,
                    "longitude": place.longitude
                ]
            }
        }
        print("meeting잘 들어갔나 봅시다. \(payload)")
        return payload
    }
    
}

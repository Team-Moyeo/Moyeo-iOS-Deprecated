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
    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var fixedTimes: [String]?
    @Published var places: [Place] = []
    @Published var fixedPlace: PlaceInfo?
    @Published var deadline: String = ""
    @Published var meetingId: Int64 = 0
    
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
            print("❤️@모임생성: \(String(data: data, encoding: .utf8) ?? "")")
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response")
                return
            }
            
            if httpResponse.statusCode == 200 {
                print("Meeting created successfully")
                guard let decoded = try? JSONDecoder().decode(BaseResponse<MeetingResult>.self, from: data) else {
                    return
                }
                
                self.meetingId = decoded.result?.meetingId ?? -1
                print("IN CREATEMEETING☠️\(self.meetingId)")
                
                
                
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
        
        let startDateString = self.startDate.yearMonthDay()
        let endDateString = self.endDate.yearMonthDay()
        // let startTimeString = self.startTime.hourMinute()
        // let endTimeString = self.endTime.hourMinute()
        
        /// 일단 시간 범위 설정과 무관하게, 오전 00시부터 오후 11시 30분까지 24시간 범위로 고정 -> 수정할 것!
        let startTimeString = "00:00:00"
        let endTimeString = "23:30:00"
        
        var payload: [String: Any] = [
            "title": title,
            "deadline": deadline
        ]
        
        if !startDateString.isEmpty {
            payload["startDate"] = startDateString
        }
        
        if !endDateString.isEmpty {
            payload["endDate"] = endDateString
        }
        
        if !startTimeString.isEmpty {
            payload["startTime"] = startTimeString
        }
        
        if !endTimeString.isEmpty {
            payload["endTime"] = endTimeString
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

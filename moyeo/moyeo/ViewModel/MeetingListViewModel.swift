//
//  MeetingListViewModel.swift
//  moyeo
//
//  Created by Woowon Kang on 8/5/24.
//

import Foundation

@Observable
class MeetingListViewModel {
    var meetings: [MeetingListResponse.MeetingStatus] = []
    var isLoading: Bool = false
    
    var meetingId: Int64?
    var title: String?
    var deadline: String?
    
    // 필터링된 회의 목록
    var confirmedMeetings: [MeetingListResponse.MeetingStatus] {
        meetings.filter { $0.meetingStatus == "CONFIRM" || $0.meetingStatus == "END" }
    }
    
    var disconfirmedMeetings: [MeetingListResponse.MeetingStatus] {
        meetings.filter { $0.meetingStatus == "PENDING" }
    }
}

extension MeetingListViewModel {
    
    @MainActor
        func fetchMeetings(meetingStatus: String) async {
            isLoading = true
            
            do {
                let accessToken = try SignInInfo.shared.readToken(.access)
                var urlComponents = URLComponents(string: APIEndpoints.basicURLString(path: .meetingStatus))
                urlComponents?.queryItems = [
                    URLQueryItem(name: "ß", value: meetingStatus)
                ]
                
                guard let url = urlComponents?.url else {
                    print("Failed to create URL")
                    isLoading = false
                    return
                }
                
                var request = URLRequest(url: url)
                request.httpMethod = "GET"
                request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    isLoading = false
                    print("Failed to fetch meetings: No valid HTTP response")
                    return
                }
                
                print("HTTP Response Status Code: \(httpResponse.statusCode)")
                
                guard (200..<300).contains(httpResponse.statusCode) else {
                    isLoading = false
                    print("Failed to fetch meetings: HTTP Status Code \(httpResponse.statusCode)")
                    if let responseData = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseData)")
                    }
                    return
                }
                
                do {
                    let baseResponse = try JSONDecoder().decode(BaseResponse<MeetingListResponse>.self, from: data)
                    if let meetingListResponse = baseResponse.result {
                        self.meetings = meetingListResponse.meetingList
                        print("Meetings fetched successfully: \(meetingListResponse.meetingList)")
                    } else {
                        print("No meetings found")
                    }
                } catch {
                    print("Failed to decode response: \(error.localizedDescription)")
                    isLoading = false
                    return
                }
                
            } catch {
                print("Failed to fetch meetings: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            isLoading = false
        }
    
}

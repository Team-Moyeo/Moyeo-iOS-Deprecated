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
    
    var meetingId: Int64
    var name: String
    var deadlne: String
    
    init(meetingId: Int64, name: String, deadlne: String) {
        self.meetings = [
            MeetingListResponse.MeetingStatus(meetingId: 1, name: "와인 동아리", deadline: "24. 08. 01"),
            MeetingListResponse.MeetingStatus(meetingId: 2, name: "오텍동 회식", deadline: "24. 08. 04"),
            MeetingListResponse.MeetingStatus(meetingId: 3, name: "테니스 동아리", deadline: "24. 08. 15")
        ]
        
        self.meetingId = meetingId
        self.name = name
        self.deadlne = deadlne
    }
}

extension MeetingListViewModel {
    
    @MainActor
    func fetchMeetings(userIdentifier: String) async {
        isLoading = true
        
        do {
            let accessToken = try SignInInfo.shared.readToken(.access)
            let urlString = APIEndpoints.basicURLString(path: .meetingStatus)
            guard let url = URL(string: urlString) else {
                print("Failed to create URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200..<300).contains(httpResponse.statusCode) else {
                isLoading = false
                print("Failed to fetch meetings")
                return
            }
            
            do {
                let baseResponse = try JSONDecoder().decode(BaseResponse<[MeetingListResponse.MeetingStatus]>.self, from: data)
                if let meetings = baseResponse.result {
                    self.meetings = meetings
                } else {
                    print("No meetings found")
                }
            } catch {
                print("Failed to decode response: \(error.localizedDescription)")
                return
            }
            
        } catch {
            print("Failed to fetch meetings: \(error.localizedDescription)")
            return
        }
        
        isLoading = false
    }
    
    
}

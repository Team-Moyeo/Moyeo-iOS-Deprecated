//
//  MeetingNetworkManager.swift
//  moyeo
//
//  Created by kyungsoolee on 8/13/24.
//

import Foundation

class MeetingNetworkManager: ObservableObject {
    
    // MARK: - 모임 삭제
    @MainActor
    func fetchDeleteMeeting(meetingId: Int, candidatePlaceId: Int) async -> MeetingResponse.DeleteMeeting {
        var response = MeetingResponse.DeleteMeeting()
        
        do {
            response = try await deleteMeeting(meetingId: meetingId)
            
        } catch {
            print("[fetchDeleteMeeting] Error: \(error)")
        }
        
        return response
    }
    
    func deleteMeeting(meetingId: Int) async throws -> MeetingResponse.DeleteMeeting {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.meetings.rawValue + "/\(meetingId)", queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.DELETE, needAuthorization: true, headers: [:], requestBody: nil)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<MeetingResponse.DeleteMeeting>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
}

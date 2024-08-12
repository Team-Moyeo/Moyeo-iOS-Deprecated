//
//  MemberNetworkManager.swift
//  moyeo
//
//  Created by kyungsoolee on 8/13/24.
//

import Foundation

class MemberNetworkManager: ObservableObject {
    
    // MARK: - 모임 참여자 조회
    @MainActor
    func fetchGetMembersByMeeting(meetingId: Int) async -> MemberResponse.GetMembersByMeeting {
        var response = MemberResponse.GetMembersByMeeting()
        
        do {
            response = try await getMembersByMeeting(meetingId: meetingId)
            
        } catch {
            print("[fetchGetMembersByMeeting] Error: \(error)")
        }
        
        return response
    }
    
    func getMembersByMeeting(meetingId: Int) async throws -> MemberResponse.GetMembersByMeeting {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.membersMeeting.rawValue + "/\(meetingId)", queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.GET, needAuthorization: true, headers: [:], requestBody: nil)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<MemberResponse.GetMembersByMeeting>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
}

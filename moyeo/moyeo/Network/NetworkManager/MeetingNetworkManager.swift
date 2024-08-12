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
    
    // MARK: - 모임 가입
    @MainActor
    func fetchJoinMeetingWithInviteCode(inviteCode: String) async -> MeetingResponse.JoinWithInviteCode {
        var response = MeetingResponse.JoinWithInviteCode()
        
        do {
            response = try await joinMeetingWithInviteCode(inviteCode: inviteCode)
            
        } catch {
            print("[fetchDeleteMeeting] Error: \(error)")
        }
        
        return response
    }
    
    func joinMeetingWithInviteCode(inviteCode: String) async throws -> MeetingResponse.JoinWithInviteCode {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.meetingsJoin.rawValue + "/\(inviteCode)", queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.POST, needAuthorization: true, headers: [:], requestBody: nil)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<MeetingResponse.JoinWithInviteCode>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
    // MARK: - 모임 초대코드 조회
    @MainActor
    func fetchGetInviteCode(meetingId: Int) async -> MeetingResponse.GetInviteCode {
        var response = MeetingResponse.GetInviteCode()
        
        do {
            response = try await getInviteCode(meetingId: meetingId)
            
        } catch {
            print("[fetchGetInviteCode] Error: \(error)")
        }
        
        return response
    }
    
    func getInviteCode(meetingId: Int) async throws -> MeetingResponse.GetInviteCode {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.meetingsInviteCode.rawValue + "/\(meetingId)", queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.GET, needAuthorization: true, headers: [:], requestBody: nil)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<MeetingResponse.GetInviteCode>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
    // MARK: - 모임 상세 조회
    @MainActor
    func fetchGetMeetingDetail(meetingId: Int) async -> MeetingResponse.GetMeetingDetail {
        var response = MeetingResponse.GetMeetingDetail()
        
        do {
            response = try await getMeetingDetail(meetingId: meetingId)
            
        } catch {
            print("[fetchGetMeetingDetail] Error: \(error)")
        }
        
        return response
    }
    
    func getMeetingDetail(meetingId: Int) async throws -> MeetingResponse.GetMeetingDetail {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.meetings.rawValue + "/\(meetingId)", queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.GET, needAuthorization: true, headers: [:], requestBody: nil)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<MeetingResponse.GetMeetingDetail>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
    // MARK: - 투표 수정(재투표)
    @MainActor
    func fetchVoteUpdate(meetingId: Int, request: MeetingRequest.VoteUpdate) async -> MeetingResponse.VoteUpdate {
        var response = MeetingResponse.VoteUpdate()
        
        do {
            let requestBody = try NetworkHelper.encodeRequestBody(requestBody: request)
            response = try await voteUpdate(meetingId: meetingId, requestBody: requestBody)
            
        } catch {
            print("[fetchVoteUpdate] Error: \(error)")
        }
        
        return response
    }
    
    func voteUpdate(meetingId: Int, requestBody: Data) async throws -> MeetingResponse.VoteUpdate {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.meetings.rawValue + "/\(meetingId)" + APIEndpoints.Path.voteUpdateValues.rawValue, queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.POST, needAuthorization: true, headers: [:], requestBody: requestBody)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<MeetingResponse.VoteUpdate>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
    // MARK: - 모임 확정
    @MainActor
    func fetchFixMeeting(meetingId: Int, request: MeetingRequest.FixMeeting) async -> MeetingResponse.FixMeeting {
        var response = MeetingResponse.FixMeeting()
        
        do {
            let requestBody = try NetworkHelper.encodeRequestBody(requestBody: request)
            response = try await fixMeeting(meetingId: meetingId, requestBody: requestBody)
            
        } catch {
            print("[fetchVoteUpdate] Error: \(error)")
        }
        
        return response
    }
    
    func fixMeeting(meetingId: Int, requestBody: Data) async throws -> MeetingResponse.FixMeeting {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.meetings.rawValue + "/\(meetingId)" + APIEndpoints.Path.fix.rawValue, queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.POST, needAuthorization: true, headers: [:], requestBody: requestBody)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<MeetingResponse.FixMeeting>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
    // MARK: - 모임 결과 조회
    @MainActor
    func fetchGetMeetingResult(meetingId: Int) async -> MeetingResponse.GetMeetingResult {
        var response = MeetingResponse.GetMeetingResult()
        
        do {
            response = try await getMeetingResult(meetingId: meetingId)
            
        } catch {
            print("[fetchGetMeetingResult] Error: \(error)")
        }
        
        return response
    }
    
    func getMeetingResult(meetingId: Int) async throws -> MeetingResponse.GetMeetingResult {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.meetings.rawValue + "/\(meetingId)" + APIEndpoints.Path.result.rawValue, queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.GET, needAuthorization: true, headers: [:], requestBody: nil)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<MeetingResponse.GetMeetingResult>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
    // MARK: - 모임 결과 조회
    @MainActor
    func fetchGetMeetingsByStatus(meetingStatus: MeetingResponse.GetMeetingsByStatus.MeetingStatus?) async -> MeetingResponse.GetMeetingsByStatus {
        var response = MeetingResponse.GetMeetingsByStatus()
        
        do {
            response = try await getMeetingsByStatus(meetingStatus: meetingStatus)
            
        } catch {
            print("[fetchGetMeetingsByStatus] Error: \(error)")
        }
        
        return response
    }
    
    func getMeetingsByStatus(meetingStatus: MeetingResponse.GetMeetingsByStatus.MeetingStatus?) async throws -> MeetingResponse.GetMeetingsByStatus {
        var queryItems: [URLQueryItem] = []
        
        // meetingStatus가 nil이 아닐 경우, queryItems에 추가
        if let meetingStatus = meetingStatus {
            queryItems.append(URLQueryItem(name: "meetingStatus", value: meetingStatus.rawValue))
        }
        
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.meetings.rawValue, queryItems: queryItems)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.GET, needAuthorization: true, headers: [:], requestBody: nil)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<MeetingResponse.GetMeetingsByStatus>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
    // MARK: - 모임 생성
    @MainActor
    func fetchCreateMeeting(request: MeetingRequest.CreateMeeting) async -> MeetingResponse.CreateMeeting {
        var response = MeetingResponse.CreateMeeting()
        
        do {
            let requestBody = try NetworkHelper.encodeRequestBody(requestBody: request)
            response = try await createMeeting(requestBody: requestBody)
            
        } catch {
            print("[fetchCreateMeeting] Error: \(error)")
        }
        
        return response
    }
    
    func createMeeting(requestBody: Data) async throws -> MeetingResponse.CreateMeeting {
        
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.meetings.rawValue, queryItems: [])
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.POST, needAuthorization: true, headers: [:], requestBody: requestBody)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<MeetingResponse.CreateMeeting>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
}

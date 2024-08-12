//
//  CandidatePlaceNetworkManager.swift
//  moyeo
//
//  Created by kyungsoolee on 8/13/24.
//

import Foundation

class CandidatePlaceNetworkManager: ObservableObject {
    
    // MARK: - 모임 상세 조회(장소)
    @MainActor
    func fetchGetMeetingDetailPlaces(meetingId: Int) async -> CandidatePlaceResponse.GetMeetingDetailPlaces {
        var response = CandidatePlaceResponse.GetMeetingDetailPlaces()
        
        do {
            response = try await getMeetingDetailPlaces(meetingId: meetingId)
            
        } catch {
            print("[fetchGetMeetingDetailPlaces] Error: \(error)")
        }
        
        return response
    }
    
    func getMeetingDetailPlaces(meetingId: Int) async throws -> CandidatePlaceResponse.GetMeetingDetailPlaces {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.candidatePlaces.rawValue + "/\(meetingId)", queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.GET, needAuthorization: true, headers: [:], requestBody: nil)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<CandidatePlaceResponse.GetMeetingDetailPlaces>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
    // MARK: - 후보 장소 추가
    @MainActor
    func fetchAddCandidatePlace(meetingId: Int, placeId: Int) async -> CandidatePlaceResponse.AddCandidatePlace {
        var response = CandidatePlaceResponse.AddCandidatePlace()
        
        do {
            response = try await addCandidatePlace(meetingId: meetingId, placeId: placeId)
            
        } catch {
            print("[fetchAddCandidatePlace] Error: \(error)")
        }
        
        return response
    }
    
    func addCandidatePlace(meetingId: Int, placeId: Int) async throws -> CandidatePlaceResponse.AddCandidatePlace {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.candidatePlaces.rawValue + "/\(meetingId)" + "/\(placeId)", queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.POST, needAuthorization: true, headers: [:], requestBody: nil)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<CandidatePlaceResponse.AddCandidatePlace>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    // MARK: - 후보 장소 삭제
    @MainActor
    func fetchDeleteCandidatePlace(meetingId: Int, candidatePlaceId: Int) async -> CandidatePlaceResponse.DeleteCandidatePlace {
        var response = CandidatePlaceResponse.DeleteCandidatePlace()
        
        do {
            response = try await deleteCandidatePlace(meetingId: meetingId, candidatePlaceId: candidatePlaceId)
            
        } catch {
            print("[fetchDeleteCandidatePlace] Error: \(error)")
        }
        
        return response
    }
    
    func deleteCandidatePlace(meetingId: Int, candidatePlaceId: Int) async throws -> CandidatePlaceResponse.DeleteCandidatePlace {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.candidatePlaces.rawValue + "/\(meetingId)" + "/\(candidatePlaceId)", queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.DELETE, needAuthorization: true, headers: [:], requestBody: nil)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<CandidatePlaceResponse.DeleteCandidatePlace>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
    
}

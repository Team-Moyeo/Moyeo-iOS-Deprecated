//
//  PlaceNetworkManager.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import Foundation

class PlaceNetworkManager: ObservableObject {
    
    // MARK: - 장소 등록
    @MainActor
    func fetchCreatePlace(request: PlaceRequest.PlaceCreate) async -> PlaceResponse.PlaceCreate {
        var response = PlaceResponse.PlaceCreate()
        
        do {
            let requestBody = try NetworkHelper.encodeRequestBody(requestBody: request)
            response = try await createPlace(requestBody: requestBody)
            
        } catch {
            print("[fetchCreatePlace] Error: \(error)")
        }
        
        return response
    }
    
    func createPlace(requestBody: Data) async throws -> PlaceResponse.PlaceCreate {
        let url = try NetworkHelper.setUrlComponet(path: APIEndpoints.Path.places.rawValue, queryItems: nil)
        
        let request = try NetworkHelper.setUrlRequest(url: url, httpMethod: NetworkHelper.HttpMethod.POST, needAuthorization: true, headers: [:], requestBody: requestBody)
        
        let (data, optionalResponse) = try await URLSession.shared.data(for: request)
        
        let response = try NetworkHelper.getResponse(response: optionalResponse)
        
        print(response)
        
        let jsonDictionary = try JSONDecoder().decode(BaseResponse<PlaceResponse.PlaceCreate>.self, from: data)
        
        guard let result = jsonDictionary.result else {
            throw NetworkError.decodeFailed
        }
        
        return result
    }
}

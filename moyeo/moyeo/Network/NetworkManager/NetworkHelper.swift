//
//  NetworkHelper.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import Foundation

class NetworkHelper {
    
    static func setUrlComponet(path: String, queryItems: [URLQueryItem]?) throws -> URL {
        print("---setUrlComponet---")
        var urlComponents = APIEndpoints.getBasicUrlComponents()
        urlComponents.path = path
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            print("[setUrlComponet] Error")
            throw NetworkError.cannotCreateURL
        }
        
        return url
    }
    
    static func setUrlRequest(url: URL, httpMethod: HttpMethod, needAuthorization: Bool, headers: [String: String], requestBody: Data?) throws -> URLRequest {
        print("---setUrlRequest---")
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if needAuthorization {
            do {
                let accessToken = try SignInInfo.shared.readToken(.access)
                request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            } catch {
                print("[setUrlRequest] Error: \(error)")
            }
        }
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        headers.forEach { value in
            request.addValue(value.value, forHTTPHeaderField: value.key)
        }
        
        if let requestBody = requestBody {
            request.httpBody = requestBody
        }
        
        return request
    }
    
    static func getResponse(response: URLResponse) throws -> URLResponse {
        print("---getResponse---")
        if let response = response as? HTTPURLResponse,
           !(200..<300).contains(response.statusCode) {
            print(response)
            throw NetworkError.badRequest
        }
        return response
    }
    
    static func encodeRequestBody<RequestDTO: Codable>(requestBody: RequestDTO) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        return try encoder.encode(requestBody)
    }
    
    enum HttpMethod: String {
        case GET
        case POST
        case DELETE
        case PATCH
    }
}

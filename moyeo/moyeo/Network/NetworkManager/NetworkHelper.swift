//
//  NetworkHelper.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import Foundation

class NetworkHelper {
    
    static func setUrlComponet(path: String, queryItems: [URLQueryItem]?) throws -> URL {
        var urlComponents = APIEndpoints.getBasicUrlComponents()
        urlComponents.path = path
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
        
        guard let url = urlComponents.url else {
            print("[fetMeetingDetailTimes] Error")
            throw NetworkError.cannotCreateURL
        }
        
        return url
    }
    
    static func setUrlRequest(url: URL, httpMethod: HttpMethod, needAuthorization: Bool, headers: [String: String]) throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod.rawValue
        if needAuthorization {
            do {
                var accessToken = try SignInInfo.shared.readToken(.access)
                request.addValue("Bearer " + accessToken, forHTTPHeaderField: "Authorization")
            } catch {
                print("[setUrlRequest] Error: \(error)")
            }
        }
        headers.forEach { value in
            request.addValue(value.value, forHTTPHeaderField: value.key)
        }
        return request
    }
    
    static func getResponse(response: URLResponse) throws -> URLResponse {
        
        if let response = response as? HTTPURLResponse,
           !(200..<300).contains(response.statusCode) {
            throw NetworkError.badRequest
        }
        return response
    }
    
    enum HttpMethod: String {
        case GET
        case POST
        case DELETE
        case PATCH
    }
}

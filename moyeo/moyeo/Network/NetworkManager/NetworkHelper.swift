//
//  NetworkHelper.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import Foundation

class NetworkHelper {
    
    static func setUrlComponet(path: APIEndpoints.Path, pathVariable: String?, queryItems: [URLQueryItem]?) {
        var urlComponents = APIEndpoints.getBasicUrlComponents()
        urlComponents.path = path.rawValue
        if let queryItems = queryItems {
            urlComponents.queryItems = queryItems
        }
    }
    
    static func setUrlRequest(url: URL, httpMethod: HttpMethod.RawValue, headers: [String: String]) {
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        headers.forEach { value in
            request.addValue(value.key, forHTTPHeaderField: value.value)
        }
    }
    
    enum HttpMethod: String {
        case GET
        case POST
        case DELETE
        case PATCH
    }
}

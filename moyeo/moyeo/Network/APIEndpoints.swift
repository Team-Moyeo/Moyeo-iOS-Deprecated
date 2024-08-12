//
//  ApiEndpoints.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 7/30/24.
//

import Foundation

enum APIEndpoints {
    
    static let scheme = "https"
    static let host = Bundle.main.object(forInfoDictionaryKey: "HOST_URL") as? String
    
    enum Path: String {
        
        // MARK: - 멤버
        case signIn = "/members/sign-in"
        case resign = "/members/resign"
        case profile = "/members/profile"
        case profileUpdate = "/members/profile/update"
        case tokenRefresh = "/members/token/access-token"
        
        // MARK: - 모임
        case meetings = "/meetings"
        case meetingsJoin = "/meetings/join"
        
        // MARK: - candidate-times
        case candidateTimes = "/candidate-times"
        
        // MARK: - candidate-places
        case candidatePlaces = "/candidate-places"
        
        // MARK: - places
        case places = "/places"
        
    }
}

extension APIEndpoints {
    
    /// 기본 URL 주소 문자열을 반환합니다.
    static func basicURLString(path: APIEndpoints.Path) -> String {
        guard let host = Bundle.main
            .object(forInfoDictionaryKey: "HOST_URL") as? String
        else { return "" }
        
        return "\(scheme)://\(host)\(path.rawValue)"
    }
    
    // basicUrlComponents 생성
    static func getBasicUrlComponents() -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = APIEndpoints.scheme
        urlComponents.host = APIEndpoints.host
        return urlComponents
    }
}

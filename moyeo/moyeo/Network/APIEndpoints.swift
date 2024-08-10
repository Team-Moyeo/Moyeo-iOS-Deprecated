//
//  ApiEndpoints.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 7/30/24.
//

import Foundation

enum APIEndpoints {
    
    static let scheme = "https"
    
    enum Path: String {
        
        // MARK: - 멤버
        case signIn = "/members/sign-in"
        case signUp = "/members/sign-up"
        case profile = "/members/profile"
        case resign = "/members/resign"
        case tokenRefresh = "/members/token/access-token"
        
        // MARK: - 모임
        case meetings = "/meetings"
        
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
}

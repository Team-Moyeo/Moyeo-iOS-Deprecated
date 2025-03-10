//
//  SignInResult.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 7/31/24.
//

import Foundation
    
struct MemberAuthResponse {
    
    struct SignIn: Codable {
        let memberId: Int
        let accessToken: String
        let refreshToken: String
        var isServiced: Bool
    }
    
    struct MemberInfo: Codable {
        var profileImage: Data?
        var name: String
        var phoneNumber: String
        var email: String
    }
    
}

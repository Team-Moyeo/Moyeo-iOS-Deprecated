//
//  SignInResult.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 7/31/24.
//

import Foundation
    
struct MemberResponse {
    
    struct SignIn: Codable {
        let memberId: Int
        let accessToken: String
        let refreshToken: String
        let isServiced: Bool
    }
    
    struct MemberInfo: Codable {
        let profileImage: Data?
        let name: String?
        let phoneNumber: String?
        let email: String?
    }
    
}



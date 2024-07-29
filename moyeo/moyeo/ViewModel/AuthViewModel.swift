//
//  AuthViewModel.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 7/29/24.
//

import Foundation
import AuthenticationServices

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    
}

extension AuthViewModel {
    
    func appleLogin(request: ASAuthorizationAppleIDRequest) async {
        request.requestedScopes = [.fullName, .email]
    }
    
    func appleLoginCompletion(result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            print("Apple Login Successful")
            handleAuthorization(authorization)
        case .failure(let error):
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
    
    private func handleAuthorization(_ authorization: ASAuthorization) {
        // Apple 인증 결과 처리
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user // 사용자 식별자
            let fullName = appleIDCredential.fullName // 사용자 전체 이름
            let email = appleIDCredential.email // 사용자 이메일
            let IdentityToken = String(data: appleIDCredential.identityToken!, encoding: .utf8)
            let AuthorizationCode = String(data: appleIDCredential.authorizationCode!, encoding: .utf8)
            
            print("User ID: \(userIdentifier)")
            if let identityToken = IdentityToken {
                print("identityToken: \(identityToken)")
            }
            if let authorizationCode = AuthorizationCode {
                print("authorizationCode: \(authorizationCode)")
            }
            if let fullName = fullName {
                print("Full Name: \(fullName)")
            }
            if let email = email {
                print("Email: \(email)")
            }
        }
        
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }
}

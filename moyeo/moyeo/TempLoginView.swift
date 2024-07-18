//
//  TempLoginView.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 7/18/24.
//

import SwiftUI
import AuthenticationServices

struct TempLoginView: View {
    var body: some View {
        VStack {
            AppleSigninButton()
        }
    }
}

struct AppleSigninButton: View {
    var body: some View {
        
        SignInWithAppleButton(
            .signUp,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let authorization):
                    print("Apple Login Successful")
                    handleAuthorization(authorization)
                case .failure(let error):
                    print("Authorization failed: \(error.localizedDescription)")
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(width: 361, height: 50)
        
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
            if let fullName = fullName {
                print("Full Name: \(fullName)")
            }
            if let email = email {
                print("Email: \(email)")
            }
        }
        
    }
    
}




#Preview {
    TempLoginView()
}

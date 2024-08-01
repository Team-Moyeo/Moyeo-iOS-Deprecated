//
//  AuthViewModel.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 7/29/24.
//

import Foundation
import AuthenticationServices

@Observable
class AuthViewModel {
    var isAuthenticated: Bool = false
    
    var memberId: String?
    var accessToken: String?
    var refreshToken: String?
    var isServiceMember: Bool = false
    
}

extension AuthViewModel {
    
    func appleLogin(request: ASAuthorizationAppleIDRequest) async {
        request.requestedScopes = [.fullName, .email]
    }
    
    @MainActor
    func appleLoginCompletion(result: Result<ASAuthorization, Error>) async {
        switch result {
        case .success(let authorization):
            print("Apple Login Successful")
            await handleAuthorization(authorization)
        case .failure(let error):
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
    
    private func handleAuthorization(_ authorization: ASAuthorization) async {
        
        // Apple 인증 결과 처리
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            
            let userIdentifier = appleIDCredential.user // 사용자 식별자
            // let fullName = (appleIDCredential.fullName?.familyName ?? "") + (appleIDCredential.fullName?.givenName ?? "")
            // let email = appleIDCredential.email ?? ""
            
            // guard let identityToken = appleIDCredential.identityToken else { return }
            // let tokenString = String(data: identityToken, encoding: .utf8) ?? "" // 이메일 가리기 시 여기서 이메일 추출

            
            print("userIdentifier:\(userIdentifier)")
             
            guard let url = URL(string: APIEndpoints.basicURLString(path: .signIn)) else {
                print("Invalid URL")
                return
            }
            
            let encryptedUserIdentifier = HashHelper.hash(userIdentifier)
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(encryptedUserIdentifier, forHTTPHeaderField: "encryptedUserIdentifier")
            // request.setValue(fullName, forHTTPHeaderField: "fullName")
            // request.setValue(email, forHTTPHeaderField: "email")
            
            do {
                let (data, httpResponse) = try await URLSession.shared.data(for: request)
                
                if let httpResponse = httpResponse as? HTTPURLResponse,
                   !(200..<300).contains(httpResponse.statusCode) {
                    print("Error: badRequest")
                }
                
                let response = try JSONDecoder().decode(BaseResponse<MemberResponse.SignIn>.self, from: data)
                print("MemberResponse:SignIn: \(String(describing: response.result))")
                
                if response.code == "COMMON200" {
                    self.memberId = response.result?.memberId
                    self.accessToken = response.result?.accessToken
                    self.refreshToken = response.result?.refreshToken
                    self.isServiceMember = response.result?.isServiceMember ?? false
                }
                
                print("\(String(describing: self.memberId))")
                print("\(String(describing: self.accessToken))")
                print("\(String(describing: self.refreshToken))")
                print("\(self.isServiceMember)")
                
                
                if let signInResponse = response.result {
                    
                    try SignInInfo.shared.addToken(.access, token: signInResponse.accessToken)
                    try SignInInfo.shared.addToken(.refresh, token: signInResponse.refreshToken)
                    
                    if signInResponse.isServiceMember {
                        print("로그인 성공")
                        self.isAuthenticated = true
                    } else {
                        // 이때 정보 기입 뷰 뜨면서 프로필 사진, 이름, 이메일 기입?
                        print("첫 로그인")
                        self.isAuthenticated = true
                    }
                    
                    print("accessToken: \(try SignInInfo.shared.readToken(.access))")
                    print("refreshToken: \(try SignInInfo.shared.readToken(.refresh))")
                    
                }
                
            } catch {
                
            }
            
            
        default:
            break
        }
    }
}

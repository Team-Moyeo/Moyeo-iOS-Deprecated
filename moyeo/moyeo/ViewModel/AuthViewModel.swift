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
    
    @Published var memberId: String?
    @Published var accessToken: String?
    @Published var refreshToken: String?
    @Published var isServiceMember: Bool = false
    
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
            // guard let authorizationCode = appleIDCredential.authorizationCode else { return }
            
            // let tokenString = String(data: identityToken, encoding: .utf8) ?? "" // 이메일 가리기 시 여기서 이메일 추출
            // let authCodeString = String(data: authorizationCode, encoding: .utf8)
            
            print("userIdentifier:\(userIdentifier)")
             
            guard let url = URL(string: APIEndpoints.basicURLString(path: .signIn)) else {
                print("Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue(userIdentifier, forHTTPHeaderField: "userIdentifier")
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
                
                
                
                
                
            } catch {
                
            }
            
            
        default:
            break
        }
        
        
        DispatchQueue.main.async {
            self.isAuthenticated = true
        }
    }
}

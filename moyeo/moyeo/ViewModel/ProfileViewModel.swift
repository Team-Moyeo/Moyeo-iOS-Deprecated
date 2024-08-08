//
//  ProfileViewModel.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/5/24.
//

import Foundation

@Observable
class ProfileViewModel {
    var profileInfo: MemberResponse.MemberInfo
    
    init() {
        self.profileInfo = .init(profileImage: nil, name: nil, phoneNumber: nil, email: nil)
    }
        
}

extension ProfileViewModel {
    
    @MainActor
    func requestProfileInfo() async {
        do {
            self.profileInfo = try await requestProfile()
        } catch {
            print("프로필 정보 로드 실패")
        }
        
    }
    
    private func requestProfile() async throws -> MemberResponse.MemberInfo {
        
        // URL 객체 생성
        guard let url = URL(string: APIEndpoints.basicURLString(path: .profile)) else {
            print("Error: cannotCreateURL")
            throw NetworkError.cannotCreateURL
        }
        
        let accessToken = try SignInInfo.shared.readToken(.access)
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = httpResponse as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            print("Error: \(httpResponse.statusCode) badRequest")
            throw NetworkError.badRequest
        }
        
        let response = try JSONDecoder().decode(BaseResponse<MemberResponse.MemberInfo>.self, from: data)
        
        guard let memberInfoResponse = response.result else {
            print("Error: No MemberInfo Response")
            throw NetworkError.decodeFailed
        }
     
        return memberInfoResponse
        
    }
}

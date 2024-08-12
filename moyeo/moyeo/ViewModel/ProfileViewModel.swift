//
//  ProfileViewModel.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/5/24.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var profileInfo: MemberAuthResponse.MemberInfo
    @Published var editProfileMode: Bool = false
    
    init() {
        self.profileInfo = .init(profileImage: nil, name: "", phoneNumber: "", email: "")
    }
    
}

extension ProfileViewModel {
    
    @MainActor
    func loadProfileInfo() async {
        do {
            self.profileInfo = try await fetchProfileInfo()
        } catch {
            print("프로필 정보 로드 실패: \(error)")
        }
        
    }
    
    @MainActor
    func saveProfileChanges() async {
        do {
            print(profileInfo)
            try await updateProfileInfo(with: profileInfo)
            self.editProfileMode = false
        } catch {
            print("프로필 정보 저장 실패: \(error)")
        }
    }
    
    
    func toggleEditMode(cancelChanges: Bool) {
        if cancelChanges {
            Task {
                await loadProfileInfo()
            }
        }
        self.editProfileMode.toggle()
    }
    
    
    private func fetchProfileInfo() async throws -> MemberAuthResponse.MemberInfo {
        
        // URL 객체 생성
        guard let url = URL(string: APIEndpoints.basicURLString(path: .profile)) else {
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
        
        let response = try JSONDecoder().decode(BaseResponse<MemberAuthResponse.MemberInfo>.self, from: data)
        
        guard let responseResult = response.result else {
            print("Error: No MemberInfo Response")
            throw NetworkError.decodeFailed
        }
        
        var memberInfoResponse = responseResult
        
        if memberInfoResponse.name.isEmpty {
            memberInfoResponse.name = "미등록"
        }
        if memberInfoResponse.phoneNumber.isEmpty {
            memberInfoResponse.phoneNumber = "미등록"
        }
        if memberInfoResponse.email.isEmpty {
            memberInfoResponse.email = "미등록"
        }
        
        if let profileImage = memberInfoResponse.profileImage {
            print("프로필이미지 From 서버: \(String(describing: String(data: profileImage, encoding: .utf8)))")
        } else {
            print("프로필이미지 From 서버: 미등록")
        }
        print("프로필이름 From 서버: \(String(describing: memberInfoResponse.name))")
        print("프로필전화번호 From 서버: \(String(describing: memberInfoResponse.phoneNumber))")
        print("프로필이메일 From 서버: \(String(describing: memberInfoResponse.email))")
        
        return memberInfoResponse
        
    }
    
    private func updateProfileInfo(with editedInfo: MemberAuthResponse.MemberInfo) async throws {
        guard let url = URL(string: APIEndpoints.basicURLString(path: .profileUpdate)) else {
            throw NetworkError.cannotCreateURL
        }
        
        let accessToken = try SignInInfo.shared.readToken(.access)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: String] = [
            "name": editedInfo.name,
            "phoneNumber": editedInfo.phoneNumber,
            "email": editedInfo.email
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        
        let (data, httpResponse) = try await URLSession.shared.data(for: request)
        
        if let httpResponse = httpResponse as? HTTPURLResponse,
           !(200..<300).contains(httpResponse.statusCode) {
            print("Error: \(httpResponse.statusCode) badRequest")
            throw NetworkError.badRequest
        }
        
        print("프로필 정보 업데이트 성공: \(String(data: data, encoding: .utf8) ?? "")")
    }
    
}

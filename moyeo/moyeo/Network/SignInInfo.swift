//
//  SignInInfo.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/1/24.
//

import Foundation
import Security

final class SignInInfo {
    
    /// 키체인 에러 열거형
    enum KeyChainError: Error {
        case notFound // 키체인 찾을 수 없음
        case unexpectedData // 예상치 못한 데이터
        case unHandledError(status: OSStatus) // 예외 처리에 실패한 에러
    }
    
    /// 토큰 타입 열거형
    enum TokenType: String {
        case access = "accessToken"
        case refresh = "refreshToken"
    }
    
    static let shared = SignInInfo()
    private init() {}
    
    private var refreshTokenValue: String = ""
    
    /// 키체인에서 액세스 토큰을 반환합니다.
    func readToken(_ type: TokenType) throws -> String {
        
        // 1. 키체인에서 검색할 쿼리
        let readQuery: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrType: type.rawValue,
            kSecReturnAttributes: true,
            kSecReturnData: true
        ]
        
        // 2. 검색 결과를 담을 변수 생성
        var result: CFTypeRef?
        
        // 3. 키체인에 쿼리를 이용한 검색 및 반환
        let status = SecItemCopyMatching(readQuery as CFDictionary, &result)
        
        // 4. 검색 결과가 잘 들어왔는지 확인
        guard status != errSecItemNotFound else {
            print("키체인 검색 결과 없음")
            throw KeyChainError.notFound
        }
        
        guard status == errSecSuccess else {
            print("키체인 검색 실패")
            throw KeyChainError.unHandledError(status: status)
        }
        
        // 5. 검색 결과를 딕셔너리로 변환
        guard let existingItem = result as? [String: Any],
              let tokenData = existingItem[kSecValueData as String] as? Data,
              let token = String(data: tokenData, encoding: .utf8)
        else {
            print("예상치 못한 데이터 반환")
            throw KeyChainError.unexpectedData
        }
        
        // 6. 최종 토큰 반환
        return token
    }
    
    /// 키체인에 토큰을 추가합니다.
    func addToken(_ type: TokenType, token: String) throws {
        
        // 1. 토큰 문자열을 Data로 변환
        let tokenData = token.data(using: .utf8)!
        
        // 2. 키체인 생성용 쿼리
        let addQuery: [CFString: Any] = [
            kSecClass: kSecClassKey, // 키체인 item 클래스: kSecClassKey
            kSecAttrType: type.rawValue, // 키체인 검색용 attribute: 토큰 라벨 access인지 refresh인지
            kSecValueData: tokenData // 암호화가 필요한 키체인 item(토큰)
        ]
        
        // 3. 키체인에 쿼리를 이용해 추가
        let status = SecItemAdd(addQuery as CFDictionary, nil)
        
        // 4. 키체인 추가가 잘 되었는지 확인
        if status == errSecSuccess {
            print("키체인 생성 성공")
        } else if status == errSecDuplicateItem {
            // 4-1. 만약 이미 존재한다면, 기존 키체인 item 업데이트
            print("키체인 업데이트 시작")
            try updateToken(type, value: tokenData)
            
        } else {
            print("키체인 생성 실패")
            throw KeyChainError.unHandledError(status: status)
        }
    }
    
    /// 키체인 내 토큰을 업데이트합니다.
    func updateToken(_ type: TokenType, value: Data) throws {
        
        // 1. 기존 키체인을 찾기 위한 쿼리
        let originalQuery: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrType: type.rawValue
        ]
        
        // 2. 업데이트할 데이터를 담고 있는 쿼리
        let updateQuery: [CFString: Any] = [
            kSecValueData: value
        ]
        
        // 3. 키체인에 쿼리를 이용해 업데이트
        let status = SecItemUpdate(originalQuery as CFDictionary, updateQuery as CFDictionary)
        
        // 4. 키체인 업데이트가 잘 되었는지 확인
        if status == errSecSuccess {
            print("키체인 업데이트 성공")
        } else {
            print("키체인 업데이트 실패")
            throw KeyChainError.unHandledError(status: status)
        }
        
    }
    
    /// 키체인 내 토큰을 삭제합니다.
    func deleteToken(_ type: TokenType) throws {
        
        let deleteQuery: [CFString: Any] = [
            kSecClass: kSecClassKey,
            kSecAttrType: type.rawValue
        ]
        
        let status = SecItemDelete(deleteQuery as CFDictionary)
        
        if status == errSecSuccess {
            print("키체인 삭제 성공")
        } else if status == errSecItemNotFound {
            print("키체인에서 토큰 못찾음")
            throw KeyChainError.notFound
        } else {
            print("키체인 삭제 실패")
            throw KeyChainError.unHandledError(status: status)
        }
        
        
    }
    
    
}

//
//  Helper+Encryption.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/1/24.
//

import Foundation
import CryptoKit

class HashHelper {
    static func hash(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

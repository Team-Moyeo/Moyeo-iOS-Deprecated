//
//  NetworkError.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/8/24.
//

import Foundation

enum NetworkError: Error {
    case badRequest
    case decodeFailed
    case cannotCreateURL
}

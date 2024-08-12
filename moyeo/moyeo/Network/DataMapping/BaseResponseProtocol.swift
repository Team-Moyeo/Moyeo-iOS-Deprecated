//
//  BaseResponseProtocol.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import Foundation

protocol BaseResponseProtocol: Codable {
    var timestamp: String { get }
    var code: String { get }
    var message: String { get }
    associatedtype ResultType: Codable
    var result: ResultType { get }
}

//
//  BaseResponse.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 7/31/24.
//

import Foundation

struct BaseResponse<ResultType: Codable>: Codable {
    let timeStamp: String
    let code: String
    let message: String
    let result: ResultType?
}

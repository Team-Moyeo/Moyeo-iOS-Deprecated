//
//  MemberResponse.swift
//  moyeo
//
//  Created by kyungsoolee on 8/13/24.
//

import Foundation

class MemberResponse {
    struct GetMembersByMeeting: Codable {
        var memberInfos: [MemberInfo] = []
        
        struct MemberInfo: Codable {
            var name: String = ""
            var avatar: String = ""
        }
    }
    

}

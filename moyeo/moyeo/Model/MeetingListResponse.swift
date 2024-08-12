//
//  MeetingListResponse.swift
//  moyeo
//
//  Created by Woowon Kang on 8/5/24.
//

import Foundation

struct MeetingListResponse: Codable {
    
    struct MeetingStatus: Codable, Hashable {
        let meetingId: Int
        let title: String
        let deadline: String
        let meetingStatus: String
        
        // 날짜 포맷을 변경 해줍니다.
        var formattedDeadline: String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            guard let date = dateFormatter.date(from: deadline) else {
                return deadline
            }
            
            // 원하는 출력 형식
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = "yy. MM. dd"
            return outputFormatter.string(from: date)
        }
    }
    
    let meetingList: [MeetingStatus]
}

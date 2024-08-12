//
//  NetworkManagerTestView.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import SwiftUI

struct NetworkManagerTestView: View {
    @ObservedObject var candidateTimeNetworkManager = CandidateTimeNetworkManager()
    @State private var fetchGetMeetingDetailTimesMeetingId: String = ""
    
    var body: some View {
        VStack {
            AppleSigninButton()
            
            Divider()
            Button {
                if let intMeetingId = Int(fetchGetMeetingDetailTimesMeetingId) {
                    Task {
                        print(await candidateTimeNetworkManager.fetchGetMeetingDetailTimes(request: CandidateTimeRequest.GetMeetingDetailTimes(meetingId: intMeetingId)))
                    }
                }
            } label: {
                Text("fetchGetMeetingDetailTimesMeetingId")
            }
            TextField("수정할 투두리스트 아이디를 입력하세요.", text: $fetchGetMeetingDetailTimesMeetingId)
            Divider()
        }

    }
}

#Preview {
    NetworkManagerTestView()
}

//
//  GroupVoteView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/26/24.
//

import SwiftUI

struct GroupVoteView: View {
    
    @EnvironmentObject var appViewModel: AppViewModel
    @ObservedObject var sharedDm : SharedDateModel
    @State private var isPresentingMemberPopupView = false
    @State private var isPresentingMapWideView = false
    @State private var isPresentingGroupConfirmView = false
    @State private var isShowingTimeTable = false
  
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                
                TimeTableView(sharedDm : sharedDm)
                
                Button(action: {
                    // 사용자의 역할(role)에 따라 '설정 아이콘' 또는 '초대하기 버튼'
                }) {
                    Text("설정")
                }
                
                Button(action: {
                    // MemberPopupView가 뜬다
                    isPresentingMemberPopupView.toggle()
                }) {
                    Text("프로필")
                }
                .sheet(isPresented: $isPresentingMemberPopupView) {
                    MemberPopupView()
                }
                .padding()
                
                Button(action: {
                    // MapWideView Sheet가 올라온다
                    isPresentingMapWideView.toggle()
                }) {
                    Text("지도")
                }
                .sheet(isPresented: $isPresentingMapWideView) {
                    MapWideView()
                }
                .padding()
                
                
                
                
                
                
                //MARK: - 그룹장
                Button(action: {
                    // GroupConfirmView Sheet가 올라온다
                    isPresentingGroupConfirmView.toggle()
                }) {
                    Text("투표 마감하기")
                    
                    // 그룹장은 "투표 다시하기", "투표 마감하기"로 나뉘어짐
                }
                .sheet(isPresented: $isPresentingGroupConfirmView) {
                    GroupConfirmView(isPresentingGroupConfirmView: $isPresentingGroupConfirmView)
                        .environmentObject(appViewModel)
                }
                .padding()
                
                //MARK: - 그룹원
                Button(action: {
                    
                }) {
                    Text("투표 완료하기")
                    // 누르면 "투표 다시하기"
                    
                }
                .padding()
            }
        }
    }
}

//#Preview {
//
//        let sharedDm = SharedDateModel()
//        sharedDm.meetingName = "Sample Meeting"
//        sharedDm.voteTime = true
//        sharedDm.startDate = Date()
//        sharedDm.endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
//        sharedDm.selectedDate = Date()
//        sharedDm.selectedTime = Date()
//        
//         GroupVoteView()
//    
//}

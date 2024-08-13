//
//  GroupVoteView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/26/24.
//

import SwiftUI

struct GroupVoteView: View {
    
    @Environment(AppViewModel.self) var appViewModel
    @ObservedObject var createMeetingViewModel : CreateMeetingViewModel
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
                        .environment(appViewModel)
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
        .onAppear {
            sharedDm.meetingName = createMeetingViewModel.title
            sharedDm.meetingId = createMeetingViewModel.meetingId
            
            sharedDm.startDate = Calendar.current.startOfDay(for: createMeetingViewModel.startDate)
            if let endDate = timeFixToMidNight(date: createMeetingViewModel.endDate) {
                sharedDm.endDate = endDate
            }
            
            if let numberOfDays =  daysBetween(start: timeFixToZero(date: createMeetingViewModel.startDate)! , end: timeFixToMidNight(date: createMeetingViewModel.endDate)! ) {
                sharedDm.numberOfDays = numberOfDays
            } else {
                sharedDm.numberOfDays = 7
            }
            
            print("createMeetingViewModel.meetingId☠️\(createMeetingViewModel.meetingId)")
            print("sharedDm.meetingId☠️\(sharedDm.meetingId)")
            
            sharedDm.places = createMeetingViewModel.places
            sharedDm.deadLine = createMeetingViewModel.deadline
            
        }
    }
}

extension String {
    func toDate() -> Date? { //"yyyy-MM-dd HH:mm:ss"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            return nil
        }
    }

}





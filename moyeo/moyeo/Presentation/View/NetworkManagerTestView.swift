//
//  NetworkManagerTestView.swift
//  moyeo
//
//  Created by kyungsoolee on 8/12/24.
//

import SwiftUI

struct NetworkManagerTestView: View {
    @ObservedObject var candidateTimeNetworkManager = CandidateTimeNetworkManager()
    @ObservedObject var candidatePlaceNetworkManager = CandidatePlaceNetworkManager()
    @ObservedObject var placeNetworkManager = PlaceNetworkManager()
    @ObservedObject var meetingNetworkManager = MeetingNetworkManager()
    @State private var getMeetingDetailTimesMeetingId: String = ""
    @State private var getMeetingDetailPlacesMeetingId: String = ""
    @State private var createPlaceTitle: String = ""
    @State private var createPlaceAddress: String = ""
    @State private var createPlaceLatitude: String = ""
    @State private var createPlaceLongitude: String = ""
    @State private var addCandidatePlaceMeetingId: String = ""
    @State private var addCandidatePlacePlaceId: String = ""
    @State private var deleteCandidatePlaceMeetingId: String = ""
    @State private var deleteCandidatePlaceId: String = ""
    @State private var deleteMeetingId: String = ""
    @State private var joinMeetingInviteCode: String = ""
    @State private var getInviteCodeMeetingId: String = ""
    @State private var getMeetingDetailMeetingId: String = ""
    
    
    
    
    var body: some View {
        VStack {
            AppleSigninButton()
            
            Divider()
            
            // MARK: - 모임 상세 조회(시간)
            Button {
                if let intMeetingId = Int(getMeetingDetailTimesMeetingId) {
                    Task {
                        print(await candidateTimeNetworkManager.fetchGetMeetingDetailTimes(meetingId: intMeetingId))
                    }
                }
            } label: {
                Text("getMeetingDetailTimes")
            }
            TextField("조회할 모임 아이디를 입력하세요.", text: $getMeetingDetailTimesMeetingId)
            Divider()
            
            // MARK: - 모임 상세 조회(장소)
            Button {
                if let intMeetingId = Int(getMeetingDetailPlacesMeetingId) {
                    Task {
                        print(await candidatePlaceNetworkManager.fetchGetMeetingDetailPlaces(meetingId: intMeetingId))
                    }
                }
            } label: {
                Text("getMeetingDetailPlaces")
            }
            TextField("조회할 모임 아이디를 입력하세요.", text: $getMeetingDetailPlacesMeetingId)
            Divider()
            
            // MARK: - 장소 등록
            Button {
                if let doubleLatitude = Double(createPlaceLatitude)
                    , let doubleLongitude = Double(createPlaceLongitude) {
                    Task {
                        print(await placeNetworkManager.fetchCreatePlace(request: PlaceRequest.PlaceCreate(title: createPlaceTitle, address: createPlaceAddress, latitude: doubleLatitude, longitude: doubleLongitude)))
                    }
                }
            } label: {
                Text("createPlace")
            }
            TextField("등록할 장소 타이틀을 입력하세요.", text: $createPlaceTitle)
            TextField("등록할 장소 주소 입력하세요.", text: $createPlaceAddress)
            TextField("등록할 장소 위도 입력하세요.", text: $createPlaceLatitude)
            TextField("등록할 장소 경도 입력하세요.", text: $createPlaceLongitude)
            Divider()
            
            // MARK: - 후보 장소 삭제
            Button {
                if let meetingId = Int(addCandidatePlaceMeetingId)
                    , let placeId = Int(addCandidatePlacePlaceId) {
                    Task {
                        print(await candidatePlaceNetworkManager.fetchAddCandidatePlace(meetingId: meetingId, placeId: placeId))
                    }
                }
            } label: {
                Text("addCandidatePlace")
            }
            TextField("등록할 모임 아이디를 입력하세요.", text: $addCandidatePlaceMeetingId)
            TextField("등록할 장소 아이디를 입력하세요.", text: $addCandidatePlacePlaceId)
            Divider()
            
            // MARK: - 후보 장소 삭제
            Button {
                if let meetingId = Int(deleteCandidatePlaceMeetingId)
                    , let candidatePlaceId = Int(deleteCandidatePlaceId) {
                    Task {
                        print(await candidatePlaceNetworkManager.fetchDeleteCandidatePlace(meetingId: meetingId, candidatePlaceId: candidatePlaceId))
                    }
                }
            } label: {
                Text("DeleteCandidatePlace")
            }
            TextField("삭제할 모임 아이디를 입력하세요.", text: $deleteCandidatePlaceMeetingId)
            TextField("삭제할 후보 장소 아이디를 입력하세요.", text: $deleteCandidatePlaceId)
            Divider()
            
            // MARK: - 모임 삭제
            Button {
                if let meetingId = Int(deleteMeetingId) {
                    Task {
                        print(await meetingNetworkManager.fetchDeleteMeeting(meetingId: meetingId, candidatePlaceId: meetingId))
                    }
                }
            } label: {
                Text("DeleteMeeting")
            }
            TextField("삭제할 모임 아이디를 입력하세요.", text: $deleteMeetingId)
            Divider()
            
            // MARK: - 모임 가입
            Button {
                Task {
                    print(await meetingNetworkManager.fetchJoinMeetingWithInviteCode(inviteCode: joinMeetingInviteCode))
                }
            } label: {
                Text("JoinMeeting")
            }
            TextField("가입할 모임의 초대코드를 입력하세요.", text: $joinMeetingInviteCode)
            Divider()
            
            // MARK: - 모임 초대코드 조회
            Button {
                    if let meetingId = Int(getInviteCodeMeetingId) {
                        Task {
                            print(await meetingNetworkManager.fetchGetInviteCode(meetingId: meetingId))
                        }
                    }
                } label: {
                    Text("getInviteCode")
                }
                TextField("초대코드를 조회할 모임의 아이디를 입력하세요.", text: $getInviteCodeMeetingId)
                Divider()
                
            }
        // MARK: - 모임 상세 조회
        Button {
            if let meetingId = Int(getMeetingDetailMeetingId) {
                Task {
                    print(await meetingNetworkManager.fetchGetMeetingDetail(meetingId: meetingId))
                }
            }
        } label: {
            Text("getMeetingDetail")
        }
        TextField("조회할 모임 아이디를 입력하세요.", text: $getMeetingDetailMeetingId)
        Divider()
            
        }
    }
    
    #Preview {
        NetworkManagerTestView()
    }

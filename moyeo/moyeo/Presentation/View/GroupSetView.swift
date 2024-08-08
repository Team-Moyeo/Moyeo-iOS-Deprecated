//
//  GroupSetView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/26/24.
//

import SwiftUI

struct GroupSetView: View {
    @Environment(AppViewModel.self) var appViewModel
    @State private var meetingName: String = ""
    @State private var voteTime: Bool = false
    @State private var votePlace: Bool = false
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    
    @Binding var isPresentingGroupSetView: Bool
    
    @State var placeViewModel: PlaceViewModel = PlaceViewModel(meetingId: "12345", memberId: "54321")
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("모임명")
                    TextField("모임 이름을 입력해주세요.", text: $meetingName)
                }
            }
            
            Section {
                HStack {
                    Toggle(isOn: $voteTime) {
                        Text("시간 투표")
                    }
                }
            }
            
            Section {
                HStack {
                    Toggle(isOn: $votePlace) {
                        Text("장소 투표")
                    }
                }
                
                HStack {
                    Text("장소")
                    Spacer()
                    
                    Button(action: {
                        placeViewModel.isPresentingPlaceSearchView.toggle()
                    }) {
                        Text("장소를 선택해주세요.")
                            .foregroundColor(.gray)
                    }
                    .sheet(isPresented: $placeViewModel.isPresentingPlaceSearchView) {
                        NavigationStack {
                            PlaceSearchView()
                                .environment(placeViewModel)
                        }
                        
                    }
                    
                }
            }
            
            Section {
                HStack {
                    Text("투표 마감")
                    Spacer()
                    
                    DatePicker("날짜", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                    
                    DatePicker("시간", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                }
            }
            
        }
        .overlay {
            VStack {
                Spacer()
                
                Button(action: {
                    appViewModel.navigateTo(.groupVoteView)
                    isPresentingGroupSetView = false
                    
                }) {
                    Text("모임 시작하기")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(8)
                }
                .frame(width: 360, height: 50)
                .background(Color.black)
                .cornerRadius(10)
            }
            
        }
    }
}

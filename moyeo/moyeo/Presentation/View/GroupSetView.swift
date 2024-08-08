//
//  GroupSetView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/26/24.
//

import SwiftUI

struct GroupSetView: View {
    @Environment(AppViewModel.self) var appViewModel
    @State private var meetingName: String = "우리지금만나~"
    @State private var voteTime: Bool = false
    @State private var votePlace: Bool = false
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    
    @State private var selectedStartDate = Date()
    @State private var selectedEndDate = Date()
    
    @State private var isPresentingPlaceSearchView = false
    @Binding var isPresentingGroupSetView: Bool
    
    @ObservedObject var sharedDm  : SharedDateModel
   
    
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
                        // PlaceSearchView Sheet로 넘어가기
                        isPresentingPlaceSearchView.toggle()
                    }) {
                        Text("장소를 선택해주세요.")
                            .foregroundColor(.gray)
                    }
                    .sheet(isPresented: $isPresentingPlaceSearchView) {
                        PlaceSearchView()
                    }

                }
            }
            
            Section {
                HStack {
                    Text("시작투표일")
                    Spacer()
                    
                    DatePicker("날짜", selection: $selectedStartDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        .onChange(of: selectedStartDate) { newStartDate,_ in
                            if selectedEndDate < selectedStartDate {
                                selectedEndDate = selectedStartDate
                            }
                            if let maxEndDate = Calendar.current.date(byAdding: .day, value: 6, to: newStartDate), selectedEndDate > maxEndDate {
                                selectedEndDate = maxEndDate
                            }
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.year, .month, .day], from: newStartDate)
                            if let year = components.year, let month = components.month, let day = components.day {
                                print("Year: \(year), Month: \(month), Day: \(day)")
                            }
                        }
                }
                
                HStack{
                    Text("종료투표일")
                    Spacer()
                    
                    DatePicker("날짜", selection: $selectedEndDate, displayedComponents: .date)
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                        .onChange(of: selectedEndDate) { newEndDate in
                            // If the new end date exceeds 7 days from the start date, adjust it
                           if newEndDate < selectedStartDate {
                                selectedEndDate = selectedStartDate
                            } else if let maxEndDate = Calendar.current.date(byAdding: .day, value: 6, to: selectedStartDate), newEndDate > maxEndDate {
                                selectedEndDate = maxEndDate
                            }
                            let calendar = Calendar.current
                                   let components = calendar.dateComponents([.year, .month, .day], from: selectedEndDate)
                                   if let year = components.year, let month = components.month, let day = components.day {
                                       print("Year: \(year), Month: \(month), Day: \(day)")
                                   }
                        }
                    
                }
                
                HStack {
                    Text("투표 마감")
                    Spacer()
                    
                    DatePicker("날짜", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(CompactDatePickerStyle())
                        .labelsHidden()
                    
//                    DatePicker("시간", selection: $selectedTime, displayedComponents: .hourAndMinute)
//                        .datePickerStyle(CompactDatePickerStyle())
//                        .labelsHidden()
                }
            }
            
        }
        .overlay {
            VStack {
                Spacer()
                
                Button(action: {
                    // GroupVoteView로 넘어가기
                    // 시간, 장소 둘 중 하나라도 활성화 되어야 해당 버튼 활성화
                    // 해당 sheet가 내려가고, MainView의 List에 추가되고,
                    // NavigationStack에 쌓기
                    Task {
                        await post_meeting()
                    }
                    sharedDm.isUpdating = true
                    sharedDm.meetingName = meetingName
                    sharedDm.voteTime = voteTime
                    sharedDm.endDate = selectedEndDate
                    sharedDm.selectedDate = selectedDate
                    sharedDm.selectedTime = selectedTime
                    if let numberOfDays =  daysBetween(start: TimeFixToZero(date: selectedStartDate)! , end: TimeFixToMidNight(date: selectedEndDate)! ) {
                        sharedDm.numberOfDays = numberOfDays
                    } else {
                        
                        sharedDm.numberOfDays = 7
                    }
                    // 순서가 중요해~~ startDate이 다른 이벤트를 트리거 할수있어서..,
                    sharedDm.startDate = selectedStartDate
                    
                    sharedDm.isUpdating = false
                    
                    print("GroupSetView \(sharedDm.meetingName) s:\(sharedDm.startDate) e:\(sharedDm.endDate) n: \(sharedDm.numberOfDays)")
              
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
func post_meeting()  async {
    
    var apiService = APIService<Meeting>()
    guard let url = URL(string: APIEndpoints.basicURLString(path: .meeting)) else {
        print("Invalid URL")
        return
    }
    print("url :  \(url)")
   let accessToken = "eyJhbGciOiJIUzUxMiJ9.eyJ0b2tlblR5cGUiOiJhY2Nlc3MiLCJtZW1iZXJJZCI6MiwiY2xpZW50SWQiOiI3NTcyMDdhMmU1MDgzZmY2NWU2ZTU4ZjhmYWY1OGE0YWU4ZWRiYmY4MDM0YzEzM2NhYTI1ZmJkZDFhZDA5ODFmIiwicGVybWlzc2lvblJvbGUiOiJBRE1JTiIsImlhdCI6MTcyMzEyMjM4OCwiZXhwIjoxNzIzOTg2Mzg4fQ.RLAKFQHU0VYxCOvi20Q4jQryn_-KCE9-W_HWp_c6CgqMMuWbzPpaUoiDJXxJh0zxsdRaX0m13-l8pk8MRscifg"
    
    
    var request = URLRequest(url: url)
  
   
    let headers = [
        "Content-Type": "application/json",
        "Authorization": "Bearer \(accessToken)",
    ]
    

    let meeting = Meeting(
        title: "Andy's Team Meeting",
        startDate: "2024-08-25",
        endDate: "2024-08-31",
        startTime: "09:00:00",
        endTime: "17:00:00",
        fixedTimes: ["2024-08-10T10:00:00", "2024-08-10T10:30:00"],
        fixedPlace: Place(
            title: "포항공대 생활관",
            address: "경북 포항시 남구 청암로 포항공과대학교",
            latitude: 35.3528,
            longitude: 129.3135
        ),
        candidatePlaces: [
            Place(
                title: "Conference Room B",
                address: "456 Secondary Street, Cityville",
                latitude:35.3528,
                longitude:129.3135
            )
        ],
        deadline: "2024-08-09T23:59:59"
    )

    // JSON 인코더 생성
    let encoder = JSONEncoder()

    do {
        // JSON 데이터로 인코딩
        let jsonData = try encoder.encode(meeting)
        request.httpBody = jsonData
        print("jsonData \(jsonData)")
        // JSON 데이터 문자열로 변환 (디버깅 용)
        if let jsonString = String(data: jsonData, encoding: .utf8) {
            print("JSON String: \(jsonString)")
        }
    }
    catch {
        print(error)
    }
  
    request.allHTTPHeaderFields = headers
    request.httpMethod = "POST"
    
    do {
        let  decoded = try  await apiService.asyncLoad(for: request)
        print("decoded in the post_meeting \(decoded)")
    } catch{
        print("decoding error \(error)")
    }
  
}

//#Preview {
//    // 임시 상태 및 뷰 모델 설정
//    @StateObject var appViewModel = AppViewModel()
//    @StateObject var sharedDm = SharedDateModel()
//    @State var isPresentingGroupSetView = true
//    
//    return GroupSetView(isPresentingGroupSetView: $isPresentingGroupSetView, sharedDm: sharedDm)
//        .environmentObject(appViewModel)
//}

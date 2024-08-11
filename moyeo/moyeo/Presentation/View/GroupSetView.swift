//
//  GroupSetView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/26/24.
//

import SwiftUI

struct GroupSetView: View {
    @Environment(AppViewModel.self) var appViewModel
    @EnvironmentObject var createMeetingViewModel : CreateMeetingViewModel
    
    @State private var meetingName: String = ""
    @State private var voteTime: Bool = false
    @State private var votePlace: Bool = false
    
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    @State var placeViewModel: PlaceViewModel = PlaceViewModel(meetingId: "12345", memberId: "54321")
    
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var startTime = Date()
    @State private var endTime = Date()
    @State private var deadLine = Date()
    
    @Binding var isPresentingGroupSetView: Bool
    
    @State private var isTextFieldActive: Bool = false
    
    //    @ObservedObject var sharedDm : SharedDateModel
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    HStack {
                        Text("모임명")
                            .padding(.trailing, 50)
                        TextField("모임 이름을 입력해주세요.", text: $meetingName, onEditingChanged: { isEditing in
                            isTextFieldActive = isEditing
                        })
                        .onAppear {
                            UITextField.appearance().clearButtonMode = .whileEditing
                        }
                    }
                }
            header: {
                Text("\n")
            }
                
                Section {
                    HStack {
                        Toggle(isOn: $voteTime) {
                            Text("시간 투표")
                        }
                    }
                    if voteTime {
                        Section {
                            HStack {
                                Text("시작 투표일")
                                Spacer()
                                
                                DatePicker("날짜", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .onChange(of: startDate) { newStartDate,_ in
                                        if endDate < startDate {
                                            endDate = startDate
                                        }
                                        if let maxEndDate = Calendar.current.date(byAdding: .day, value: 6, to: newStartDate), endDate > maxEndDate {
                                            endDate = maxEndDate
                                        }
                                        let calendar = Calendar.current
                                        let components = calendar.dateComponents([.year, .month, .day], from: newStartDate)
                                        if let year = components.year, let month = components.month, let day = components.day {
                                            print("Year: \(year), Month: \(month), Day: \(day)")
                                        }
                                    }
                            }
                            
                            HStack{
                                Text("종료 투표일")
                                Spacer()
                                
                                DatePicker("날짜", selection: $endDate, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                                    .labelsHidden()
                                    .onChange(of: endDate) { newEndDate in
                                        // If the new end date exceeds 7 days from the start date, adjust it
                                        if endDate < startDate {
                                            endDate = startDate
                                        } else if let maxEndDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate), newEndDate > maxEndDate {
                                            endDate = maxEndDate
                                        }
                                        let calendar = Calendar.current
                                        let components = calendar.dateComponents([.year, .month, .day], from: endDate)
                                        if let year = components.year, let month = components.month, let day = components.day {
                                            print("Year: \(year), Month: \(month), Day: \(day)")
                                        }
                                    }
                            }
                            
                            Section {
                                HStack {
                                    Text("시간 범위")
                                    Spacer()
                                    DatePicker("", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .frame(maxWidth: 100)
                                    Text("~")
                                    DatePicker("", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .labelsHidden()
                                        .frame(maxWidth: 100)
                                }
                            }
                        }
                    } else {
                        DatePicker("날짜", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                    }
                }
                
                Section {
                    HStack {
                        Toggle(isOn: $votePlace) {
                            Text("장소 투표")
                        }
                    }
                    
                    if votePlace {
                        // 새로운 장소가 추가되면 해당 섹션에 리스트 형태로 장소가 들어간다
                        List {
                            ForEach(createMeetingViewModel.places) { place in
                                Text("\(place.name)")
                            }
                            Button(action: {
                                placeViewModel.isPresentingPlaceSearchView.toggle()
                            }, label: {
                                HStack {
                                    Image(systemName: "plus")
                                    Text("새로운 장소")
                                    Spacer()
                                }
                                .foregroundStyle(.myDD8686)
                                
                            })
                        }
                        
                        
                    } else {
                        HStack {
                            Text("장소")
                            Spacer()
                            
                            Button(action: {
                                placeViewModel.isPresentingPlaceSearchView.toggle()
                            }) {
                                if createMeetingViewModel.places.isEmpty {
                                    Text("장소를 선택해주세요.")
                                        .foregroundColor(.gray)
                                } else {
                                    Text("\(createMeetingViewModel.places[0].name)")
                                        .foregroundColor(.gray)
                                }
                                
                            }
                        }
                    }
                }
                // sheet 첫 접근 시 내려감 문제
                .sheet(isPresented: $placeViewModel.isPresentingPlaceSearchView) {
                    NavigationStack {
                        PlaceSearchView()
                            .environment(placeViewModel)
                            .environmentObject(createMeetingViewModel)
                    }
                }
                
                Section {
                    HStack {
                        Text("투표 마감기한")
                        Spacer()
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: [.date, .hourAndMinute])
                            .datePickerStyle(CompactDatePickerStyle())
                    }
                }
            }
            
            VStack {
                // Sheet 최상단에 있는 title
                Text("모임 생성하기")
                    .pretendard(.bold, 17)
                    .padding(11)
                Spacer()
                
                Button(action: {
                    // GroupVoteView로 넘어가기
                    // 시간, 장소 둘 중 하나라도 활성화 되어야 해당 버튼 활성화
                    // 해당 sheet가 내려가고, MainView의 List에 추가되고,
                    // NavigationStack에 쌓기
                    
                    
                    Task {
                        createMeetingViewModel.title = meetingName
                        createMeetingViewModel.startDate = startDate.toString()
                        print("꺅~\(createMeetingViewModel.startDate)")
                        createMeetingViewModel.endDate = endDate.toString()
                        print("꺅~\(createMeetingViewModel.endDate)")
                        createMeetingViewModel.startTime = startTime.toString()
                        createMeetingViewModel.endTime = endTime.toString()
                        
                        // 시간 정해졌을 경우, 몇시부터 몇시까지 약속인지 나타내줘야함
                        createMeetingViewModel.fixedTimes = voteTime ? [] : nil
                        
                        createMeetingViewModel.deadline = deadLine.toString()
                        
                        await createMeetingViewModel.createMeeting()
                        
                        appViewModel.navigateTo(.groupVoteView)
                        isPresentingGroupSetView = false
                    }
                    
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
                .padding(.bottom, 25)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        
    }
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        return formatter.string(from: self)
    }
}

struct DateRangePickerView: View {
    @Binding var dates: Set<DateComponents>
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            MultiDatePicker("날짜를 선택해주세요.", selection: $dates)
                .datePickerStyle(.graphical)
                .navigationTitle("날짜 선택")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("완료") {
                            presentationMode.wrappedValue.dismiss()
                        }
                    }
                }
        }
    }
}

// 키보드 외 영역 눌렀을때 키보드 숨기기
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
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

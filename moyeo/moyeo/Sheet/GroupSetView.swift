import SwiftUI

struct GroupSetView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State private var meetingName: String = ""
    @State private var voteTime: Bool = false
    @State private var votePlace: Bool = false
    @State private var selectedDate = Date()
    @State private var selectedTime = Date()
    
    @State private var isPresentingPlaceSearchView = false
    @Binding var isPresentingGroupSetView: Bool
    
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
                        NavigationStack{
                            PlaceSearchView()
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
                    // GroupVoteView로 넘어가기
                    // 시간, 장소 둘 중 하나라도 활성화 되어야 해당 버튼 활성화
                    // 해당 sheet가 내려가고, MainView의 List에 추가되고,
                    // NavigationStack에 쌓기
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

//#Preview {
//    GroupSetView()
//}

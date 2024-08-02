//
//  MainView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/25/24.
//

import SwiftUI

struct MainView: View {
    @Environment(AppViewModel.self) var appViewModel
    @State var selectedTab = "tab"
    var isConfirmed = ["미확정", "확정"]
    @State private var isPresentingGroupSetView = false
    
    // 임시
    @State private var inviteCode = ""
    @State private var presentAlert = false
    
    var body: some View {
        VStack {
            
            // 확정/미확정 미팅 리스트
            Picker("", selection: $selectedTab) {
                ForEach(isConfirmed, id: \.self) {
                    Text($0)
                        .fontWeight(.semibold)
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
            // 서버에서 모임을 불러온다.
            List {
                VStack (alignment: .leading) {
                    Text("와인 동아리")
                        .pretendard(.bold, 17)
                    Text("24. 05. 12 마감 예정")
                        .pretendard(.regular, 14)
                }
                VStack (alignment: .leading) {
                    Text("와인 동아리")
                        .pretendard(.bold, 17)
                    Text("24. 05. 12 마감 예정")
                        .pretendard(.regular, 14)
                }
            }
            .listStyle(.inset)
            
            Spacer()
            
            // 모임 생성하기 버튼
            Button(action: {
                // GroupSetView Sheet가 올라온다
                isPresentingGroupSetView.toggle()
            }) {
                Text("모임 생성하기")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(8)
            }
            .frame(width: 360, height: 50)
            .background(Color.black)
            .cornerRadius(10)
            .sheet(isPresented: $isPresentingGroupSetView) {
                GroupSetView(isPresentingGroupSetView: $isPresentingGroupSetView)
            }
            
        }
        //.navigationTitle("Moyeo")
        .navigationDestination(for: MainRoute.self) { destination in
            switch destination {
            case .groupVoteView:
                GroupVoteView()
            case .groupResultView:
                GroupResultView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Text("MOYEO")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack {
                    Button("초대코드 입력") {
                        presentAlert = true
                    }
                    .alert("초대코드 입력", isPresented: $presentAlert, actions: {
                        TextField("영문/숫자 30자리", text: $inviteCode)
                        Button("확인", action: {})
                        Button("취소", role: .cancel, action: {})
                    }, message: {
                        Text("공유받은 초대코드를 입력해주세요.")
                    })
                    .buttonStyle(.bordered)
                    Button("선택") {
                        
                    }
                    .buttonStyle(.bordered)
                    
                    Button {
                        // ProfileView로 이동
                    } label: {
                        Image("IconToProfile")
                    }
                }
                
            }
        }
    }
}

#Preview {
    MainView()
        .environment(AppViewModel())
}

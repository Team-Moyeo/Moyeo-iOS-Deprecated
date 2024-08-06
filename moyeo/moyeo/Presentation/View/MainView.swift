//
//  MainView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/25/24.
//

import SwiftUI

struct MainView: View {
    @Environment(AppViewModel.self) var appViewModel
    @State var selectedTab = "미확정"
    var isConfirmed = ["미확정", "확정"]
    @State private var isPresentingGroupSetView = false
    
    // 임시
    @State private var inviteCode = ""
    @State private var presentAlert = false
    
    // Andy
    @StateObject var sharedDm = SharedDateModel()
    
    
    var body: some View {
        VStack {
            
            // 확정/미확정 미팅 리스트
            Picker("", selection: $selectedTab) {
                ForEach(isConfirmed, id: \.self) {
                    Text($0)
                        .pretendard(.semiBold, 13)
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
                AndyGroupSetView(isPresentingGroupSetView: $isPresentingGroupSetView, sharedDm: sharedDm)
            }
            
        }
        //.navigationTitle("Moyeo")
        .navigationDestination(for: MainRoute.self) { destination in
            switch destination {
            case .groupVoteView:
                AndyGroupVoteView(sharedDm: sharedDm)
            case .groupResultView:
                GroupResultView()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Image("MainViewLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 28)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                
                HStack() {
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
                    .background(.myE1ACAC.opacity(0.3))
                    .frame(height: 28)
                    .font(.system(size: 15))
                    .foregroundStyle(.myDD8686)
                    .cornerRadius(10)
                    
                    Button("선택") {
                        // 내 모임들의 상태를 선택가능 하게 바꿉니다.
                    }
                    .buttonStyle(.bordered)
                    .frame(height: 28)
                    .font(.system(size: 15))
                    .foregroundStyle(.myDD8686)
                    .cornerRadius(10)
                    
                    Button {
                        // ProfileView로 이동
                    } label: {
                        Image("IconToProfile")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 28)
                    }
//                    .padding(.leading, -8)
                    
                }
                
                
            }
            
            
            
        }
    }
}

#Preview {
    NavigationStack {
        MainView()
            .environment(AppViewModel())
    }
}

//
//  MainView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/25/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @State var selectedTab = "tab"
    var isConfirmed = ["미확정", "확정"]
    @State private var isPresentingGroupSetView = false
    
    
    var body: some View {
        VStack {
            Text("Main View")
                .font(.largeTitle)
                .padding()
            
            // 상단 HeaderView
            Group {
                HStack {
                    Button(action: {
                        
                    }) {
                        Text("초대코드 입력")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    Button(action: {
                        
                    }) {
                        Text("선택")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                    Button(action: {
                        
                    }) {
                        Text("프로필")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black)
                            .cornerRadius(8)
                    }
                }
            }
            
            // 확정/미확정 미팅 리스트
            Picker("", selection: $selectedTab) {
                ForEach(isConfirmed, id: \.self) {
                    Text($0)
                    // 확정/미확정, 그룹장/그룹원 여부 경우의 수로 목업 파일 추가하기
                }
            }
            .pickerStyle(.segmented)
            .padding()
            
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
        .navigationTitle("Moyeo")
        .navigationDestination(for: MainRoute.self) { destination in
            switch destination {
            case .groupVoteView:
                GroupVoteView()
            case .groupResultView:
                GroupResultView()
            }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(AppViewModel())
}

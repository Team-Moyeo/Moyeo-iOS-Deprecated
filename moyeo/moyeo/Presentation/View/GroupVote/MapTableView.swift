//
//  MapTableView.swift
//  moyeo
//
//  Created by Giwoo Kim on 8/13/24.
//

import SwiftUI

struct MapTableView: View {
    @State var meetingID: Int = 0
    @ObservedObject var vm = MapTableViewModel()
    
    var body: some View {
        VStack {
            let numberFormatter: NumberFormatter = {
                let formatter = NumberFormatter()
                formatter.numberStyle = .none // 숫자 스타일 설정
                formatter.minimumIntegerDigits = 1 // 최소 자리수 설정
                formatter.maximumIntegerDigits = 4 // 최대 자리수 설정 (입력 제한은 별도로 처리)
                return formatter
            }()
            
            TextField("meetingID", value: $meetingID, formatter: numberFormatter)
                .keyboardType(.numberPad)
                .onChange(of: meetingID) { _, newValue in
                    // 4자리 숫자 초과 입력 시 잘라냄
                    if String(newValue).count > 4 {
                        meetingID = Int(String(String(newValue).prefix(4))) ?? 0
                    }
                }.frame(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            Button("fetch candidate place") {
                
                vm.meetingID = meetingID
                
                Task {
                    await vm.getCandidatePlaces()
                    print(vm.votedPlacesResult)
                }
            }
        }
        .onAppear {
            vm.meetingID = meetingID
        }
    }
}

#Preview {
   
    MapTableView(meetingID: 1, vm: MapTableViewModel())
}

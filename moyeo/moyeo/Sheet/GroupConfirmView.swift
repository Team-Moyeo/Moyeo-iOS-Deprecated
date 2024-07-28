//
//  GrooupConfirmView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/26/24.
//

import SwiftUI

struct GroupConfirmView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Binding var isPresentingGroupConfirmView: Bool
    
    var body: some View {
        Text("GroupConfirmView")
            .padding()
        
        Button(action: {
            // GroupConfirmView Sheet가 내려가고
            // appPath에 GroupResultView가 append 된다.
            appViewModel.navigateTo(.groupResultView)
            isPresentingGroupConfirmView = false
        }) {
            Text("확정하기")
        }
        
    }
}

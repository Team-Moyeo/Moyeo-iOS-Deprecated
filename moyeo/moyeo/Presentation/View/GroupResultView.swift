//
//  GroupResultView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/26/24.
//

import SwiftUI

struct GroupResultView: View {
    @Environment(AppViewModel.self) var appViewModel
    
    var body: some View {
        VStack {
            Text("GroupResultView")
            
            Button(action: {
                //
                appViewModel.popToMain()
            }) {
                Text("홈으로 돌아가기")
            }
        }
        .navigationBarBackButtonHidden(true)
        
        
    }
}

#Preview {
    GroupResultView()
}

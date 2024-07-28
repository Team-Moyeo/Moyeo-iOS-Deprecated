//
//  LoginView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/25/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var appViewModel: AppViewModel

    var body: some View {
        VStack {
            Text("모여 로고")
                .font(.title)
            
            Button(action: {
                // 임의로 로그인 성공 처리
                appViewModel.handleSignInWithApple()
            }) {
                Text("임시 Apple Login Button")
                    .foregroundColor(.white)
                    .padding()
                    
            }
            .frame(width: 360, height: 50)
            .background(Color.black)
            .cornerRadius(14)
        }
    }
}


#Preview {
    LoginView()
        .environmentObject(AppViewModel())
}

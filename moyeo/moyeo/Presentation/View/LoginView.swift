//
//  LoginView.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 7/18/24.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    var body: some View {
        VStack {
            Spacer()
            Image(.loginViewLogo)
                .padding(.bottom, 21)
            Text("The Best Time for Everyone")
                .pretendard(.extraLight, 19)
                .foregroundStyle(.myGray)
            Spacer()
            AppleSigninButton()
                .padding(.bottom, 12)
        }
    }
}

struct AppleSigninButton: View {
    @Environment(AuthViewModel.self) var authViewModel
    
    var body: some View {
        
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                Task {
                    await authViewModel.appleLogin(request: request)
                }
            },
            onCompletion: { result in
                Task {
                    await authViewModel.appleLoginCompletion(result: result)
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(width: 361, height: 50)
        
    }
    
    
    
}

#Preview {
    LoginView()
        .environment(AuthViewModel())
        .environment(AppViewModel())
}

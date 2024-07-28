//
//  AppViewModel.swift
//  moyeo
//
//  Created by Woowon Kang on 7/25/24.
//

import SwiftUI

enum MainRoute : String , Hashable {
    case groupVoteView
    case groupResultView
}

class AppViewModel: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var appPath = NavigationPath()
    
    func handleSignInWithApple() {
        // 애플 로그인 로직 구현 필요
        
        self.isAuthenticated = true
    }
    
    func navigateTo(_ view: MainRoute) {
        appPath.append(view)
    }
    
    func pop() {
        if !appPath.isEmpty {
            appPath.removeLast()
        }
    }
    
    func popToMain() {
        // MainView로 돌아가려면 모든 뷰를 제거하고 초기 상태로 돌아감
        while !appPath.isEmpty {
            appPath.removeLast()
        }
    }
}

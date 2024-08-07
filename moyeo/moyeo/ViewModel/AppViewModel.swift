//
//  AppViewModel.swift
//  moyeo
//
//  Created by Woowon Kang on 7/25/24.
//

import SwiftUI

enum MainRoute : Hashable {
 
    case groupVoteView
    case groupResultView
}

@Observable class AppViewModel {
    
    var appPath = NavigationPath()
    
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

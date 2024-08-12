//
//  moyeoApp.swift
//  moyeo
//
//  Created by kyungsoolee on 7/15/24.
//

import SwiftUI
import AuthenticationServices
import NMapsMap

@main
struct moyeoApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var vm = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $vm.appPath) {
//                NetworkManagerTestView()
//                    .environment(AuthViewModel())
                ContentView()
            }
        }
        .environment(vm)
        
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        // 앱이 런칭될 때 호출되는 함수
        
        return true
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        // 앱이 사용자 활동을 계속할 때 호출되는 함수
        if userActivity.activityType == ASAuthorizationAppleIDProvider.credentialRevokedNotification.rawValue {
            // Apple ID Credential이 취소된 경우 처리
            print("Apple ID Credential Revoked")
        }
        return true
    }
}

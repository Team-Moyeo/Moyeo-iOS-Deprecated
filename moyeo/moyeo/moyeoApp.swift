//
//  moyeoApp.swift
//  moyeo
//
//  Created by kyungsoolee on 7/15/24.
//

import SwiftUI

@main
struct moyeoApp: App {
    
    @StateObject private var vm = AppViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $vm.appPath) {
                ContentView()
            }
        }
        .environmentObject(vm)
        
    }
}

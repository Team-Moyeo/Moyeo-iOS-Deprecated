//
//  ContentView.swift
//  moyeo
//
//  Created by kyungsoolee on 7/15/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(AppViewModel.self) var appViewModel
    @StateObject var authViewModel: AuthViewModel = .init()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainView()
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
    }
}


//
//  ContentView.swift
//  moyeo
//
//  Created by kyungsoolee on 7/15/24.
//

import SwiftUI
import NMapsMap
struct ContentView: View {
    @EnvironmentObject var appViewModel: AppViewModel
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

#Preview {
    ContentView()
        .environmentObject(AppViewModel())
}

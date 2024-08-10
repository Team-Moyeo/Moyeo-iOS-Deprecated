//
//  ContentView.swift
//  moyeo
//
//  Created by kyungsoolee on 7/15/24.
//

import SwiftUI
import NMapsMap

struct ContentView: View {
    @Environment(AppViewModel.self) var appViewModel
    @State var authViewModel: AuthViewModel = .init()
    @State var meetingListViewModel: MeetingListViewModel = .init()
    @StateObject var profileViewModel: ProfileViewModel = .init()
    
    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                MainView()
                    .environment(meetingListViewModel)
                    .environmentObject(profileViewModel)
            } else {
                LoginView()
            }
        }
        .environment(authViewModel)
    }
}


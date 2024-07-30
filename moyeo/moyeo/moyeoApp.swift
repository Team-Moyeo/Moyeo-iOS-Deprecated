//
//  moyeoApp.swift
//  moyeo
//
//  Created by kyungsoolee on 7/15/24.
// for testing purpose

import SwiftUI

@main
struct moyeoApp: App {
    @StateObject var timeVM = TimeTableHeaderVM()
    var body: some Scene {
        WindowGroup {
         //   GridExampleView()
           // LazyVGridWithButtonTrackingView()
           // DynamicGridExample()
            DynamicGridWithDragSelection(vm:  timeVM)
// 뭐하러  environmentobject로 바내지 그냥 클라스 내에서 생성해서 쓰지.. 나중에 필요하면 옮기는걸로 함.
//            CalendarFetchView()
//                .environmentObject(storeManager)
        }
    }
}

//
//  TempGroupVoteView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/18/2https://chatgpt.com/c/c5e2307b-a637-4c15-939a-683a4910274f4.
//

import SwiftUI

struct TempGroupVoteView: View{
    @State var startDate: Date
    @State  var endDate: Date
    
    var numberOfDays: Int {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day], from: startDate, to: endDate)
            return components.day ?? 0
        }

    init(startDate: Date, endDate: Date) {
        self.startDate = startDate
        self.endDate = endDate
    }
    
    var body: some View {
   

       Text("hello world")
        
        
    }
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()

}

//#Preview {
//    var startDate : Date = Date.now
//    var endDate : Date  = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate)!
//    TempGroupVoteView(startDate: startDate , endDate:endDate)
//}

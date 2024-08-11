//
//  SharedDateModel.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/31/24.
//

import Combine
import Foundation
import SwiftUI



struct CombinedDate{
    let id = UUID()
    let start: Date
    let end: Date
}

class SharedDateModel: ObservableObject {
   //  순환참조 조심 didSet은 값이 변경되면 한번만 불러오고 종료되게.
    let id = UUID()
    @Published var meetingName: String = "오택동회의"
    
    @Published var voteTime: Bool = false
    @Published var votePlace: Bool = false
    @Published var selectedDate = Date()
    @Published var selectedTime = Date()
    
    
    @Published var startDate: Date {
        didSet {

            //willSet이면 아직 startDate가 변경되기 전이라   updateEndDate이 실행을 해도 값이 바뀌기 전이라 안바뀔것이고
            //didSet이면 startDate가 변경된 후이므로 변경된 startDate과 변경되지 않은 endDate을 가져오게 되는 오류가 생김
            //didSet과 willSet에서는 직접적인 변수값을 변경하는것은 피해야한다는게 결론 .스트링 정도값만업데이트
            
            startDateString = dateToDateString(date: self.startDate) ?? ""
            print("In the startDate didSet. endDate now is \(self.endDate)")
            
        }
    }
    
    @Published var endDate: Date {
        didSet{
            
            endDateString = dateToDateString(date: endDate) ?? ""
            print("In the endDate didSet. endDate now is \(self.endDate)")
            
        }
    }
    
    @Published var endDateString : String
    @Published var startDateString : String
    
    var isUpdating = false
    private var isUpdatingDates = false
    private var cancellables = Set<AnyCancellable>()
    //CurrentValueSubject도 되는데 초기값이 필요함.
    
    var count  = 0
    var receiveCount = 0
    
    init(startDate: Date = Date(), endDate: Date = Date(), numberOfDays: Int = 7) {
        let calendar = Calendar.current
        self.startDate = calendar.startOfDay(for: startDate)
        if let endOfNextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: endDate)) , let endDate = calendar.date(byAdding: .second, value: -1, to: endOfNextDay) {
           
                self.endDate = endDate
            
        } else {
            self.endDate = endDate
        }
        self.endDateString = ""
        self.startDateString = ""
        
    }
    
    private func setupBindings() {
        
       $startDate
            .compactMap{
                TimeFixToZero(date:$0)
            }
            .sink { [weak self] date in
                guard let self = self else { 
                    print("sink error")
                    return }
                if !self.isUpdating {
                    print("SharedDateModel : startdate Publish \(date)")
               }
            }
            .store(in: &cancellables)
        
        
    }
    
    

    
}

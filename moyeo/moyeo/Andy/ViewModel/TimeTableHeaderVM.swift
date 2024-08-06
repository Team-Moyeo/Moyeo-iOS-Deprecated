//
//  SwiftUIView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/29/24.
//

import Foundation
import Combine
@MainActor
// 화면 출력과 관계가 있어서 @MainActor.run {}을 사용해야 할곳이 있는지 추후 체크
class TimeTableHeaderVM :ObservableObject{
    
    @Published var startDate : Date = Date()
    @Published var endDate : Date = Date()
    
    @Published var numberOfDays: Int = 7
    
    @Published var day : [Int] = []
    @Published var month : [Int] = []
    @Published var monthString :[String] = []
    @Published var year  : [Int] = []
    @Published var yearString : [String] = []
    @Published var weekdayString : [String] = []
    @Published var startDateString : String
    @Published var endDateString : String
    private var cancellables = Set<AnyCancellable>()
    private var isShowing = false
    
    init(sharedModel : SharedDateModel) {
      
        
        day =  []
        month = []
        monthString  = []
        year = []
        yearString  = []
        weekdayString = []
        startDateString  = ""
        endDateString = ""
        Task {
           await  setupBindings(sharedModel: sharedModel)
        }
    }
  
    private func setupBindings(sharedModel: SharedDateModel)  async {
        
     Publishers.CombineLatest3(sharedModel.$startDate,sharedModel.$endDate , sharedModel.$numberOfDays)
        .sink { [weak self]  start, end, numberOfDays in
            guard let self = self else { return }
            if !(self.isShowing) {
                self.isShowing = true
                self.startDate = start
                self.endDate = end
                self.numberOfDays = numberOfDays
                self.makeHeaderTimeTable()
                self.isShowing = false
                
                print("TTHVM COMBINELATEST3 : s:\(start) e:\(end) n:\(numberOfDays)")
            }
        }
        .store(in: &cancellables)
    }
    
    //변수의 값이 바뀔때 publishing-sink로 연결된 함수를 실행시킨다..내가 조건체크할 필요가 없음
    func makeHeaderTimeTable(){
//        guard let startDate = self.startDate else {return }
//        guard let endDate = self.endDate else {return }
//        guard let numberOfDays = self.numberOfDays else { return}
//
        print("makeHeaderTimeTable from combine!! be careful not to run many times...")
        let dateString = dateToDateString(date: startDate)
        _ = TimeZone(identifier: "Asia/Seoul")!
        
        day.removeAll()
        month.removeAll()
        monthString.removeAll()
        year.removeAll()
        yearString.removeAll()
        weekdayString.removeAll()
        
        let numberOfDaysInt = Int(numberOfDays)
        startDateString = dateToDateString(date: startDate) ?? ""
        endDateString = dateToDateString(date: endDate) ?? ""
        
        print("TimeTableHeader \(numberOfDaysInt)")
        for index in 0..<numberOfDaysInt {
            if let dayFromDateString = dayFromDateString(dateString: dateString, dateOffset: index  ),
               let weekdayNumberFromDateString = weekdayFromDateString(dateString: dateString, dateOffset:index ),
               let monthFromDateString  = monthFromDateString(dateString: dateString, dateOffset: index  ),
               let yearFromDateString = yearFromDateString(dateString: dateString, dateOffset: index  ) {
                
                day.append(dayFromDateString)
                month.append( monthFromDateString)
                year.append( yearFromDateString)
                weekdayString.append(Weekday(rawValue: weekdayNumberFromDateString)?.name ?? "")
                if index == 0 {
                    monthString.append(String(month[index]))
                    yearString.append(String(year[index]))
                }
                else{
                    if month[index] != month[index - 1] {
                        monthString.append(String(month[index]))
                    } else{
                        monthString.append("")
                    }
                    
                    if year[index] != year[index - 1] {
                        yearString.append(String(year[index]))
                    } else{
                        yearString.append("")
                    }
                    
                }
            }
        }
    }
}



//
//  SwiftUIView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/29/24.
//

import Foundation
import Combine


class TimeTableHeaderVM :ObservableObject{
    
    @Published var startDate : Date = Date()
    @Published var endDate : Date = Date()
    
    @Published var numberOfColumns: Double = 7
    
    @Published var day : [Int] = []
    @Published var month : [Int] = []
    @Published var monthString :[String] = []
    @Published var year  : [Int] = []
    @Published var yearString : [String] = []
    @Published var weekdayString : [String] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var startDateString : String
  
    @Published var endDateString : String

    init(startDate: Date = Date(), endDate : Date = Date(), numberOfColumns: Double = 7) {
        self.startDate = startDate
        self.endDate = endDate
        self.numberOfColumns = numberOfColumns
        
        day =  []
        month = []
        monthString  = []
        year = []
        yearString  = []
        weekdayString = []
        startDateString  = ""
        endDateString = ""
        
        setupBindings()
    }
    private func setupBindings() {
        $startDate
            .merge(with: $endDate)
            .sink { [weak self] _ in
                self?.makeHeaderTimeTable()
            }
            .store(in: &cancellables)
        $numberOfColumns
            .sink { [weak self] _ in
                self?.makeHeaderTimeTable()
            }
            .store(in: &cancellables)
    }
    
    //변수의 값이 바뀔때 publishing-sink로 연결된 함수를 실행시킨다..내가 조건체크할 필요가 없음
    func makeHeaderTimeTable(){
//        guard let startDate = self.startDate else {return }
//        guard let endDate = self.endDate else {return }
//        guard let numberOfColumns = self.numberOfColumns else { return}
//
        print("makeHeaderTimeTable from combine wonderful to use the combine..")
        let dateString = dateToDateString(date: startDate)
        _ = TimeZone(identifier: "Asia/Seoul")!
        
        day.removeAll()
        month.removeAll()
        monthString.removeAll()
        year.removeAll()
        yearString.removeAll()
        weekdayString.removeAll()
        
        let numberOfColumnsInt = Int(numberOfColumns)
        startDateString = dateToDateString(date: startDate) ?? ""
        endDateString = dateToDateString(date: endDate) ?? ""
        
        for index in 0..<numberOfColumnsInt {
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



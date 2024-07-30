//
//  SwiftUIView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/29/24.
//

import Foundation
class TimeTableHeaderVM :ObservableObject{
    
   var startDate : Date
 
  
    var numberOfColumns: Int
    
    @Published var day : [Int] = []
    @Published  var month : [Int] = []
    @Published var monthString :[String] = []
    @Published var year  : [Int] = []
    @Published var yearString : [String] = []
    @Published var weekdayString : [String] = []
    
    init(startDate : Date, numberOfColumns : Int) {
        self.startDate = startDate
        self.numberOfColumns = numberOfColumns
        
      //  print("startDate \(startDate) endDate \(endDate)  in the tableHeaderVM")
        
        
        makeHeaderTimeTable()
        
    }
    
    func makeHeaderTimeTable(){
       
        let dateString = dateToDateString(date: startDate)
        let koreanTimeZone = TimeZone(identifier: "Asia/Seoul")!
        
        // DateFormatter 생성 및 설정
       
        
        
        day.removeAll()
        month.removeAll()
        monthString.removeAll()
        year.removeAll()
        yearString.removeAll()
        weekdayString.removeAll()
        
        
        for index in 0..<numberOfColumns  {
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



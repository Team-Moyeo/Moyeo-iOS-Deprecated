/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Extends the date class.
*/

import Foundation

extension Date {
    
    /// The day of the week matching the specified date.
    var matchingDay: Int {
        Calendar.current.component(.weekday, from: self)
    }
    
    /// The next date for the given weekdays.
    func fetchNextDateFromDays(_ nextWeekDay: IndexSet) -> Date {
       var components: Int?
       let weekDay = Calendar.current.component(.weekday, from: self)
    
       if let nextWeekDay = nextWeekDay.integerGreaterThan(weekDay) {
           components = nextWeekDay
       } else {
           components = nextWeekDay.first
       }
       guard let foundWeekDay = components else { return self }
       return Calendar.current.nextDate(after: self, matching: DateComponents(weekday: foundWeekDay), matchingPolicy: .nextTime) ?? self
   }
   
    /// The formatted time of the date.
    var timeAsText: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: self)
    }
    
    /// Thirty minutes from the current time.
    var thirtyMinutesLater: Date {
        Date(timeInterval: 1800, since: self)
    }
    
    /// A month from the current date.
    var oneMonthOut: Date {
        Calendar.current.date(byAdding: .month, value: 1, to: Date.now) ?? Date()
    }
}

func dateStringToDate(dateString : String?) -> Date? {
    guard let dateString = dateString else { return nil}
   
       
       // 문자열에서 연, 월, 일을 추출합니다.
       let components = dateString.split(separator: "-")
       guard components.count == 3,
             let year = Int(components[0]),
             let month = Int(components[1]),
             let day = Int(components[2]) else {
           print("Invalid date format")
           return nil
       }
       
       // Calendar를 사용하여 Date 객체를 생성합니다.
       var dateComponents = DateComponents()
       dateComponents.year = year
       dateComponents.month = month
       dateComponents.day = day
       dateComponents.hour = 0
       dateComponents.minute = 0
       dateComponents.second = 0
       
       // 한국 시간대로 설정합니다.
       let calendar = Calendar.current
       if let timeZone = TimeZone(identifier: "Asia/Seoul") {
           var calendarWithTimeZone = calendar
           calendarWithTimeZone.timeZone = timeZone
           if let date = calendarWithTimeZone.date(from: dateComponents) {
               print("The date is \(date)")
               return date
           } else {
               print("Invalid date components")
               return nil
           }
       } else {
           print("Invalid timezone")
           return nil
       }
}

func dateToDateString(date: Date?) ->String? {
    guard let date = date else { return nil }
    // DateFormatter를 생성합니다.
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" // 문자열의 날짜 형식을 설정합니다.
    dateFormatter.locale = Locale(identifier: "ko_KR") // 로케일을 한국으로 설정합니다.
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    // Date 객체를 문자열로 변환합니다.
    let dateString = dateFormatter.string(from: date)
    return dateString
}


func dateStringToDate2(dateString : String?) -> Date? {
    guard let dateString = dateString else { return nil}
    // DateFormatter를 생성합니다.
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z" // 문자열의 날짜 형식을 설정합니다.
    dateFormatter.locale = Locale(identifier: "ko_KR") // 로케일을 한국으로 설정합니다.
    dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    // 문자열을 Date 객체로 변환합니다.
    if let date = dateFormatter.date(from: dateString) {
        print("The date is \(date)")
        return date
    } else {
        print("Invalid date format")
        return nil
    }
}


func daysBetween(start: Date, end: Date, timeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!) -> Int?{
    var calendar = Calendar.current
    calendar.timeZone = timeZone
  
    
    if let startDay = TimeFixToZero(date: start), let endDay = TimeFixToMidNight(date: end) {
        print("daysBet: fixStart: \(startDay)  fixEnd: \(endDay)")
        let components = calendar.dateComponents([.day], from: startDay, to: endDay)
        
        if let day = components.day {
            print("day in the daysBetween : \(day) fs: :\(startDay) fe: \(endDay) os: \(start) oe:\(end)")
            return day + 1
            
        } else {
            return nil
        }
    } else{ return nil}
}

func hourminToFourDigit(timeToConvert : Date, timeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!) -> Int? {
    
    var calendar = Calendar.current
    calendar.timeZone = timeZone
    
    let components = calendar.dateComponents([.day, .hour, .minute], from: timeToConvert)
    
    guard let day = components.day, let hour = components.hour, let minute = components.minute else {
        return nil
    }
    let result = hour * 100 + minute
    return result
    
}
extension String {
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start...end]
    }
}

func hourminStringToFourDigit(timeToConvert: String) -> Int {
    var result : Int = 0
   
    if timeToConvert != "midnight" {
        if let hour = Int(timeToConvert[0...1]) , let min  = Int(timeToConvert[3...4]) {
            
            let flag = timeToConvert.suffix(2)
            result = hour * 100  + min
            
            if flag == "pm" && hour < 12 {
                
                result = result + 1200
                
            }
            
            
        }
    }
    else {
        result = 2400
    }
    
    return result
}

func dayFromDateString(dateString: String?, dateOffset: Int) -> Int? {
    
    guard let dateString = dateString else { return nil}
    let dateFormatter = DateFormatter()
    
    // 날짜 형식 지정 (여기서는 "yyyy-MM-dd" 형식 사용)
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    // 문자열을 Date 객체로 변환
    if let date = dateFormatter.date(from: dateString) {
        // Calendar 인스턴스 생성
        let calendar = Calendar.current
        
        // DateComponents를 사용하여 하루를 추가
        if  let targetDay = calendar.date(byAdding: .day, value: dateOffset, to: date) {
            let dayComponent = calendar.component(.day, from: targetDay)
            return dayComponent
            
        }
    }
    
    return nil
    
}

func monthFromDateString(dateString: String?, dateOffset: Int) -> Int? {
    
    guard let dateString = dateString else { return nil}
    let dateFormatter = DateFormatter()
    
    // 날짜 형식 지정 (여기서는 "yyyy-MM-dd" 형식 사용)
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    // 문자열을 Date 객체로 변환
    if let date = dateFormatter.date(from: dateString) {
        // Calendar 인스턴스 생성
        let calendar = Calendar.current
        
        // DateComponents를 사용하여 하루를 추가
        if  let targetDay = calendar.date(byAdding: .day, value: dateOffset, to: date) {
            let monthComponent = calendar.component(.month, from: targetDay)
            return monthComponent
            
        }
    }
    return nil
}

func yearFromDateString(dateString: String?, dateOffset: Int) -> Int? {
    
    guard let dateString = dateString else { return nil}
    let dateFormatter = DateFormatter()
    
    // 날짜 형식 지정 (여기서는 "yyyy-MM-dd" 형식 사용)
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    // 문자열을 Date 객체로 변환
    if let date = dateFormatter.date(from: dateString) {
        // Calendar 인스턴스 생성
        let calendar = Calendar.current
        
        // DateComponents를 사용하여 하루를 추가
        if  let targetDay = calendar.date(byAdding: .day, value: dateOffset, to: date) {
            let yearComponent = calendar.component(.year, from: targetDay)
            return yearComponent
            
        }
    }
    return nil
}

// 1은 일요일, 2는 월요일, ... , 7은 토요일
func weekdayFromDateString(dateString: String?, dateOffset: Int) -> Int? {
    
    guard let dateString = dateString else { return nil}
    let dateFormatter = DateFormatter()
    
    // 날짜 형식 지정 (여기서는 "yyyy-MM-dd" 형식 사용)
    dateFormatter.dateFormat = "yyyy-MM-dd"
    
    // 문자열을 Date 객체로 변환
    if let date = dateFormatter.date(from: dateString) {
        // Calendar 인스턴스 생성
        let calendar = Calendar.current
        
        // DateComponents를 사용하여 하루를 추가
        if  let targetDay = calendar.date(byAdding: .day, value: dateOffset, to: date) {
            let weekdayComponent = calendar.component(.weekday, from: targetDay)
            return weekdayComponent
            
        }
    }
    
    return nil
}
// 1은 일요일, 2는 월요일, ... , 7은 토요일

func TimeFixToZero(date : Date) ->Date?{
   
    let calendar = Calendar.current
    
    let startDate =  calendar.startOfDay(for: date)
        
        return startDate
    
                                
}
func TimeFixToMidNight(date : Date) -> Date?{
   
    let calendar = Calendar.current
    
    if let endOfNextDay = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) {
        let endDate = calendar.date(byAdding: .second, value: -1 , to: endOfNextDay)
            return  endDate
    } else {
        return nil
    }
                                   
                                   
}

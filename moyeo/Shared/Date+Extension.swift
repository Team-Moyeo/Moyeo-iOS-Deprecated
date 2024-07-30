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
    // DateFormatter를 생성합니다.
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd" // 문자열의 날짜 형식을 설정합니다.
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


func daysBetween(start: Date, end: Date, timeZone: TimeZone = TimeZone(identifier: "Asia/Seoul")!) -> Int? {
    var calendar = Calendar.current
    calendar.timeZone = timeZone
    // 시간 구성 요소를 00:00:00으로 설정
    var startComponents = calendar.dateComponents([.year, .month, .day], from: start)
    var endComponents = calendar.dateComponents([.year, .month, .day], from: end)
    
    startComponents.hour = 0
    startComponents.minute = 0
    startComponents.second = 0
    endComponents.hour = 0
    endComponents.minute = 0
    endComponents.second = 0
    
    // 새 날짜 생성
    guard let startOfDay = calendar.date(from: startComponents),
          let endOfDay = calendar.date(from: endComponents) else {
        return nil
    }
    
    let components = calendar.dateComponents([.day], from: start, to: end)
    return components.day
    
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
    //    let timeSlot : [String] = ["00:00am", "00:30am","01:00am","01:30am","02:00am", "02:30am", "03:00am", "03:30am", "04:00am", "04:30am","05:00am", "05:30am", "06:00am","06:30am", "07:00am" ,"07:30am", "08:00am","08:30am", "09:00am", "09:30am", "10:00am", "10:30am", "11:00am", "11:30am", "12:00pm", "12:30pm","01:00pm","01:30pm","02:00pm", "02:30pm", "03:00pm", "03:30pm", "04:00pm", "04:30pm","05:00pm", "05:30pm", "06:00pm","06:30pm", "07:00pm" ,"07:30pm", "08:00pm", "09:00pm", "09:30pm", "10:00pm", "10:30pm", "11:00pm", "11:30pm", "midnight" ]
    //
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


import Foundation
import EventKit
import Combine

@MainActor
class EventViewModel : ObservableObject {
    
    var startDate: Date = Date()
    var endDate: Date = Date()
    @Published var calendarArray : Set<IntTuple> = []
    @Published var events : [EKEvent]  = []
    
    private var isFetching  = false
    
    private var cancellables = Set<AnyCancellable>()
    
    private var receiveCount = 0
    
    //mid night 필요가 없음.. 00:00 이면 00:00- 00:30am을 의미하는데.. midnight하고 같은것임. from midntight ~ midnight + 30min
    var timeSlot : [String] =  ["00:00am", "00:30am","01:00am","01:30am","02:00am", "02:30am", "03:00am", "03:30am", "04:00am", "04:30am","05:00am", "05:30am", "06:00am","06:30am", "07:00am" ,"07:30am", "08:00am","08:30am", "09:00am", "09:30am", "10:00am", "10:30am", "11:00am", "11:30am", "12:00pm", "12:30pm","01:00pm","01:30pm","02:00pm", "02:30pm", "03:00pm", "03:30pm", "04:00pm", "04:30pm","05:00pm", "05:30pm", "06:00pm","06:30pm", "07:00pm" ,"07:30pm", "08:00pm", "09:00pm", "09:30pm", "10:00pm", "10:30pm", "11:00pm", "11:30pm", "midnight" ]
    
    init(sharedModel: SharedDateModel)   {
        setupBindings(sharedModel: sharedModel)
    }
    
    private func setupBindings(sharedModel: SharedDateModel) {
        
        sharedModel.$combinedDate
            .sink { [weak self]  combinedDate in
                guard let self = self , let combinedDate = combinedDate else  {return}
                
                print("EVVM: start:  \(startDate)  end : \(endDate)")
                receiveCount += 1
                print("EVVMREC# \(receiveCount) id: \(combinedDate.id) start: \(combinedDate.start) end: \(combinedDate.end)")
                
                if  !(self.isFetching) {
                    self.isFetching = true
                    print("combinedDate in the sharedModel \(combinedDate.id)")
                    self.startDate = combinedDate.start
                    print("startDate in sharedModel.$combinedDate \(self.startDate)")
                    self.endDate = combinedDate.end
                    print("endDate in sharedModel.$combinedDate \(self.endDate)")
                    Task {
                        print("getting the events...")
                        await self.getEvents()
                        await self.moveEventsToCalendarArray()
                        self.isFetching = false
                        print("finish getting the events....")
                    }
                }
            }
            .store(in: &cancellables)
        
    }
    func getEvents() async {
        
        let storeManager = EventStoreManager()
        
        self.calendarArray.removeAll()
        self.events.removeAll()
        
        if !storeManager.isWriteOnlyOrFullAccessAuthorized {
            do {
                let ret = try  await storeManager.dataStore.verifyAuthorizationStatus()
                if ret == true { print("request full access to events successfully ")}
                else {
                    print("authorization fail to get full access")
                }
            }catch {
                print(error)
            }
            
        }  else {
            print("authorized to use the events data")
        }
        print("startDate endDate in the getEvents:\(String(describing: self.startDate)) endDate \(String(describing: self.endDate))")
        events = await storeManager.dataStore.fetchEventsFromTo(startDate: startDate, endDate: endDate) ?? []
        print("Number Of Events \(events.count)")
        
        for (index, event ) in events.enumerated() {
            let title = event.title ?? "No Title"
            let startDate = event.startDate.map { "\($0)" } ?? "No Start Date"
            let endDate = event.endDate.map { "\($0)" } ?? "No End Date"
            
            print("Event #\(index + 1): \(title) \(startDate) - \(endDate) \(String(describing: event.timeZone))")
        }
    }
    // UTC라고 가정하고 한국 시간에 맞게 모두 수정, 만약에 timeZone이있는 경우 그 시간으로 변경한후에 다시 한국시간으로 변겨
    func moveEventsToCalendarArray() async {
        
        var startHourMin : Int = 0
        var endHourMin : Int  = 0
        var startCol : Int = 0
        var endCol : Int = 0
        var startRow : Int = 0
        var endRow : Int = 0
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        calendarArray.removeAll()
        
        for event in events {
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            
            // UTC 시간 출력
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            let utcDateString = dateFormatter.string(from: event.startDate )
            
            // 한국 시간 출력
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            let koreanDateString = dateFormatter.string(from: event.startDate)
            
            print("UTC 시간: \(utcDateString)   한국 시간: \(koreanDateString)")
            
            let dayDiff = daysBetween(start: startDate, end: event.startDate) ?? 0
            
            startCol = daysBetween(start: startDate, end: event.startDate) ?? 0
            endCol =   daysBetween(start: startDate, end: event.endDate) ?? 0
            
            // 자정을 23:59: 59초 이므로 분은 59에서 종료
            
            if let startDate = event.startDate {
                startHourMin = hourminToFourDigit(timeToConvert: startDate) ?? 0
            }
            
            if let endDate = event.endDate {
                endHourMin = hourminToFourDigit(timeToConvert: endDate) ?? 0
                
            }
            print("약속시작 : \(startHourMin)  약속종료: \(endHourMin)")
            
            for rowIndex in 0..<(timeSlot.count - 1) {
                let start = hourminStringToFourDigit(timeToConvert: timeSlot[rowIndex])
                let end = hourminStringToFourDigit(timeToConvert: timeSlot[rowIndex + 1 ])
                
                if   start <= startHourMin  && startHourMin <= end  {
                    startRow = rowIndex
                }
                
                if   start <= endHourMin  && endHourMin <= end  {
                    endRow = rowIndex
                    print("start \(start)  end \(end)")
                }
                
            }
            
            print("startRow: \(startRow)   endRow :\(endRow)")
            for col in startCol...endCol {
                if col == startCol && col < endCol {
                    
                    for row in startRow..<timeSlot.count{
                        calendarArray.insert(IntTuple(rowIndex: row , columnIndex: col))
                    }
                }
                else if col == startCol && col == endCol {
                    for row in startRow...endRow {
                        calendarArray.insert(IntTuple(rowIndex: row , columnIndex: col))
                    }
                }
                else if col > startCol && col < endCol {
                    for row in 0..<timeSlot.count{
                        calendarArray.insert(IntTuple(rowIndex: row , columnIndex: col))
                    }
                    
                } else if col > startCol && col == endCol{
                    for row in 0..<endRow {
                        calendarArray.insert(IntTuple(rowIndex: row , columnIndex: col))
                    }
                }
                
            }
            let title = event.title.prefix(20)
            print("일자컬럼 : \(String(describing: dayDiff)) 약속제목 \(title) 약속시작: \(startHourMin) 약속종료 \(endHourMin) ")
            /*
             for rowIndex in 0..<timeSlot.count {
             let scheduleTime = hourminStringToFourDigit(timeToConvert: timeSlot[rowIndex])
             if   scheduleTime >= startHourMin  && hourminStringToFourDigit(timeToConvert: timeSlot[rowIndex]) <= endHourMin  {
             calendarArray.insert(IntTuple(rowIndex: rowIndex , columnIndex: colIndex))
             
             print("\(timeSlot[rowIndex]) , \(startHourMin), \(endHourMin) time slot is in the row index \(rowIndex)")
             
             } else {
             print("\(timeSlot[rowIndex]) , \(startHourMin), \(endHourMin) time slot is outside row index \(rowIndex)")
             }
             } */
            print("calendarArrayCount \(calendarArray.count)")
        }
    }
}

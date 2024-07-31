import Foundation
import EventKit
import Combine

@MainActor
class EventViewModel : ObservableObject {

    @Published var startDate: Date = Date()
    @Published var endDate: Date = Date()
    @Published var calendarArray : Set<IntTuple> = []
    @Published var events : [EKEvent]  = []
    private var cancellables = Set<AnyCancellable>()
    
    private var timeSlot : [String] = ["12:00am", "12:30am","01:00am","01:30am","02:00am", "02:30am", "03:00am", "03:30am", "04:00am", "04:30am","05:00am", "05:30am", "06:00am","06:30am", "07:00am" ,"07:30am", "08:00am","08:30am", "09:00am", "09:30am", "10:00am", "10:30am", "11:00am", "11:30am", "12:00pm", "12:30pm","01:00pm","01:30pm","02:00pm", "02:30pm", "03:00pm", "03:30pm", "04:00pm", "04:30pm","05:00pm", "05:30pm", "06:00pm","06:30pm", "07:00pm" ,"07:30pm", "08:00pm", "09:00pm", "09:30pm", "10:00pm", "10:30pm", "11:00pm", "11:30pm", "midnight" ]
    
    init(sharedModel: SharedDateModel)   {

        
        setupBindings(sharedModel: sharedModel)
    }
    
    private func setupBindings(sharedModel: SharedDateModel) {
        Publishers.CombineLatest(sharedModel.$startDate,sharedModel.$endDate)
            .sink { [weak self]  start, end in
                self?.startDate = start
                self?.endDate = end
                Task {
                    await self?.getEvents()
                    await self?.moveEventsToCalendarArray()
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
        
        print("event count \(events.count)")
        print(" \(events)")
    }
    // UTC라고 가정하고 한국 시간에 맞게 모두 수정, 만약에 timeZone이있는 경우 그 시간으로 변경한후에 다시 한국시간으로 변겨
    func moveEventsToCalendarArray() async{
        
        var startHourMin : Int = 0
        var endHourMin : Int  = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        
        calendarArray.removeAll()
        
        for event in events {
          
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            
            // UTC 시간 출력
            dateFormatter.timeZone = TimeZone(identifier: "UTC")
            let utcDateString = dateFormatter.string(from: event.startDate )
            print("UTC 시간: \(utcDateString)")
            
            // 한국 시간 출력
            dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            let koreanDateString = dateFormatter.string(from: event.startDate)
            print("한국 시간: \(koreanDateString)")
            
            let dayDiff = daysBetween(start: startDate, end: event.startDate)
            
            print("\(event.title ?? "") \(dayDiff ?? 0)  \(koreanDateString)")
            
            let colIndex = dayDiff ?? 0
            
            if let startDate = event.startDate {
                startHourMin = hourminToFourDigit(timeToConvert: startDate) ?? 0
                print("startHourMin :  \(startHourMin)")
            }
            
            if let endDate = event.endDate {
                endHourMin = hourminToFourDigit(timeToConvert: endDate) ?? 0
                print("endHourMin :  \(endHourMin)")
                
            }
            
            for rowIndex in 0..<timeSlot.count {
                let scheduleTime = hourminStringToFourDigit(timeToConvert: timeSlot[rowIndex])
                if   scheduleTime >= startHourMin  && hourminStringToFourDigit(timeToConvert: timeSlot[rowIndex]) <= endHourMin  {
                    
                    
                    calendarArray.insert(IntTuple(rowIndex: rowIndex , columnIndex: colIndex))
                    
                    print("\(timeSlot[rowIndex]) , \(startHourMin), \(endHourMin) time slot is inside the range row index \(rowIndex)")
                    
                } else {
                    print("\(timeSlot[rowIndex]) , \(startHourMin), \(endHourMin) time slot is outside the index \(rowIndex)")
                }
            }
            print("calendarArrayCount \(calendarArray.count)")
        }
    }
}

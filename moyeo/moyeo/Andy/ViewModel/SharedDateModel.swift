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
    @Published var combinedDate:  CombinedDate?
    
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
   @Published var numberOfDays: Int {
        didSet {
            
            //updateEnd를 하면 치명적인 문제가 생기는데 왜지?????
            //Publisher문제로 추정됨
            // x -->(x, y) 로 해서 x 에 대한  Publisher만 고려하는것으로 정리끝.
            updateStart(date: startDate)
           
        }
    }
    
    @Published var endDateString : String
    @Published var startDateString : String
    
    private var isUpdating = false
    private var isUpdatingDates = false
    private var cancellables = Set<AnyCancellable>()
    //CurrentValueSubject도 되는데 초기값이 필요함.
   
    let currentValueSubjectStart = CurrentValueSubject<Date, Never>(Date())
    let currentValueSubjectEnd = CurrentValueSubject<Date, Never>(Date())
    let passthroughSubjectStart = PassthroughSubject<Date, Never>()
    let passthroughSubjectEnd = PassthroughSubject<Date, Never>()
    
    var count  = 0
    var receiveCount = 0
    
    init(startDate: Date = Date(), endDate: Date = Date(), numberOfDays: Int = 7) {
        self.startDate = startDate
        self.endDate = endDate
        self.numberOfDays = numberOfDays
        self.endDateString = ""
        self.startDateString = ""
        
        print("startDate in the init \(self.startDate)")
        setupBindings()
        
    }
    
    private func setupBindings() {
        
       $startDate
            .compactMap{
                self.TimeFixToZero(date:$0)
            }
            .sink { [weak self] date in
                guard let self = self else { 
                    print("sink error")
                    return }
                if !self.isUpdating {
                    print("SharedDateModel : startdate Publish \(date)")
                    updateEndFromStart(start: date)
                    updateStart(date: date)
                    
                    
                }
            }
            .store(in: &cancellables)
        
//        실제 한개 퍼블리셔로 간주하는게 맞을듯함
//        $endDate // Avoid initial value trigger
//            .compactMap{
//                //23:59:59 로 변경
//                self.TimeFixToMidNight(date:$0)
//            }
//            .sink { [weak self] date in
//                guard let self = self else { 
//                    print("sink error")
//                    return }
//                if !self.isUpdating {
//                    print("SharedDateModel : end date Publish \(date)")
//                    self.passthroughSubjectEnd.send(date)
//            
//                }
//            }
//            .store(in: &cancellables)
//        
//        
//        
//        let combinedPublisher = currentValueSubjectStart
//            .flatMap { value1 in
//                self.currentValueSubjectEnd.compactMap { value2 in
//                    if let endDate = self.getEndDateFromStart(date: value1) {
//                        self.count += 1
//                        let combined = CombinedDate(start: value1, end: endDate)
//                        print("PUB:# \(self.count)   id: \(combined.id) start: \(combined.start) end: \(combined.end)")
//                        return combined
//                    } else {return nil}
//                }
//            }
//            .eraseToAnyPublisher()
//        
//
//      

        
        // PassThroughSubject 로 구현
        let combinedPublisher2 = passthroughSubjectStart
            .compactMap { value1 in
                    if let endDate = self.getEndDateFromStart(date: value1) {
                        self.count += 1
                        let combined = CombinedDate(start: value1, end: endDate)
                        print("PUB:# \(self.count)   id: \(combined.id) start: \(combined.start) end: \(combined.end)")
                        return combined
                    } else {return nil}
                }
            .eraseToAnyPublisher()

        
        
        combinedPublisher2
              .receive(on: DispatchQueue.main)
              .sink(receiveCompletion: { completion in
                  switch completion {
                  case .finished:
                      print("SharedDateModel : combinedPublisher finished")
                  case .failure(let error):
                      print("SharedDateModel : combinedPublisher failed with error: \(error)")
                  }
              }, receiveValue: {[weak self] combinedDate in
                  guard let self = self else { return }
                  receiveCount += 1
                  print("REC#\(self.receiveCount) id:\(combinedDate.id)  start:\(combinedDate.start) end:\(combinedDate.end)")
                  
                  if  !self.isUpdating {
                      
                      self.isUpdating = true  // Set flag before update
                      self.startDate = combinedDate.start
                      print("startDate in the combinedPublisher.sink \(self.startDate)")
                      self.endDate = combinedDate.end
                      print("endDate in the combinedPublisher.sink \(self.endDate) ")
                      self.combinedDate = combinedDate
                      print("combinedDate id:\(combinedDate.id) start:\(combinedDate.start) end:\(combinedDate.end)")
                      self.isUpdating = false
                      
                      
                  }
              })
        
              .store(in: &cancellables)
    }
    
    
    func updateEndFromStart(start: Date) {
        
        if let endDate =  getEndDateFromStart(date: start) {
            print("updateEndFromStart send to  currentValueSubject  \(endDate)")
            updateEnd(date: endDate)
        }
    }
    
    private func getEndDateFromStart(date: Date) -> Date? {
        
        if let endDate = Calendar.current.date(byAdding: .day, value: numberOfDays, to: date) {
            
            print("getEndDateFromStart  start: \(date) end: \(endDate) numberOfDays: \(numberOfDays)")
            //23:59:59 초로해야할듯... 그럼 하루 빼야 하나?
            if let fixedDate =  TimeFixToMidNight(date: endDate) {
                return fixedDate
            }
            else {
                return nil
            }
        } else { return nil }
        
        
    }
    
    func updateStart(date: Date) {
        passthroughSubjectStart.send(date)
    }
    
    func updateEnd(date: Date) {
       passthroughSubjectEnd.send(date)
        print("updateEnd currentValueSubjectEnd  \(date)")
    }

    private func updateEndDate() {
        
        if let endDate = Calendar.current.date(byAdding: .day, value: numberOfDays, to: startDate) {
            updateEnd(date: endDate)
        }
        print("updateEndDate  currentValueSubject \(endDate)")
    }
    
    private func updateNumberOfDays() {
    
        numberOfDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    private  func TimeFixToZero(date : Date) ->Date?{
        var components = DateComponents()
        let calendar = Calendar.current
     
        components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let seoulTimeZone = TimeZone(identifier: "Asia/Seoul")!
        components.timeZone = seoulTimeZone
        
        if let date = calendar.date(from: components) {
            return date
        }
        else { return nil }
                                    
    }
    private  func TimeFixToMidNight(date : Date) ->Date?{
        var components = DateComponents()
        let calendar = Calendar.current
     
        components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 23
        components.minute = 59
        components.second = 59
        
        let seoulTimeZone = TimeZone(identifier: "Asia/Seoul")!
        components.timeZone = seoulTimeZone
        
        if let date = calendar.date(from: components) {
            return date
        }
        else {return nil}
                                    
    }
    private func  updateDates(){
        
        var components = DateComponents()
     
        
        let calendar = Calendar.current
        components = calendar.dateComponents([.year, .month, .day], from: startDate)
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let seoulTimeZone = TimeZone(identifier: "Asia/Seoul")!
        components.timeZone = seoulTimeZone
        
        if let startDate = calendar.date(from: components) {
           updateStart(date: startDate)
        }
   
        if let endDate =   calendar.date(byAdding: .day, value: numberOfDays, to: startDate){
          updateEnd(date: endDate)
        }
    }
}

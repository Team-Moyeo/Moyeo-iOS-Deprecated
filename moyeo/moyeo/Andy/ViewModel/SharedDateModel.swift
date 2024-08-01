//
//  SharedDateModel.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/31/24.
//

import Foundation

import SwiftUI
import Combine
/*
 @Published var startDate: Date {
     didSet {
          if !isUpdatingDates {
             updateStartAndEndDates()
          }
  
         startDateString = dateToDateString(date: startDate) ?? ""
             
         }
     }
 subscriber를 사용하지 않고 했다가 순환참조 문제와 가독성때문에 combine의  passthroughSubject 와 CurrentValueSubject를 적용.
 */// 추후에  local time 00:00 am으로 수정하는 함수 추가

class SharedDateModel: ObservableObject {
    

    
    
    //  순환참조 조심 didSet은 값이 변경되면 한번만 불러오고 종료되게.
    
    @Published var startDate: Date {
        didSet {
//            if !isUpdatingDates {
//                updateStartAndEndDates()
//            }
            updateEndDate()
            startDateString = dateToDateString(date: startDate) ?? ""
                
            }
        }
   
    @Published var endDate: Date {
        didSet{
            endDateString = dateToDateString(date: endDate) ?? ""
        }
        
    }
    
    @Published var numberOfDays: Int {
        didSet { 
            updateEndDate()
        }
    }
    
    @Published var endDateString : String
    @Published var startDateString : String
   
    private var isUpdating = false
    private var isUpdatingDates = false
    private var cancellables = Set<AnyCancellable>()
    //CurrentValueSubject도 되는데 초기값이 필요함.
    let passthroughSubject = PassthroughSubject<Date, Never>()
    let currentValueSubject = CurrentValueSubject<Date, Never>(Date())
    
    
    init(startDate: Date = Date(), endDate: Date = Date(), numberOfDays: Int = 7) {
       self.startDate = startDate
       self.endDate = endDate
       self.numberOfDays = numberOfDays
       self.endDateString = ""
       self.startDateString = ""
       print("startDate in the init \(self.startDate)")
        //updateDates()  // 초기화 시 startDate와 endDate를 설정합니다.
        setupBindings()
        
   }
    
    private func setupBindings() {
        
        // 순서가 중요
        // passthroughSubject.sink  -> $startDate.sink -> passthroughSubject.send
        // 만약 currentValueSubject로 한다면 currentValueSubject는 초기값을 갖을수있으므로..
        // $startDate.sink -> currentValueSubject.send -> currentValueSubject.sink
        
//        passthroughSubject
//                   .sink(receiveCompletion: { completion in
//                       switch completion {
//                       case .finished:
//                           print("PassthroughSubject finished")
//                       case .failure(let error):
//                           print("PassthroughSubject failed with error: \(error)")
//                       }
//                   }, receiveValue: {[weak self] value in
//                       guard let self = self else { return }
//                       print("passthroughSubject : \(value)")
//                       if  self.startDate != value {
//                           self.isUpdating = true  // Set flag before update
//                           self.startDate = value
//                           self.isUpdating = false
//                       }
//                   })
//                   .store(in: &cancellables)
//        
//      
      
      
        $startDate
            .map{
                self.startTimeFix(date:$0)
            }
    
            .sink(receiveCompletion: { completion in
                       switch completion {
                       case .finished:
                           print("Subscription finished")
                       case .failure(let error):
                           print("Subscription failed with error: \(error)")
                       }
                   }, receiveValue: { [weak self] value in
                       guard let self = self else { return }
                       if let value = value {
                           print("startDate.sink receive value \(String(describing: value))")
                       }
                       else {
                           print("startDate changed to nil")
                       }
                       // Check flag before processing
                       
                      if !(self.isUpdating), let newValue = value {
                        
//                           print("send to passthroughSubject \(newValue)")
//                           self.passthroughSubject.send(newValue)
//
//                         비교해보자
                           
                           print("send to currentValueSubject \(newValue)")
                           self.currentValueSubject.send(newValue)
                       }
                   })
        .store(in: &cancellables)
        
        currentValueSubject
                   .sink(receiveCompletion: { completion in
                       switch completion {
                       case .finished:
                           print("CurrentValueSubject finished")
                       case .failure(let error):
                           print("CurrentValueSubject failed with error: \(error)")
                       }
                   }, receiveValue: {[weak self] value in
                       guard let self = self else { return }
                       print("currentValueSubject.sink receive Value: \(value)")
                       if  self.startDate != value {
                           self.isUpdating = true  // Set flag before update
                           self.startDate = value
                           self.isUpdating = false
                       }
                   })
                   .store(in: &cancellables)
        
    
        
    }
   
    private func  updateStartAndEndDates() {
    
        updateDates()
    }

    private func updateEndDate() {
      
        endDate = Calendar.current.date(byAdding: .day, value: numberOfDays, to: startDate) ?? Date()
    }

    private func updateNumberOfDays() {
    
        numberOfDays = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    private  func startTimeFix(date : Date?) ->Date? {
        var components = DateComponents()
        let calendar = Calendar.current
        guard let date = date else { return nil }
        components = calendar.dateComponents([.year, .month, .day], from: date)
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let seoulTimeZone = TimeZone(identifier: "Asia/Seoul")!
        components.timeZone = seoulTimeZone
        
        if let date = calendar.date(from: components) {
          return date
        } else {
            
            return nil
        }
        
   
    }
    private func  updateDates(){
        
        var components = DateComponents()
     
        // recursive 를 피하자
        
        isUpdatingDates = true
        
        let calendar = Calendar.current
        components = calendar.dateComponents([.year, .month, .day], from: startDate)
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let seoulTimeZone = TimeZone(identifier: "Asia/Seoul")!
        components.timeZone = seoulTimeZone
        
        if let date = calendar.date(from: components) {
            self.startDate = date

        }
   
        if let endDate =   calendar.date(byAdding: .day, value: numberOfDays, to: startDate){
            self.endDate = endDate
            
        //recursive를 피하자
       
        }
        isUpdatingDates = false
    }
}

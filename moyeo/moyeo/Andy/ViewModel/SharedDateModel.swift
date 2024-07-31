//
//  SharedDateModel.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/31/24.
//

import Foundation

import SwiftUI
import Combine

// 추후에  local time 00:00 am으로 수정하는 함수 추가

class SharedDateModel: ObservableObject {
    
    @Published var startDate: Date {
        didSet {
            if !isUpdatingDates {
                updateStartAndEndDates()
            }
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
    private var cancellables = Set<AnyCancellable>()
    private var isUpdatingDates = false
    
    init(startDate: Date = Date(), endDate: Date = Date(), numberOfDays: Int = 7) {
       self.startDate = startDate
        self.endDate = endDate
       self.numberOfDays = numberOfDays
       self.endDateString = ""
       self.startDateString = ""
     
        updateDates()  // 초기화 시 startDate와 endDate를 설정합니다.
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
    
    private func  updateDates(){
        
        var components = DateComponents()
        var newComponents = DateComponents()
        // recursive 를 피하자
        
        isUpdatingDates = true
        
        let calendar = Calendar.current
        components = calendar.dateComponents([.year, .month, .day], from: startDate)
        components.hour = 0
        components.minute = 0
        components.second = 0
        
        let seoulTimeZone = TimeZone(identifier: "Asia/Seoul")!
        
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

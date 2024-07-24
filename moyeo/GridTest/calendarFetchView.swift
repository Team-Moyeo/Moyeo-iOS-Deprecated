//
//  calendarFetchView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/22/24.
//

import SwiftUI
import EventKit

struct calendarFetchView: View {
    @EnvironmentObject var storeManager: EventStoreManager
    
    @State var startDateString : String? = "2024-07-25"
    @State var endDateString : String?   = "2024-08-31"
   
    
    var body: some View {
        VStack{
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            
            
        }.onAppear(){
            // Get the appropriate calendar.
            

            Task{
               
                storeManager.eventStoreManagerConfig()
                
                if let events =  await storeManager.dataStore.fetchEventsFromTo(startDateString: startDateString, endDateString: endDateString)
                {   
                    print("events count \(events.count)")
                    
                    for event in events {
                        print(" event: \(event) ")
                    }
                    
                }
            }
            
            //            // Create the start date components
//            
//            let startDate =  dateStringToDate(dateString: startDateString)
//            let endDate = dateStringToDate(dateString: endDateString)
//           
//            if let startDate = startDate, let endDate = endDate {
//                //   predicate = store.predicateForEvents(withStart: anAgo, end: aNow, calendars: nil)
//                predicate = storeManager.dataStore.eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
//                
//            }
//            
//            
//            // Fetch all events that match the predicate.
//            
//            if let aPredicate = predicate {
//                events = storeManager.dataStore.eventStore.events(matching: aPredicate).sortedEventByAscendingDate()
//            }
//            
//            let filteredEvents = events?.filter { event in
//                      event.calendar.allowsContentModifications == true
//                  }
//                  
//            if let events = filteredEvents {
//                for event in events {
//                    
//                    print("event: \(event)")
//                }
//                
//            }
//            
        }
        
    }

    
    
}

#Preview {
    calendarFetchView()
        .environmentObject(EventStoreManager())
}

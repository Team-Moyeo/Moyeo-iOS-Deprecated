/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Manages full-access eventkit interactions.
*/

import EventKit


// EventDataStore를  actor로 선언해서 동기처럼 보여도 비동기 함수들임

extension EventDataStore {
    
    var isFullAccessAuthorized: Bool {
        if #available(iOS 17.0, *) {
            EKEventStore.authorizationStatus(for: .event) == .fullAccess
        } else {
            // Fall back on earlier versions.
            EKEventStore.authorizationStatus(for: .event) == .authorized
        }
    }

    /// Prompts the user for full-access authorization to Calendar.
    private func requestFullAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
          
            let ret =  try await eventStore.requestFullAccessToEvents()
       //     print("eventStore.requestFullAccessToEvents: \(ret)")
            return ret
        } else {
            // Fall back on earlier versions.
            return try await eventStore.requestAccess(to: .event)
        }
    }
    
    /// Verifies the authorization status for the app.
    func verifyAuthorizationStatus() async throws -> Bool {
        let status = EKEventStore.authorizationStatus(for: .event)
       
        switch status {
        case .notDetermined:
            return try await requestFullAccess()
        case .restricted:
            throw EventStoreError.restricted
        case .denied:
            throw EventStoreError.denied
        case .fullAccess:
            return true
        case .writeOnly:
            throw EventStoreError.upgrade
        @unknown default:
            throw EventStoreError.unknown
        }
    }
    
    /// Fetches all events occuring within a month in all the user's calendars.
    func fetchEvents() -> [EKEvent] {
        guard isFullAccessAuthorized else { return [] }
        let start = Date.now
        let end = start.oneMonthOut
        let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
        return eventStore.events(matching: predicate).sortedEventByAscendingDate()
    }
    
    
    func fetchEventsFromTo(startDateString: String?, endDateString : String?) -> [EKEvent]? {
       
        guard isFullAccessAuthorized else {
            print("fetchEvent auth error ")
            return nil
        }
        
        let start =  dateStringToDate(dateString: startDateString)
        let end = dateStringToDate(dateString: endDateString)
       
        if let start = start, let end = end {
            let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
            let events = eventStore.events(matching: predicate).sortedEventByAscendingDate()
            let filteredEvents = events.filter { event in

                event.calendar.allowsContentModifications == true
            }
            return filteredEvents
        }
        
        return nil
    }
    
    func fetchEventsFromTo(startDate:Date?, endDate : Date?) -> [EKEvent]? {
        
        guard isFullAccessAuthorized  else {
            print ("fetchEvent auth error ")
            return nil
        }
        
        if let start = startDate, let end = endDate {
            print("start: \(start) end : \(end)" )
            let predicate = eventStore.predicateForEvents(withStart: start, end: end, calendars: nil)
            let events = eventStore.events(matching: predicate).sortedEventByAscendingDate()
            let filteredEvents = events.filter { event in
                
                event.calendar.allowsContentModifications == true
                
            }
            
            print("filteredEvents Count \(filteredEvents.count)")
            
            return filteredEvents
        }
        
        return nil
    }
    /// Removes an event.
    private func removeEvent(_ event: EKEvent) throws {
        try self.eventStore.remove(event, span: .thisEvent, commit: false)
    }
    
    
    /// Batches all the remove operations.
    func removeEvents(_ events: [EKEvent]) throws {
        do {
            try events.forEach { event in
                try removeEvent(event)
            }
            try eventStore.commit()
        } catch {
            eventStore.reset()
            throw error
        }
    }
    
    
}


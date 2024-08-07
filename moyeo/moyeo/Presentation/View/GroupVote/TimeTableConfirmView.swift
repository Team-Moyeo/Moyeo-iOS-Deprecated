//
//  GroupConfirmView.swift
//  moyeo
//
//  Created by Giwoo Kim on 8/7/24.
//

import SwiftUI

struct TimeTableConfirmView: View {
    @ObservedObject var sharedDm : SharedDateModel
    
    @State private var fixedColumnWidth: CGFloat = 55
    @State private var fixedRowHeight : CGFloat = 30
    @State private var fixedHeaderHeight : CGFloat = 35
 
    @StateObject private var timeTHVm : TimeTableHeaderVM
    
   
 
    private var columns: [GridItem] {
        //첫번째 열은 timeSlot의  String 표시
        var gridItems: [GridItem] = []
        print("TimeTable number Of Columns:\(sharedDm.numberOfDays)")
        
        for _ in 0..<Int(sharedDm.numberOfDays) {
            gridItems.append(GridItem(.fixed(CGFloat(fixedColumnWidth)), spacing: spacing))
        }
        return gridItems
    }
    
    // items와 checkedStates 는 같은  array 인데..일단 둘다씀
    private let items = Array(1...48*7).map { "Item \($0)" }
    @State private var checkedStates: [Bool] = Array(repeating: false, count: 48 * 7 )
    
    @State private var allSchedule: [CGFloat] = Array(repeating: 0.0, count: 48 * 7 )
    
    private let padding: CGFloat = 10
    private let spacing: CGFloat = 0
    private var totalWidth : CGFloat { fixedColumnWidth * CGFloat(sharedDm.numberOfDays ) + spacing * CGFloat(sharedDm.numberOfDays-1) }
    private let screenWidth = UIScreen.main.bounds.width
    private var sidePadding :CGFloat {  max((screenWidth - totalWidth) / 2, 0) }
    
    @State private var  availableTimeSet: Set<String> =  []
    @State private var availableTimeTuple : Set<IntTuple> = []
 
    @State private var closingDate : String = ""
    // to change the number of columns
  
  
    // to change the number of rows for later use
  
    @State var numOfProfile : Int?

    @State private var showAlertImage = false
    @State private var showAllSchedule = true
 
    
    init(sharedDm: SharedDateModel) {
        self.sharedDm = sharedDm
        _timeTHVm = StateObject(wrappedValue: TimeTableHeaderVM(sharedModel:sharedDm))
       
    }
    
    
    
    var body: some View {
        
        // 현재 타임존의 시간을 기준
        // 시간과 분이 들어가서 정확하지 않는 일이 발생한다..참고할것.(ㅜㅜ
        //   createTestView()
        
        
        VStack(alignment: .leading, spacing : 10 ){
            HStack{
                
                Text("\(sharedDm.meetingName)")
                    .font(.title)
                
                Spacer()
                
                CircleImageListView()
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showAlertImage = true
                    }
                    .sheet(isPresented: $showAlertImage) {
                        MemberPopUpView()
                    }
                
            }
            Divider()
            
            HStack{
                Text("투표마감일")
                Spacer()
                Text("\(closingDate)")
            }   .font(.caption)
                .background(Color.gray)
                .onAppear(){
                    let calendar = Calendar.current
                    let dayComponent =  calendar.component(.day, from: sharedDm.selectedDate)
                    let weekdayComponent = calendar.component(.weekday, from: sharedDm.selectedDate)
                    let yearComponent = calendar.component(.year, from: sharedDm.selectedDate)
                    let monthComonent = calendar.component(.month, from: sharedDm.selectedDate)
                    let closingDateString =  "\(yearComponent)년 \(monthComonent)월 \(dayComponent)일(\(Weekday(rawValue: weekdayComponent)?.name ?? ""))"
                    closingDate = closingDateString
                }
            
            
            
            
            
            
            Grid(horizontalSpacing: 0,  verticalSpacing: 0 ) {
                // 헤더 행
                GridRow(){
                    ForEach(0..<timeTHVm.monthString.count, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 0) {
                            
                            HStack(alignment: .top, spacing: 0) {
                                
                                if index < timeTHVm.monthString.count  {
                                    Text(timeTHVm.monthString[index].isEmpty ? "" : "\(timeTHVm.monthString[index])월")
                                        .font(.system(size: 10))
                                        .foregroundColor(.gray)
                                    
                                    Text(timeTHVm.yearString[index].isEmpty ? "" : "\(String(timeTHVm.yearString[index].suffix(2)))년")
                                        .font(.system(size: 8))
                                        .foregroundColor(.gray)
                                }
                                
                            }
                            // Adjust the spacing between two sections
                            Spacer()
                            
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                
                                Text("\(timeTHVm.day[index])일")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                
                                Text("(\(timeTHVm.weekdayString[index]))")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            
                        }
                        .border(Color.white, width: 2)
                        .frame(width: fixedColumnWidth, height: fixedHeaderHeight)
                        
                    }
                    
                    
                }
            }  .padding(.horizontal, sidePadding)
                .padding(.vertical,0)
            
            ScrollViewReader { scrollViewProxy in
                ScrollView([.vertical], showsIndicators: true) {
                    
                    ZStack {
                        // 드래그 영역을 표시하는 투명한 레이어
                        
                        Rectangle()
                            .stroke(Color.blue, lineWidth: 0.5)
                            .background(Color.clear)
                            .padding(.vertical, padding)
                            .ignoresSafeArea(edges: .all)
                        
                        
                        LazyVGrid(columns: columns, spacing: spacing) {
                            // 데이터 행
                            //             let numberOfRows = (items.count + Int(sharedDm.numberOfDays) - 1) / Int(sharedDm.numberOfDays)
                            let numberOfRows = 48
                            ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                                GridRow {
                                    ForEach(0..<Int(sharedDm.numberOfDays) , id: \.self) { columnIndex in
                                        // -1 추가 column starts from 0 not 1
                                        let itemIndex = rowIndex * Int(sharedDm.numberOfDays) + columnIndex
                                        
                                        if itemIndex < items.count {
                                            
                                            ZStack {
                                                Rectangle()
                                                    .foregroundColor({
                                                        var color : Color = .white
                                                        if showAllSchedule {
                                                            
                                                            color = .green
                                                            
                                                        }
                                                        return color
                                                        
                                                    }())
                                                    .opacity(allSchedule[itemIndex])
                                                    .border(Color.white, width: 2)
                                                    .frame(width: fixedColumnWidth, height: fixedRowHeight)
                                                
                                                
                                                
                                                if columnIndex == 0 {
                                                    Text(timeSlot[rowIndex])
                                                        .font(.system(size: 10))
                                                        .frame(width: fixedColumnWidth, height: fixedRowHeight)
                                                        .background(Color.white.opacity(0.3))
                                                        .foregroundColor(Color.black)
                                                        .border(Color.white)
                                                        .fontWeight(.bold)
                                                }
                                            }
                                        }
                                        else {
                                            Spacer().frame(width:fixedColumnWidth, height: fixedRowHeight)
                                        }
                                    }
                                } .id(rowIndex)
                                
                            }
                            
                        }
                        .padding(.vertical, padding)
                        //  I used the pattern mathcing in switch, very concise!!
                        
                        
                    }
                    
                }.scrollTargetLayout()
                    .onAppear{
                        scrollViewProxy.scrollTo(timeSlot.firstIndex(of: "09:00am"), anchor: .top)
                    }
                
                    .coordinateSpace(name: "scroll")
                    .frame(height:450)
                
            } .background(Color.clear)
                .scrollTargetBehavior(.viewAligned)
            
            Button(action: {
                
                
                
            }) {
                Text("확정하기")
                    .font(.system(size: 20))
                    .padding(2)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }.frame(width: 300, height: 100 , alignment: .center)
            
            
        }
    }
    private func lastTwoDigits(year : Int) ->String {
        
        let yearString = String(year)
        return  String(yearString.suffix(2))
    }
    
    
    private func updateCheckboxesInArea(start: CGPoint, end: CGPoint) {
        guard let startIndex = indexForPosition(start) else { return }
        guard let endIndex = indexForPosition(end) else  { return }
        
        let rowRange = min(startIndex.row, endIndex.row)...max(startIndex.row, endIndex.row)
        let columnRange = min(startIndex.column, endIndex.column)...max(startIndex.column, endIndex.column)
        
        for row in rowRange {
            for column in columnRange {
                let itemIndex = row * Int(sharedDm.numberOfDays) + column
                if itemIndex < checkedStates.count && itemIndex >= 0  {
                    checkedStates[itemIndex].toggle()
                }
            }
        }
    }
    
    private func indexForPosition(_ position: CGPoint) -> (row: Int, column: Int)? {
        
        let adjustedX = position.x - sidePadding
        let adjustedY = position.y - padding
        
        
        if adjustedX <= 0 || adjustedY <= 0 || adjustedX > (fixedColumnWidth  * CGFloat(sharedDm.numberOfDays)  + spacing * CGFloat(sharedDm.numberOfDays - 1 )) {
            return nil
        }
        
        
        let rowIndex = Int((adjustedY ) / (fixedRowHeight + spacing))  // 각 체크박스의 높이가 50
        let columnIndex  = Int(adjustedX / (fixedColumnWidth + spacing))
//        print("(x, y) :   \(Int(adjustedX) ), \(Int(adjustedY)) ")
//        print("(row, col) \(rowIndex),\(columnIndex)")
//        print("(rowh colw) \(fixedRowHeight) , \(fixedColumnWidth) ")
        return (row: rowIndex, column: columnIndex)
    }
    
    func convertCheckedStatesToTimeTable(){
        
        var availableTimeSet :Set<String> = []
        let calendar = Calendar.current
       
        self.availableTimeSet.removeAll()
        for row in 0...47 {
            for col in 0..<Int(sharedDm.numberOfDays) {
                let index = row * Int(sharedDm.numberOfDays) + col
                if checkedStates[index] == true {
                    
                    
                    if  let targetDay = calendar.date(byAdding: .day, value: col , to: sharedDm.startDate), let dateString  = dateToDateString(date: targetDay) {
                        
                        let timeString  = timeSlot[row]
                        
                        let result = dateString  + " " +  timeString
                        
                        availableTimeSet.insert(result)
                        
                    }
                }
            }
        }
        
        self.availableTimeSet = Set(availableTimeSet.sorted())
        print("availableTimeSlot count \(self.availableTimeSet.count)")
        for item in availableTimeSet.sorted() {
            print(" timeslot: \(item)" )
        }
    }
    func convertAvailableTimeFromSetToTuple() {
        
  
        var row :Int = 0
        var col : Int = 0
        self.availableTimeTuple.removeAll()
        print("availableTimeSet.count \(availableTimeSet.count)")
        for item in availableTimeSet {
            let end = dateStringToDate(dateString: String(item.prefix(10))) ?? sharedDm.startDate
            if let  days = daysBetween(start: sharedDm.startDate, end: end ) {
                col = days
                print(" start : \(sharedDm.startDate) end:  \(end) daysDiff: \(col)")
            }
         
            if let timeslot = timeSlot.firstIndex(where: { $0.contains(String(item.suffix(7))) }) {
                
                row = timeslot
                print("item -> (Row, Col)  time: \(item.suffix(7))   (\(row) , \(col))")
               
                availableTimeTuple.insert(IntTuple(rowIndex: row, columnIndex: col))
            } else {
                
                print("time slot error")
            }
            

        }
        print("availableTimeTuple.count \(availableTimeTuple.count)")
        for item in availableTimeTuple {
            print(item)
        }
    }
    
   
    
    private func bindingForDatePicker(startDate: Binding<Date?>) -> Binding<Date> {
        return Binding(
            get: { startDate.wrappedValue ?? Date() },
            set: { newValue in startDate.wrappedValue = newValue }
        )
    }
    private func bindingForSlider(numberOfDays: Binding<CGFloat?>) -> Binding<CGFloat> {
        return Binding(
            get: { numberOfDays.wrappedValue ?? 7},
            set: { newValue in numberOfDays.wrappedValue = newValue }
        )
    }
    
    
    func createTestView() -> some View {
      
        VStack {
           HStack{
                DatePicker(
                    "StartDate",
                    selection:  $sharedDm.startDate,
                    displayedComponents:  [.date])
                .frame(height: 15)
               
               CircleImageListView()
                   .onTapGesture {
                       showAlertImage = true
                   }
               if showAlertImage  {
                   Color.black.opacity(0.4)
                       .edgesIgnoringSafeArea(.all)
                   
                   VStack {
                       Spacer()
                       MemberPopUpView()
                       Spacer()
                   }
                   .transition(.move(edge: .bottom))
                   .animation(.default, value: showAlertImage)
               }
               
               
           }
            
            Text("EndDate: \(String(describing: sharedDm.endDateString))")
                .font(.system(size: 11))
                .frame(alignment: .leading)
            
            
            HStack {
                
                Text("No of Days: \(Int(sharedDm.numberOfDays))")
                    .font(.system(size: 11))
                Slider(value: Binding(
                    get: { CGFloat(sharedDm.numberOfDays) },
                    set: { newValue in
                        sharedDm.numberOfDays = Int(newValue)
                    }
                ), in: 1...7, step: 1) {_ in
                    print("startDateString \(sharedDm.startDateString)")
                    print("endDateString \(sharedDm.endDateString)")
                }
            }
            
            HStack {
                Text("Column Width: \(fixedColumnWidth, specifier: "%.0f")")
                    .font(.system(size: 11))
                Slider(value: $fixedColumnWidth, in: 30...100, step: 1) {
                    //  Text("Fixed Column Width")
                }
            }
        }
    }
}



#Preview {
    
    TimeTableConfirmView(sharedDm: SharedDateModel(startDate: Date(), endDate: Date(), numberOfDays: 7))
    
}

   

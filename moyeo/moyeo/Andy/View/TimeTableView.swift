//
//  SwiftUIView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/20/24.


import SwiftUI

struct CheckboxItem {
    var isChecked: Bool
    var row: Int
    var column: Int
}

struct IntTuple: Hashable {
    let rowIndex: Int
    let columnIndex: Int
}
enum Weekday: Int {
    case sunday = 1
    case monday = 2
    case tuesday = 3
    case wednesday = 4
    case thursday = 5
    case friday = 6
    case saturday = 7
    
    var name: String {
        switch self {
        case .sunday:    return "일"
        case .monday:    return "월"
        case .tuesday:   return "화"
        case .wednesday: return "수"
        case .thursday:  return "목"
        case .friday:    return "금"
        case .saturday:  return "토"
        }
    }
}

var timeSlot : [String] = ["00:00am", "00:30am","01:00am","01:30am","02:00am", "02:30am", "03:00am", "03:30am", "04:00am", "04:30am","05:00am", "05:30am", "06:00am","06:30am", "07:00am" ,"07:30am", "08:00am","08:30am", "09:00am", "09:30am", "10:00am", "10:30am", "11:00am", "11:30am", "12:00am", "12:30pm","01:00pm","01:30pm","02:00pm", "02:30pm", "03:00pm", "03:30pm", "04:00pm", "04:30pm","05:00pm", "05:30pm", "06:00pm","06:30pm", "07:00pm" ,"07:30pm", "08:00pm", "09:00pm", "09:30pm", "10:00pm", "10:30pm", "11:00pm", "11:30pm", "12:00pm" ]


struct TimeTableView: View {
   
    @ObservedObject var sharedDm : SharedDateModel
    
    @State private var fixedColumnWidth: CGFloat = 55
    @State private var fixedRowHeight : CGFloat = 30
    @State private var fixedHeaderHeight : CGFloat = 35
   
    
    @State private var dragStart: CGPoint? = nil
    @State private var dragEnd: CGPoint? = nil
    @GestureState private var dragOffset: CGSize = .zero
    
    @State private var initialPosition: CGPoint? = nil
    @State private var dragActive: Bool = false
    @State private var totalDragOffset: CGSize = .zero
   
    

    @StateObject private var eventVm : EventViewModel
    @StateObject private var timeTHVm : TimeTableHeaderVM
    
    @State var isLongPressed : Bool =  false
    @State var allowHitTestingFlag: Bool  = false
    @State var rectAllowHitTestingFlag : Bool = true
 
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
    
    
    private let padding: CGFloat = 10
    private let spacing: CGFloat = 0
    private var totalWidth : CGFloat { fixedColumnWidth * CGFloat(sharedDm.numberOfDays ) + spacing * CGFloat(sharedDm.numberOfDays-1) }
    private let screenWidth = UIScreen.main.bounds.width
    private var sidePadding :CGFloat {  max((screenWidth - totalWidth) / 2, 0) }
    
    @State private var pressedPosition: CGPoint = .zero
    @State private var  dragArray: Set<IntTuple> = []
    @State private var contentOffset: CGFloat = 0.0
    
    @State private var  availableTimeSet: Set<String> =  []
    @State private var availableTimeTuple : Set<IntTuple> = []
 
    @State private var closingDate : String = ""
    // to change the number of columns
  
  
    // to change the number of rows for later use
  
    @State var numOfProfile : Int?

    @State private var showAlertImage = false
    @State private var showAlertVote = false
    @State private var showSchedule = false
    //    private let minY: CGFloat = -380
    //    private let maxY: CGFloat = 670
    //

   
    
    init(sharedDm: SharedDateModel) {
        self.sharedDm = sharedDm
        _timeTHVm = StateObject(wrappedValue: TimeTableHeaderVM(sharedModel:sharedDm))
        _eventVm = StateObject(wrappedValue: EventViewModel(sharedModel: sharedDm))
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
        
            HStack(spacing: 10){
                
                Button(action: {
                   
                    showSchedule.toggle()
                    
                }) {
                    Text(showSchedule == true ? "일정숨기기" : "일정보기")
                        .font(.system(size: 15))
                        .padding(2)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .frame(width: 80, height: 24)
                
                Spacer()
                Button(action: {
                    
                    deleteCheckAll()
                    
                }) {
                    Text("지우기")
                        .font(.system(size: 15))
                        .padding(2)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                }.frame(width: 80, height: 24)
                
                Spacer().frame(width: 8)
                
                Button(action: {
                    
                    allowHitTestingFlag.toggle()
                    if allowHitTestingFlag == false {
                        convertCheckedStatesToTimeTable()
                        convertAvailableTimeFromSetToTuple()
                    }
                }) {
                    Text(allowHitTestingFlag ?  "보내기": "선택하기")
                        .font(.system(size: 15))
                        .padding(2)
                        .background( allowHitTestingFlag ? Color.blue : Color.cyan)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                }.frame(width: 80, height: 24) // Adjust the width and height as needed
                
                
                Spacer()
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
                                                        if showSchedule {
                                                            if eventVm.calendarArray.contains(IntTuple(rowIndex: rowIndex, columnIndex: columnIndex)) {
                                                                
                                                                color = .blue
                                                            }
                                                        }
                                                        let index = rowIndex * Int(sharedDm.numberOfDays) + columnIndex
                                                        if checkedStates[index] == true {
                                                            color = .cyan
                                                        }
                                                        if dragArray.contains(IntTuple(rowIndex: rowIndex, columnIndex: columnIndex)) {
                                                            color = .red
                                                        }
                                                        return color
                                                        
                                                    }())
                                                    .border(Color.white, width: 2)
                                                    .frame(width: fixedColumnWidth, height: fixedRowHeight)
                                                
                                                
                                                
                                                
                                                
                                                
                                                //                                            CheckboxView(isChecked: $checkedStates[itemIndex], rowIndex: rowIndex, colIndex: columnIndex) {
                                                //                                                row, column in
                                                //                                                // 체크박스가 클릭될 때 실행되는 코드
                                                //                                                print("Checkbox clicked at row: \(row), column: \(column)")
                                                //                                            } .allowsHitTesting(false)
                                                //                                                .background(Color.mint)
                                                //                                                .frame(width: 20, height: 20)
                                                //                                                .border(Color.gray)
                                                //                                                .contentShape(Circle())
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
                        .allowsHitTesting(allowHitTestingFlag)
                        .padding(.vertical, padding)
                        //  I used the pattern mathcing in switch, very concise!!!
                        .gesture(
                            LongPressGesture(minimumDuration: 0.25, maximumDistance: 3)
                                .sequenced(before: DragGesture(minimumDistance: 3))
                                .onChanged { value in
                                    switch value {
                                    case .first(true):
                                        isLongPressed = true
                                        //     print("isLongPressed")
                                    case .second(true, let drag?):
                                        if isLongPressed {
                                            pressedPosition = drag.location
                                            if let coord = indexForPosition(pressedPosition) {
                                                dragArray.insert(IntTuple(rowIndex: coord.row, columnIndex: coord.column))
                                            }
                                        }
                                    default:
                                        break
                                    }
                                }
                                .onEnded { value in
                                    switch value {
                                    case .second(true, let drag?):
                                        if isLongPressed {
                                            pressedPosition = drag.location
                                            if let coord = indexForPosition(pressedPosition) {
                                                dragArray.insert(IntTuple(rowIndex: coord.row, columnIndex: coord.column))
                                            }
                                            applyDragPath()
                                            resetDragState()
                                        }
                                    default:
                                        break
                                    }
                                }
                                .exclusively(before: TapGesture()
                                    .onEnded {
                                        print("Tapped")
                                    }
                                    .simultaneously(with: DragGesture(minimumDistance: 0)
                                        .onEnded { value in
                                            pressedPosition = value.location
                                            //   print("start, loc in tap \(value.startLocation) \(value.location)")
                                            let dragDistance = sqrt(pow(value.translation.width, 2) +  pow(value.translation.height, 2))
                                            if dragDistance > 3 {
                                                // 작동 안하는데... 실제 첫번째 컬럼으로 스크롤할때 나머지 그리드셀 스크롤은 여기서 되는게 아님.
                                                print("scrollTarget")
                                                if value.translation.height > 0  {
                                                    let hidden  = -Int(contentOffset / fixedRowHeight)
                                                    let target = min(max(hidden - 10,0), hidden)
                                                    scrollViewProxy.scrollTo(target , anchor: .top)
                                                }
                                                if value.translation.height < 0 {
                                                    let hidden  = -Int(contentOffset / fixedRowHeight)
                                                    let target = min(hidden + 10, Int(1010 / fixedRowHeight))
                                                    scrollViewProxy.scrollTo(target , anchor: .top)
                                                    
                                                }
                                            } else {
                                                if let coord = indexForPosition(pressedPosition) {
                                                    let index = coord.row * Int(sharedDm.numberOfDays) + coord.column
                                                    if index < items.count && index >= 0 {
                                                        checkedStates[index].toggle()
                                                    }
                                                }
                                            }
                                        }
                                    )
                                )
                        )
                        
                        
                    } .background(GeometryReader { geometry -> Color in
                        DispatchQueue.main.async {
                            // orgin.y == minY
                            let offset = geometry.frame(in: .named("scroll")).minY
                            
                            if self.contentOffset != offset {
                                self.contentOffset = offset
                                
                            }
                            
                            self.adjustScroll(contentOffset: contentOffset)
                        }
                        return Color.clear
                    })
                    
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
                Text("투표완료하기")
                    .font(.system(size: 20))
                    .padding(2)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }.frame(width: 300, height: 100 , alignment: .center)
            
            
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
               
                Image(systemName: "star.fill")
                    .contextMenu(ContextMenu(menuItems: {
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("초대하기")
                        })
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("수정하기")
                        })
                        Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                            Text("그룹삭제하기")
                        })
                    }))
              
                
            }
        }
    }
    private func lastTwoDigits(year : Int) ->String {
        
        let yearString = String(year)
        return  String(yearString.suffix(2))
    }
    private func adjustScroll(contentOffset: CGFloat) {
        var adjustedOffset : CGFloat = 0
        let offset = contentOffset.truncatingRemainder(dividingBy: fixedRowHeight)
        
        if offset != 0 {
            let targetOffset = contentOffset - offset
            if abs(offset) > fixedRowHeight / 2 {
                
                 adjustedOffset = targetOffset + (fixedRowHeight) * (offset > 0 ? 1 : -1)
                
            }
            else {
                adjustedOffset = targetOffset
            }
            withAnimation {
                self.contentOffset = adjustedOffset
            }
        }
        
        
    }
    
    func applyDragPath() {
        
        for tuple in dragArray {
            let index = tuple.rowIndex * Int(sharedDm.numberOfDays) + tuple.columnIndex
            if index < items.count &&  index >= 0  {
                checkedStates[index].toggle() // 값 변경 로직
            }
            
        }
    }
    func resetDragState() {
        pressedPosition = .zero
        isLongPressed = false
        dragArray.removeAll()
    }
    
    func deleteCheckAll() {
        for i in 0..<checkedStates.count {
            checkedStates[i] = false
        }
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

struct CheckboxView: View {
    @Binding var isChecked: Bool
    
    var rowIndex : Int
    var colIndex : Int
    var onToggle: (Int, Int) -> Void
    
    var body: some View {
        Image(systemName: isChecked ? "checkmark.square" : "square")
            .resizable()
            .frame(width: 15, height: 15)
            .foregroundColor(isChecked ? .blue : .gray)
            .onTapGesture {
                isChecked.toggle()
                onToggle(rowIndex, colIndex)
            }
    }
}


#Preview {
    
    TimeTableView(sharedDm: SharedDateModel(startDate: Date(), endDate: Date(), numberOfDays: 7))
    
}

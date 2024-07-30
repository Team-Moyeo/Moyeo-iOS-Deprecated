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
struct DynamicGridWithDragSelection: View {
    @State private var numberOfColumns: Double = 7
    @State private var fixedColumnWidth: Double = 50
    var firstColumnWidth : Double { 0 }
    @State private var fixedRowHeight : Double = 30
    @State private var fixedHeaderHeight : Double = 35
    @State private var checkedStates: [Bool] = Array(repeating: false, count: 48 * 7 )
    
    @State private var dragStart: CGPoint? = nil
    @State private var dragEnd: CGPoint? = nil
    @GestureState private var dragOffset: CGSize = .zero
    @State private var initialPosition: CGPoint? = nil
    @State private var dragActive: Bool = false
    @State private var totalDragOffset: CGSize = .zero
    @State private var cellSize : CGSize = .zero
    
    @StateObject var eventViewModel =  EventViewModel()
    @StateObject var storeManager = EventStoreManager()
    
    @State var startDateString : String? = ""
    @State var endDateString : String?   = ""
    @State var isLongPressed : Bool =  false
    @State var allowHitTestingFlag: Bool  = false
    @State var rectAllowHitTestingFlag : Bool = true
    //    init(eventViewModel: EventViewModel){
    //
    //        self.eventViewModel = eventViewModel
    //    }
    
    private var columns: [GridItem] {
        //첫번째 열은 timeSlot의  String 표시
        var gridItems: [GridItem] = []
        //        gridItems.append(GridItem(.fixed(CGFloat(firstColumnWidth)), spacing: spacing))
        
        for _ in 0..<Int(numberOfColumns) {
            gridItems.append(GridItem(.fixed(CGFloat(fixedColumnWidth)), spacing: spacing))
        }
        return gridItems
    }
    
    // 이게 필요할일이 있을까?
    
    private let items = Array(1...48*7).map { "Item \($0)" }
    
    private let padding: CGFloat = 10
    private let spacing: CGFloat = 0
    private var totalWidth : CGFloat { fixedColumnWidth * (numberOfColumns ) + spacing * (numberOfColumns-1) + firstColumnWidth}
    private let screenWidth = UIScreen.main.bounds.width
    private var sidePadding :CGFloat {  max((screenWidth - totalWidth) / 2, 0) }
    
    @State private var pressedPosition: CGPoint = .zero
    @State private var  dragArray: Set<IntTuple> = []
    @State private var  availableTimeSet: Set<String> =  []
    @State private var availableTimeTuple : Set<IntTuple> = []
    @State private var scrollOffset: CGFloat = 0
    
    private var timeSlot : [String] =  ["00:00am", "00:30am","01:00am","01:30am","02:00am", "02:30am", "03:00am", "03:30am", "04:00am", "04:30am","05:00am", "05:30am", "06:00am","06:30am", "07:00am" ,"07:30am", "08:00am","08:30am", "09:00am", "09:30am", "10:00am", "10:30am", "11:00am", "11:30am", "12:00pm", "12:30pm","01:00pm","01:30pm","02:00pm", "02:30pm", "03:00pm", "03:30pm", "04:00pm", "04:30pm","05:00pm", "05:30pm", "06:00pm","06:30pm", "07:00pm" ,"07:30pm", "08:00pm", "09:00pm", "09:30pm", "10:00pm", "10:30pm", "11:00pm", "11:30pm", "midnight" ]
    /*
     let dateFormatter = DateFormatter()
     
     // 날짜 형식 지정 (여기서는 "yyyy-MM-dd" 형식 사용)
     dateFormatter.dateFormat = "yyyy-MM-dd"
     if let date = dateFormatter.date(from: dateString) {
     print(date)  // 2024-07-28 00:00:00 +0000
     } else {
     print("날짜 변환에 실패했습니다.")
     }
     */
    // to change the number of columns
    @State private var startDate = Date()
    @State private var endDate  = Date()
    
    // to change the number of rows for later use
    @State var startTime: String?
    @State var endTime: String?
    
    @State var numOfProfile : Int?
    @State private var showAlert = false
    //    private let minY: CGFloat = -380
    //    private let maxY: CGFloat = 670
    //
    @State var previousMonth : Int  = 0
    @State var currentMonth : Int = 0
    @State var previousYear : Int  = 0
    @State var currentYear : Int  = 0
    
    @State private var contentOffset: CGFloat = 0.0
    
    var body: some View {
        
        
        
        // 현재 타임존의 시간을 기준
        // 시간과 분이 들어가서 정확하지 않는 일이 발생한다..참고할것.(ㅜㅜ
        
        VStack(alignment: .leading, spacing : 10 ){
            HStack{
                DatePicker(
                    "StartDate",
                    selection: $startDate,
                    displayedComponents:  [.date])
                .onChange(of: startDate) {
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month, .day], from: startDate)
                    var newComponents = DateComponents()
                    
                    newComponents.year = components.year
                    newComponents.month = components.month
                    newComponents.day = components.day
                    newComponents.hour = 0
                    newComponents.minute = 0
                    newComponents.second = 0
                    
                    if let startDate = calendar.date(from: newComponents) {
                        self.startDate = startDate
                        
                        if let endDate  =  calendar.date(byAdding: .day, value: Int(numberOfColumns ), to: self.startDate)  {
                            self.endDate = endDate
                        }
                        print("self.endDate \(self.endDate)")
                    }
                    if let startDateString = dateToDateString(date: startDate) {
                        self.startDateString  = startDateString
                    }
                    if let endDateString = dateToDateString(date: endDate) {
                        self.endDateString = endDateString
                    }
                    
                }
                .onAppear() {
                    let calendar = Calendar.current
                    let components = calendar.dateComponents([.year, .month, .day], from: startDate)
                    var newComponents = DateComponents()
                    
                    newComponents.year = components.year
                    newComponents.month = components.month
                    newComponents.day = components.day
                    newComponents.hour = 0
                    newComponents.minute = 0
                    newComponents.second = 0
                    
                    if let startDate = calendar.date(from: newComponents) {
                        self.startDate = startDate
                        
                        self.endDate =  calendar.date(byAdding: .day, value: Int(numberOfColumns ), to: self.startDate) ?? self.startDate
                        print("self.endDate \(self.endDate)")
                    }
                    if let startDateString = dateToDateString(date: startDate) {
                        self.startDateString  = startDateString
                    }
                    if let endDateString = dateToDateString(date: endDate) {
                        self.endDateString = endDateString
                    }
                    
                    
                    
                }
                .frame(height: 20)
                
                
                
                CircleImageListView()
                    .onTapGesture {
                        showAlert = true
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Images are tapped"))
                    }
                
            }.onChange(of : startDate){
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: startDate)
                var newComponents = DateComponents()
                
                newComponents.year = components.year
                newComponents.month = components.month
                newComponents.day = components.day
                newComponents.hour = 0
                newComponents.minute = 0
                newComponents.second = 0
                if let startDate = calendar.date(from: newComponents) {
                    self.startDate = startDate
                    
                    if let endDate  =  calendar.date(byAdding: .day, value: Int(numberOfColumns ), to: self.startDate)  {
                        self.endDate = endDate
                    }
                    print("self.endDate \(self.endDate)")
                }
                if let startDateString = dateToDateString(date: startDate) {
                    self.startDateString  = startDateString
                }
                if let endDateString = dateToDateString(date: endDate) {
                    self.endDateString = endDateString
                }
                
            }
            
            Text("EndDate: \(String(describing: endDateString ?? ""))")
                .font(.system(size: 11))
                .frame(alignment: .leading)
                .onAppear() {
                    let calendar = Calendar.current
                    endDate = calendar.date(byAdding: .day, value: Int(numberOfColumns  ), to: startDate) ?? startDate
                    if let startDateString = dateToDateString(date: startDate) {
                        self.startDateString  = startDateString
                    }
                    if let endDateString = dateToDateString(date: endDate) {
                        self.endDateString = endDateString
                    }
                }
            
            HStack {
                
                Text("No of Days: \(Int(numberOfColumns))")
                    .font(.system(size: 11))
                Slider(value: $numberOfColumns  , in: 1...7, step: 1) {_ in
                    //  Text("Number of Columns")
                    
                    //fixedColumnWidth =
                    let calendar = Calendar.current
                    
                    if let endDate = calendar.date(byAdding: .day, value: Int(numberOfColumns ), to: startDate) {
                        self.endDate = endDate
                    }
                    startDateString = dateToDateString(date: startDate)
                    endDateString = dateToDateString(date: endDate)
                    
                    print("startDateString \(startDateString!)")
                    print("endDateString \(endDateString!)")
                }
            }
            
            
            HStack {
                Text("Column Width: \(fixedColumnWidth, specifier: "%.0f")")
                    .font(.system(size: 11))
                Slider(value: $fixedColumnWidth, in: 30...100, step: 1) {
                    //  Text("Fixed Column Width")
                }
            }
            HStack(spacing: 10){
                Button(action: {
                    Task {
                        print("getEvents in the View \(startDate) , \(endDate)")
                        await eventViewModel.getEvents(storeManager:storeManager, startDate:startDate, endDate:endDate)
                        await eventViewModel.moveEventsToCalendarArray()
                        
                    }
                    
                }) {
                    Text("칼렌다")
                        .font(.system(size: 11))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                }
                .frame(width: 100, height: 12)
                
                Button(action: {
                    
                    deleteCheckAll()
                    
                }) {
                    Text("지우기")
                        .font(.system(size: 11))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                }.frame(width: 100, height: 12)
                
                Button(action: {
                    
                    allowHitTestingFlag.toggle()
                    if allowHitTestingFlag == false {
                        convertCheckedStatesToTimeTable()
                        convertAvailableTimeFromSetToTuPle()
                    }
                }) {
                    Text("선택하기")
                        .font(.system(size: 11))
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                    
                }.frame(width: 150, height: 12)
            }
            
            
            
            Grid(horizontalSpacing: 0,  verticalSpacing: 0) {
                // 헤더 행
                
                let vm = TimeTableHeaderVM(startDate: startDate, numberOfColumns: Int(self.numberOfColumns))
              
                GridRow(){
                    //                    Text("")
                    //                        .frame(width: firstColumnWidth, height: fixedRowHeight - 15, alignment: .leading)
                    //                        .background(Color.gray.opacity(0.3))
                    //                        .foregroundColor(Color.mint)
                    //                        .border(Color.mint)
                    //                        .padding(0)
                    
                    
                    ForEach(0..<vm.monthString.count , id: \.self) { index in
                        VStack(alignment: .leading, spacing: 0) {
                            
                            HStack(alignment: .top, spacing: 0) {
                                
                                if index < vm.monthString.count  {
                                    
                                    Text(vm.monthString[index].isEmpty ? "" : "\(vm.monthString[index])월")
                                        .font(.system(size: 11))
                                        .foregroundColor(.gray)
                                    
                                    
                                    Text(vm.yearString[index].isEmpty ? "" : "\(String(vm.yearString[index].suffix(2)))년")
                                        .font(.system(size: 8))
                                        .foregroundColor(.gray)
                                }
                                
                                
                            }
                            // Adjust the spacing between two sections
                            Spacer()
                            
                            HStack(alignment: .firstTextBaseline, spacing: 0) {
                                
                                Text("\(vm.day[index])일")
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                
                                Text("(\(vm.weekdayString[index]))")
                                    .font(.system(size: 8))
                                    .foregroundColor(.gray)
                                
                            }
                            
                            
                            Spacer()
                            
                        }.frame(width:fixedColumnWidth, height:fixedHeaderHeight)
                            .onAppear(){
                                print("\(index)")
                            }
                            .padding(0)
                        //    .border(Color.blue)
                        
                    }
                }
                
            }
            .onAppear(){
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: startDate)
                var newComponents = DateComponents()
                
                newComponents.year = components.year
                newComponents.month = components.month
                newComponents.day = components.day
                newComponents.hour = 0
                newComponents.minute = 0
                newComponents.second = 0
                if let startDate = calendar.date(from: newComponents) {
                    self.startDate = startDate
                    
                    if let endDate  =  calendar.date(byAdding: .day, value: Int(numberOfColumns ), to: self.startDate)  {
                        self.endDate = endDate
                    }
                    print("self.endDate \(self.endDate)")
                }
                if let startDateString = dateToDateString(date: startDate) {
                    self.startDateString  = startDateString
                }
                if let endDateString = dateToDateString(date: endDate) {
                    self.endDateString = endDateString
                }
            }
            .onChange(of:startDate) {
                let calendar = Calendar.current
                let components = calendar.dateComponents([.year, .month, .day], from: startDate)
                var newComponents = DateComponents()
                
                newComponents.year = components.year
                newComponents.month = components.month
                newComponents.day = components.day
                newComponents.hour = 0
                newComponents.minute = 0
                newComponents.second = 0
                if let startDate = calendar.date(from: newComponents) {
                    self.startDate = startDate
                    
                    if let endDate  =  calendar.date(byAdding: .day, value: Int(numberOfColumns ), to: self.startDate)  {
                        self.endDate = endDate
                    }
                    print("self.endDate \(self.endDate)")
                }
                if let startDateString = dateToDateString(date: startDate) {
                    self.startDateString  = startDateString
                }
                if let endDateString = dateToDateString(date: endDate) {
                    self.endDateString = endDateString
                }
                
            }
            ScrollViewReader { scrollViewProxy in
                ScrollView([.vertical], showsIndicators: true) {
                    
                    ZStack {
                        // 드래그 영역을 표시하는 투명한 레이어
                        
                        Rectangle()
                            .stroke(Color.blue, lineWidth: 0.5)
                            .background(Color.clear)
                            .padding(padding)
                            .ignoresSafeArea(edges: .all)
                        
                        
                        LazyVGrid(columns: columns, spacing: spacing) {
                            // 데이터 행
                            //             let numberOfRows = (items.count + Int(numberOfColumns) - 1) / Int(numberOfColumns)
                            let numberOfRows = 48
                            ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                                GridRow {
                                    
                                    
                                    
                                    ForEach(0..<Int(numberOfColumns) , id: \.self) { columnIndex in
                                        // -1 추가 column starts from 0 not 1
                                        let itemIndex = rowIndex * Int(numberOfColumns) + columnIndex
                                        
                                        if itemIndex < items.count {
                                            
                                            ZStack {
                                                Rectangle()
                                                    .foregroundColor({
                                                        var color : Color = .white
                                                      
                                                        if eventViewModel.calendarArray.contains(IntTuple(rowIndex: rowIndex, columnIndex: columnIndex)) {
                                                            color = .blue
                                                        }
                                                        
                                                        let index = rowIndex * Int(numberOfColumns ) + columnIndex
                                                        
                                                        if checkedStates[index] == true {
                                                            color = .cyan
                                                        }
                                                        
                                                        if dragArray.contains(IntTuple(rowIndex: rowIndex, columnIndex: columnIndex)) {
                                                            color = .red
                                                        }
                                                        return color
                                                        
                                                    }())
                                                
                                                    .border(Color.white)
                                                    .frame(width: fixedColumnWidth, height: fixedRowHeight)
                                                    .background(GeometryReader { geometry in
                                                        Color.clear
                                                            .onAppear {
                                                                cellSize = geometry.size
                                                                //                                                            print("rectangle cell size \(cellSize)")
                                                            }
                                                        
                                                    })
                                                
                                                
                                                
                                                
                                                
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
                                                    VStack(alignment: .leading, spacing: 0){
                                                        Text(timeSlot[rowIndex])
                                                            .font(.system(size: 11))
                                                            .frame(width: fixedColumnWidth, height: fixedRowHeight)
                                                            .background(Color.white.opacity(0.3))
                                                            .foregroundColor(Color.gray)
                                                            .border(Color.white)
                                                        
                                                    }
                                                }
                                            }
                                        }
                                        //                                         else {
                                        //                                            Spacer().frame(width:fixedColumnWidth, height: fixedRowHeight)
                                        //                                        }
                                    }
                                } .id(rowIndex)
                            }
                            
                        }
                        .allowsHitTesting(allowHitTestingFlag)
                        .padding(padding)
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
                                                    let index = coord.row * Int(numberOfColumns  ) + coord.column
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
                    
                    
                }
                
                .coordinateSpace(name: "scroll")
                .frame(height:450)
                
            } .background(Color.clear)
            
            
        }
        
    }
    
    private func lastTwoDigits(year : Int) ->String {
        
        let yearString = String(year)
        return  String(yearString.suffix(2))
    }
    private func adjustScroll(contentOffset: CGFloat) {
        let offset = contentOffset.truncatingRemainder(dividingBy: fixedRowHeight)
        if offset != 0 {
            let targetOffset = contentOffset - offset
            //     if abs(offset) > fixedRowHeight / 2 {
            let adjustedOffset = contentOffset + (fixedRowHeight - abs(offset)) * (offset > 0 ? 1 : -1)
            withAnimation {
                scrollOffset = adjustedOffset
            }
            //        } else {
            withAnimation {
                scrollOffset = targetOffset
            }
            //        }
        }
    }
    
    func applyDragPath() {
        
        for tuple in dragArray {
            let index = tuple.rowIndex * Int(numberOfColumns  ) + tuple.columnIndex
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
                let itemIndex = row * Int(numberOfColumns) + column
                if itemIndex < checkedStates.count && itemIndex >= 0  {
                    checkedStates[itemIndex].toggle()
                }
            }
        }
    }
    
    private func indexForPosition(_ position: CGPoint) -> (row: Int, column: Int)? {
        
        let adjustedX = position.x - sidePadding
        let adjustedY = position.y - padding
        
        
        if adjustedX <= 0 || adjustedY <= 0 || adjustedX > (fixedColumnWidth  * numberOfColumns  + spacing * (numberOfColumns - 1 )) {
            return nil
        }
        
        
        let rowIndex = Int((adjustedY ) / (fixedRowHeight + spacing))  // 각 체크박스의 높이가 50
        let columnIndex  = Int(adjustedX / (fixedColumnWidth + spacing))
        print("(x, y) :   \(Int(adjustedX) ), \(Int(adjustedY)) ")
        print("(row, col) \(rowIndex),\(columnIndex)")
        print("(rowh colw) \(fixedRowHeight) , \(fixedColumnWidth), \(firstColumnWidth) ")
        return (row: rowIndex, column: columnIndex)
    }
    func convertCheckedStatesToTimeTable(){
        
        var availableTimeSet :Set<String> = []
        let calendar = Calendar.current
        let timeSlot : [String] = ["00:00am", "00:30am","01:00am","01:30am","02:00am", "02:30am", "03:00am", "03:30am", "04:00am", "04:30am","05:00am", "05:30am", "06:00am","06:30am", "07:00am" ,"07:30am", "08:00am","08:30am", "09:00am", "09:30am", "10:00am", "10:30am", "11:00am", "11:30am", "12:00pm", "12:30pm","01:00pm","01:30pm","02:00pm", "02:30pm", "03:00pm", "03:30pm", "04:00pm", "04:30pm","05:00pm", "05:30pm", "06:00pm","06:30pm", "07:00pm" ,"07:30pm", "08:00pm", "09:00pm", "09:30pm", "10:00pm", "10:30pm", "11:00pm", "11:30pm", "midnight" ]
        self.availableTimeSet.removeAll()
        for row in 0...47 {
            for col in 0..<Int(numberOfColumns) {
                let index = row * Int(numberOfColumns) + col
                if checkedStates[index] == true {
                    
                    
                    if  let targetDay = calendar.date(byAdding: .day, value: col , to: startDate), let dateString  = dateToDateString(date: targetDay) {
                        
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
    func convertAvailableTimeFromSetToTuPle() {
        
        let timeSlot : [String] = ["00:00am", "00:30am","01:00am","01:30am","02:00am", "02:30am", "03:00am", "03:30am", "04:00am", "04:30am","05:00am", "05:30am", "06:00am","06:30am", "07:00am" ,"07:30am", "08:00am","08:30am", "09:00am", "09:30am", "10:00am", "10:30am", "11:00am", "11:30am", "12:00pm", "12:30pm","01:00pm","01:30pm","02:00pm", "02:30pm", "03:00pm", "03:30pm", "04:00pm", "04:30pm","05:00pm", "05:30pm", "06:00pm","06:30pm", "07:00pm" ,"07:30pm", "08:00pm", "09:00pm", "09:30pm", "10:00pm", "10:30pm", "11:00pm", "11:30pm", "midnight" ]
        var row :Int = 0
        var col : Int = 0
        self.availableTimeTuple.removeAll()
        print("availableTimeSet.count \(availableTimeSet.count)")
        for item in availableTimeSet {
            if let  days = daysBetween(start: startDate, end: dateStringToDate(dateString: String(item.prefix(10)))  ?? startDate ) {
                
                
                col = days
              
            }
         
            if let timeslot =  timeSlot.firstIndex(of: String(item.suffix(7)) ) {
                row = timeslot
               
            } else {
                
                print("time slot error")
            }
            
            print("row \(row) col \(col) in availableTimeSlot")
            
            availableTimeTuple.insert(IntTuple(rowIndex: row, columnIndex: col))
        }
        print("availableTimeTuple.count \(availableTimeTuple.count)")
        for item in availableTimeTuple {
            print(item)
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


struct DynamicGridWithDragSelection_Previews: PreviewProvider {
    static var previews: some View {
        DynamicGridWithDragSelection()
    }
}

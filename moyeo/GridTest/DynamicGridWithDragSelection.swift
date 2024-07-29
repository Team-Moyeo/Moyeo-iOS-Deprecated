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
    @State private var numberOfColumns: Double = 8
    @State private var fixedColumnWidth: Double = 30
    var firstColumnWidth : Double { fixedColumnWidth + 22}
    @State private var fixedRowHeight : Double = 30
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
    
//    init(eventViewModel: EventViewModel){
//        
//        self.eventViewModel = eventViewModel
//    }

    private var columns: [GridItem] {
        //첫번째 열은 timeSlot의  String 표시
        var gridItems: [GridItem] = []
        gridItems.append(GridItem(.fixed(CGFloat(firstColumnWidth)), spacing: spacing))
        
        for _ in 1..<Int(numberOfColumns) {
            gridItems.append(GridItem(.fixed(CGFloat(fixedColumnWidth)), spacing: spacing))
        }
        return gridItems
    }
    
    // 이게 필요할일이 있을까?
    
    private let items = Array(1...48*7).map { "Item \($0)" }
    
    private let padding: CGFloat = 10
    private let spacing: CGFloat = 0
    private var totalWidth : CGFloat { fixedColumnWidth * (numberOfColumns - 1) + spacing * (numberOfColumns - 1) + firstColumnWidth}
    private let screenWidth = UIScreen.main.bounds.width
    private var sidePadding :CGFloat {  max((screenWidth - totalWidth) / 2, 0) }
    
    @State private var pressedPosition: CGPoint = .zero
    @State private var  dragArray: Set<IntTuple> = []
    @State private var scrollOffset: CGSize = .zero
    
    private var timeSlot : [String] = ["12:00am", "12:30am","01:00am","01:30am","02:00am", "02:30am", "03:00am", "03:30am", "04:00am", "04:30am","05:00am", "05:30am", "06:00am","06:30am", "07:00am" ,"07:30am", "08:00am","08:30am", "09:00am", "09:30am", "10:00am", "10:30am", "11:00am", "11:30am", "12:00pm", "12:30pm","01:00pm","01:30pm","02:00pm", "02:30pm", "03:00pm", "03:30pm", "04:00pm", "04:30pm","05:00pm", "05:30pm", "06:00pm","06:30pm", "07:00pm" ,"07:30pm", "08:00pm", "09:00pm", "09:30pm", "10:00pm", "10:30pm", "11:00pm", "11:30pm", "midnight" ]
    
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
    private let minY: CGFloat = -380
    private let maxY: CGFloat = 670
    
    var body: some View {
      
        VStack {
            
            // 현재 타임존의 시간을 기준
            // 시간과 분이 들어가서 정확하지 않는 일이 발생한다..참고할것.(ㅜㅜ
            
            VStack(alignment: .leading, spacing: 10){
                HStack{
                    DatePicker(
                        "StartDate",
                        selection: $startDate,
                        displayedComponents:  [.date])
                    .frame(height: 40)
                    
                    .frame(height: 40)
                    
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
                        
                        self.endDate =  calendar.date(byAdding: .day, value: Int(numberOfColumns), to: self.startDate) ?? self.startDate
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
                    .frame(alignment: .leading)
                    .onAppear() {
                        let calendar = Calendar.current
                        endDate = calendar.date(byAdding: .day, value: Int(numberOfColumns), to: startDate) ?? startDate
                        if let startDateString = dateToDateString(date: startDate) {
                            self.startDateString  = startDateString
                        }
                        if let endDateString = dateToDateString(date: endDate) {
                            self.endDateString = endDateString
                        }
                    }
                
                HStack {
                    
                    Text("No of Columns: \(Int(numberOfColumns))").font(.footnote)
                    Slider(value: $numberOfColumns, in: 1...8, step: 1) {_ in
                        //  Text("Number of Columns")
                        
                        //fixedColumnWidth =
                        let calendar = Calendar.current
                        
                        if let endDate = calendar.date(byAdding: .day, value: Int(numberOfColumns), to: startDate) {
                            self.endDate = endDate
                        }
                        startDateString = dateToDateString(date: startDate)
                        endDateString = dateToDateString(date: endDate)
                    }
                    
                }
                HStack {
                    Text("Column Width: \(fixedColumnWidth, specifier: "%.0f")").font(.footnote)
                    Slider(value: $fixedColumnWidth, in: 30...100, step: 1) {
                        //  Text("Fixed Column Width")
                    }
                }
                HStack{
                    Button(action: {
                        Task {
                            print("getEvents in the View \(startDate) , \(endDate)")
                            await eventViewModel.getEvents(storeManager:storeManager, startDate:startDate, endDate:endDate)
                            await eventViewModel.moveEventsToCalendarArray()
                            
                        }
                        
                    }) {
                        Text("일정가져오기")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .frame(width: 160, height: 25)
                    
                    Button(action: {
                        
                        deleteCheckAll()
                        
                    }) {
                        Text("일정지우기")
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                    }.frame(width: 160, height: 25)
                    
                }.padding()
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
                            // 헤더 행
                            GridRow {
                                Text("")
                                    .frame(width: firstColumnWidth, height: fixedRowHeight*2)
                                    .background(Color.gray.opacity(0.3))
                                    .foregroundColor(Color.mint)
                                    .border(Color.mint)
                                ForEach(1..<Int(numberOfColumns), id: \.self) { index in
                                    let dateString = startDateString
                                    if let dayFromDateString = dayFromDateString(dateString: dateString, dateOffset: index - 1 ), let weekdayNumberFromDateString = weekdayFromDateString(dateString: dateString, dateOffset: index - 1 ) {
                                        VStack(spacing:0){
                                            Text(" \(dayFromDateString)")
                                                .font(.footnote)
                                                .frame(width: fixedColumnWidth, height: fixedRowHeight)
                                                .foregroundColor(Color.mint)
                                                .background(Color.gray.opacity(0.3))
                                                .border(Color.mint)
                                                .padding(0)
                                            if  let weekDayString =  Weekday(rawValue: weekdayNumberFromDateString)?.name {
                                                
                                                Text(" (\(weekDayString))")
                                                    .font(.footnote)
                                                    .frame(width: fixedColumnWidth, height: fixedRowHeight)
                                                    .foregroundColor(Color.mint)
                                                    .background(Color.gray.opacity(0.3))
                                                    .border(Color.mint)
                                                
                                            }
                                        }
                                    }
                                }
                            }
                            
                            // 데이터 행
                            //             let numberOfRows = (items.count + Int(numberOfColumns) - 1) / Int(numberOfColumns)
                            let numberOfRows = 48
                            ForEach(0..<numberOfRows, id: \.self) { rowIndex in
                                GridRow {
                                    
                                    Text(timeSlot[rowIndex])
                                        .frame(width: fixedColumnWidth + 22, height: fixedRowHeight)
                                        .background(Color.gray.opacity(0.3))
                                        .foregroundColor(Color.mint)
                                        .border(Color.mint)
                                        .font(.footnote)
                                        .allowsHitTesting(false)
                                    
                                    
                                    ForEach(0..<Int(numberOfColumns) - 1 , id: \.self) { columnIndex in
                                        // -1 추가 column starts from 0 not 1
                                        let itemIndex = rowIndex * Int(numberOfColumns - 1) + columnIndex
                                        
                                        if itemIndex < items.count {
                                            
                                            ZStack {
                                                Rectangle()
                                                    .foregroundColor({
                                                        if dragArray.contains(IntTuple(rowIndex: rowIndex, columnIndex: columnIndex)) {
                                                            return .red
                                                        } else if eventViewModel.calendarArray.contains(IntTuple(rowIndex: rowIndex, columnIndex: columnIndex)) {
                                                            return .blue
                                                        } else {
                                                            return .green
                                                        }
                                                    }())
                                                
                                                    .frame(width: fixedColumnWidth, height: fixedRowHeight)
                                                    .background(GeometryReader { geometry in
                                                        Color.clear
                                                            .onAppear {
                                                                cellSize = geometry.size
                                                                //                                                            print("rectangle cell size \(cellSize)")
                                                            }
                                                        
                                                    })
                                                //                                                .onTapGesture {
                                                //
                                                //                                                    let index = rowIndex * (numberOfColumns - 1 ) + columnIndex
                                                //                                                    checkedStates[index] =
                                                //                                                }
                                                
                                                CheckboxView(isChecked: $checkedStates[itemIndex], rowIndex: rowIndex, colIndex: columnIndex) {
                                                    row, column in
                                                    // 체크박스가 클릭될 때 실행되는 코드
                                                    print("Checkbox clicked at row: \(row), column: \(column)")
                                                } .allowsHitTesting(false)
                                                
                                                    .background(Color.mint)
                                                    .frame(width: 20, height: 20)
                                                
                                                    .border(Color.gray)
                                                    .contentShape(Circle())
                                                
                                            }
                                            
                                        } else {
                                            Spacer().frame(width:fixedColumnWidth, height: fixedRowHeight)
                                        }
                                    }
                                } .id(rowIndex)
                            }
                            
                        }
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
                                                    scrollViewProxy.scrollTo(0, anchor: .top)
                                                }
                                                if value.translation.height < 0 {
                                                    
                                                    scrollViewProxy.scrollTo(47, anchor: .bottom)
                                                }
                                                
                                                
                                               
                                                
                                            } else {
                                                if let coord = indexForPosition(pressedPosition) {
                                                    let index = coord.row * Int(numberOfColumns - 1 ) + coord.column
                                                    if index < items.count && index >= 0 {
                                                        checkedStates[index].toggle()
                                                    }
                                                }
                                            }
                                        }
                                    )
                                )
                        )
                        
                        //                    .gesture(
                        //                        LongPressGesture(minimumDuration: 0.3, maximumDistance: 0)
                        //                                          .onEnded { value in
                        //                                              isLongPressed = true
                        //                                              print("islongPressed \(isLongPressed)")
                        //
                        //                                          }
                        //                                          .sequenced(before: DragGesture(minimumDistance: 0)
                        //                                              .onChanged { value in
                        //                                                  if isLongPressed {
                        //                                                      if initialPosition == nil {
                        //                                                          //initialPosition -> dragStart -> dragEnd ->dragEnd-> dragEnd
                        //                                                          initialPosition = value.startLocation
                        //                                                      }
                        //                                                      dragStart = value.startLocation
                        //                                                      if let dragStart = dragStart, let coord = indexForPosition(dragStart) {
                        //                                                          dragArray.insert(IntTuple(rowIndex: coord.row, columnIndex: coord.column))
                        //                                                      }
                        //
                        //                                                      totalDragOffset = value.translation
                        //                                                      dragEnd = value.location
                        //                                                      // 일단은 dummy for testing
                        //                                                      dragActive = true
                        //                                                      if let dragEnd = dragEnd, let coord = indexForPosition(dragEnd) {
                        //
                        //                                                          dragArray.insert(IntTuple(rowIndex: coord.row, columnIndex: coord.column))
                        //
                        //                                                      }
                        //                                                  }
                        //                                              }
                        //
                        //                                              .onEnded { value in
                        //                                                  if  isLongPressed {
                        //                                                      applyDragPath()
                        //                                                      dragActive = false
                        //                                                      initialPosition = nil
                        //                                                      totalDragOffset = .zero
                        //                                                      dragStart = nil
                        //                                                      dragEnd = nil
                        //                                                      dragArray.removeAll()
                        //                                                      isLongPressed = false
                        //                                                  }
                        //                                              }
                        //                                          )
                        //                                  )
                        //
                        //
                    }
                    
                    
                }
            } .background(Color.clear)
           
            
        }
    }
    
    func dayFromDateString(dateString: String?, dateOffset: Int) -> Int? {
        
        guard let dateString = dateString else { return nil}
        let dateFormatter = DateFormatter()
        
        // 날짜 형식 지정 (여기서는 "yyyy-MM-dd" 형식 사용)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 문자열을 Date 객체로 변환
        if let date = dateFormatter.date(from: dateString) {
            // Calendar 인스턴스 생성
            let calendar = Calendar.current
            
            // DateComponents를 사용하여 하루를 추가
            if  let targetDay = calendar.date(byAdding: .day, value: dateOffset, to: date) {
                let dayComponent = calendar.component(.day, from: targetDay)
                return dayComponent
                
            }
        }
       
            return nil
        
    }
    
    
    // 1은 일요일, 2는 월요일, ... , 7은 토요일
    func weekdayFromDateString(dateString: String?, dateOffset: Int) -> Int? {
        
        guard let dateString = dateString else { return nil}
        let dateFormatter = DateFormatter()
        
        // 날짜 형식 지정 (여기서는 "yyyy-MM-dd" 형식 사용)
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // 문자열을 Date 객체로 변환
        if let date = dateFormatter.date(from: dateString) {
            // Calendar 인스턴스 생성
            let calendar = Calendar.current
            
            // DateComponents를 사용하여 하루를 추가
            if  let targetDay = calendar.date(byAdding: .day, value: dateOffset, to: date) {
                let weekdayComponent = calendar.component(.weekday, from: targetDay)
                return weekdayComponent
                
            }
        }
        
        return nil
    }
    func applyDragPath() {
      
        for tuple in dragArray {
            let index = tuple.rowIndex * Int(numberOfColumns - 1 ) + tuple.columnIndex
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
    
//    박스형 레인지는 필요 없어 보임. 일단 주석처리
//    func applySelectionChange() {
//        guard let initialPosition = initialPosition else { return }
//        print("InitialPosition  ( \(Int(initialPosition.x)) , \(Int(initialPosition.y)) ) ")
//        print("dragOffset in total (\(Int(totalDragOffset.width)) ,\(Int(totalDragOffset.height))")
//        print("sidePadding \(sidePadding) , padding : \(padding) , spacing : \(spacing)")
//        // 초기 위치와 최종 드래그 위치를 사용하여 선택된 영역을 계산
//        let adjustedX = initialPosition.x - sidePadding
//        let adjustedY = initialPosition.y - padding - fixedRowHeight
//        
//        print("adjustedX: \(Int(adjustedX))  , adjustedY : \(Int(adjustedY))")
//        if adjustedX <= 0 || adjustedX > (fixedColumnWidth + spacing) * numberOfColumns {
//            return
//        }
//        let initialRow = Int((adjustedY ) / (fixedRowHeight + spacing)) - 1 // 각 체크박스의 높이가 50
//        let initialColumn = Int(adjustedX / (fixedColumnWidth + spacing))
//        
//        if initialRow < 0 || initialColumn < 0 {
//            return
//        }
//        let finalRow = Int((adjustedY + totalDragOffset.height ) / (fixedRowHeight + spacing)) - 1
//        let finalColumn = Int((adjustedX + totalDragOffset.width ) / (fixedColumnWidth + spacing))
//        
//        
//        print("initial row, col (\(initialRow) , \(initialColumn) )")
//        print("final row, col (\(finalRow) , \(finalColumn))")
//        
//        let minRow = max(min(initialRow, finalRow), 0)
//        let maxRow = max(max(initialRow, finalRow), 0)
//        let minColumn = min(initialColumn, finalColumn,  Int(numberOfColumns) - 1 )
//        let maxColumn = min(max(initialColumn, finalColumn) , Int(numberOfColumns) - 1 )
//        
//        for row in minRow...maxRow {
//            for column in minColumn...maxColumn {
//                let position = row * Int(numberOfColumns) + column
//                if position < items.count &&  position >= 0  {
//                    checkedStates[position].toggle() // 값 변경 로직
//                }
//            }
//        }
//    }
//    
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
        
        let adjustedX = position.x - sidePadding - firstColumnWidth
        let adjustedY = position.y - padding - fixedRowHeight - fixedRowHeight
        
        
        if adjustedX <= 0 || adjustedY <= 0 || adjustedX > (fixedColumnWidth + spacing) * (numberOfColumns - 1) {
            return nil
        }
        
        
        let rowIndex = Int((adjustedY ) / (fixedRowHeight + spacing))  // 각 체크박스의 높이가 50
        let columnIndex  = Int(adjustedX / (fixedColumnWidth + spacing))
        print("(x, y) :   \(Int(adjustedX) ), \(Int(adjustedY)) ")
        print("(row, col) \(rowIndex),\(columnIndex)")
        print("(rowh colw) \(fixedRowHeight) , \(fixedColumnWidth), \(firstColumnWidth) ")
        return (row: rowIndex, column: columnIndex)
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

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

let timeSlot : [String] = ["00:00am", "00:30am","01:00am","01:30am","02:00am", "02:30am", "03:00am", "03:30am", "04:00am", "04:30am","05:00am", "05:30am", "06:00am","06:30am", "07:00am" ,"07:30am", "08:00am","08:30am", "09:00am", "09:30am", "10:00am", "10:30am", "11:00am", "11:30am", "12:00am", "12:30pm","01:00pm","01:30pm","02:00pm", "02:30pm", "03:00pm", "03:30pm", "04:00pm", "04:30pm","05:00pm", "05:30pm", "06:00pm","06:30pm", "07:00pm" ,"07:30pm", "08:00pm", "09:00pm", "09:30pm", "10:00pm", "10:30pm", "11:00pm", "11:30pm", "12:00pm" ]
let timeSlot2 : [String] = ["00:00", "00:30","01:00","01:30","02:00", "02:30am", "03:00", "03:30","04:00", "04:30","05:00", "05:30", "06:00","06:30", "07:00" ,"07:30", "08:00","08:30", "09:00", "09:30", "10:00", "10:30", "11:00", "11:30", "12:00", "12:30","13:00","13:30","14:00", "14:30", "15:00", "15:30", "16:00", "16:30", "17:00", "17:30","18:00","18:30", "19:00","19:30", "20:00", "20:30", "21:00", "21:30", "22:00", "22:30", "23:00", "23:30", "24:00" ]


struct TimeTableView: View {
    
    @ObservedObject var sharedDm : SharedDateModel
    
    @State private var fixedColumnWidth: CGFloat = 55
    @State private var fixedRowHeight : CGFloat = 30
    @State private var fixedHeaderHeight : CGFloat = 35
    @State private var isManager : Bool = true
    
    
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
    
    @State private var pressedPosition: CGPoint = .zero
    @State private var  dragArray: Set<IntTuple> = []
    @State private var contentOffset: CGFloat = 0.0
    
    @State private var  availableTimeSet: Set<String> =  []
    @State private var availableTimeTuple : Set<IntTuple> = []
    @State var serverCandidateTimes : [Int] = []
    @State private var closingDate : String = ""
    // to change the number of columns
    
    
    // to change the number of rows for later use
    
    @State var numOfProfile : Int?
    
    @State private var showAlertImage = false
    @State private var showAlertVote = false
    @State private var showSchedule = false
    @State private var showAllSchedule = false
    @State private var  showTimeTableConfirmView = false
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
                    .font(.largeTitle)
                
                Spacer()
                
                CircleImageListView()
                    .frame(width:32, height: 32)
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
            }   .font(.system(size: 24))
                .padding(4)
                .background(.myF1F1F1)
                .foregroundColor(.gray)
            
                .onAppear(){
                    closingDate = sharedDm.deadLine
                    
                }
            
            HStack(spacing: 10){
                
                Spacer()
                
                Button(action: {
                    
                    allowHitTestingFlag.toggle()
                    if allowHitTestingFlag == true {
                        deleteCheckAll()
                        
                        convertCheckedStatesToTimeTable()
                        convertAvailableTimeFromSetToTuple()
                        makeServerArray()
                    } else {
                        deleteCheckAll()
                    }
                }) {
                    
                    Text(allowHitTestingFlag ? "다시선택하기" : "선택하기")
                        .font(.system(size: 15))
                        .padding(9)
                        .background(allowHitTestingFlag ? Color.myE1ACAC.opacity(0.3) : Color.myDD8686)
                        .foregroundColor(allowHitTestingFlag ? Color.myDD8686 : .white)
                        .cornerRadius(4)
                        .padding()
                    
                }.frame(minWidth: 200, maxWidth: /*@START_MENU_TOKEN@*/.infinity/*@END_MENU_TOKEN@*/, alignment: .trailing)      // Adjust the width and height as needed
                
                Button(action: {
                    
                    showSchedule.toggle()
                    
                }) {
                    Image(systemName: "calendar")
                        .font(.system(size:22))
                        .padding(2)
                        .background(showSchedule ? Color.blue : Color.white)
                        .foregroundColor(showSchedule ? Color.white : Color.blue)
                        .cornerRadius(4)
                }
                .frame(width: 30, height: 24)
                
                Button(action: {
                    Task {
                        await  getTimeTableHit(meetingID: sharedDm.meetingId)
                    }
                    //                    for i in  0..<47 {
                    //                        for j in 0..<7 {
                    //                            let index = i * 7 + j
                    //                            allSchedule[ index ] = Double (generateRandomNumber())
                    //                            print(" \(allSchedule[ index ] )")
                    //                        }
                    //                    }
                    showAllSchedule.toggle()
                    print("showAllSchedule \(showAllSchedule)")
                    
                }) {
                    Image(systemName: "person.2" )
                        .font(.system(size: 22))
                        .padding(2)
                        .background(showAllSchedule ? Color.blue : Color.white)
                        .foregroundColor(showAllSchedule ? Color.white : Color.blue)
                        .cornerRadius(4)
                }
                .frame(width: 30, height: 24)
                //                Spacer()
                //                Button(action: {
                //
                //                    deleteCheckAll()
                //
                //                }) {
                //                    Text("지우기")
                //                        .font(.system(size: 15))
                //                        .padding(2)
                //                        .background(Color.blue)
                //                        .foregroundColor(.white)
                //                        .cornerRadius(4)
                //
                //                }.frame(width: 80, height: 24)
                
                
                
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
                                                        if showAllSchedule {
                                                            
                                                            color = .green
                                                            
                                                        }
                                                        return color
                                                        
                                                    }())
                                                    .opacity(allSchedule[itemIndex])
                                                    .border(Color.white, width: 2)
                                                    .frame(width: fixedColumnWidth, height: fixedRowHeight)
                                                
                                                Rectangle()
                                                    .foregroundColor({
                                                        var color : Color = .white
                                                        if showSchedule {
                                                            if eventVm.calendarArray.contains(IntTuple(rowIndex: rowIndex, columnIndex: columnIndex)) {
                                                                
                                                                color = .yellow
                                                            }
                                                        }
                                                        
                                                        
                                                        return color
                                                        
                                                    }())
                                                    .border(Color.white, width: 2)
                                                    .opacity(0.3)
                                                    .frame(width: fixedColumnWidth, height: fixedRowHeight)
                                                
                                                
                                                Rectangle()
                                                    .foregroundColor({
                                                        var color : Color = .white
                                                        
                                                        let index = rowIndex * Int(sharedDm.numberOfDays) + columnIndex
                                                        if checkedStates[index] == true {
                                                            color = .red
                                                        }
                                                        if dragArray.contains(IntTuple(rowIndex: rowIndex, columnIndex: columnIndex)) {
                                                            color = .red
                                                        }
                                                        return color
                                                        
                                                    }())
                                                    .border(Color.white, width: 2)
                                                    .opacity(0.7)
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
                    .frame(height:440)
                
            } .background(Color.clear)
                .scrollTargetBehavior(.viewAligned)
            
            HStack {
                Spacer()
                Button(action: {
                    
                    var voteInfo : VoteInfo
                    convertCheckedStatesToTimeTable()
                    convertAvailableTimeFromSetToTuple()
                    
                    let apiService = APIService<VoteInfo ,BaseResponse<VoteInfoResult>>()
                    // ParentView에서 전달 받는다.
                    //   sharedDm.meetingId = 1
                    guard let url = URL(string:"https://5techdong.store/meetings/\(sharedDm.meetingId)/vote-values") else {
                        print("Invalid URL")
                        return
                    }
                    
                    let accessToken: String
                    do {
                        accessToken = try SignInInfo.shared.readToken(.access)
                        print("get accessToken :\(accessToken)")
                    } catch {
                        print("Failed to retrieve access token: \(error)")
                        return
                    }
                    
                    
                    var request = URLRequest(url: url)

                    request.httpMethod = "POST"
                    request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                    
                    let availableTimeSlot = Array(availableTimeSet)
                    
                    print("availableTimeSlot: \(availableTimeSlot)")
                    let convertedAvailableTimeSlot  = convertDateStringTo24Hour(dateString: availableTimeSlot)
                    print("convertedAvailableTimeSlot: \(convertedAvailableTimeSlot)")
                    /// 장소 추가해야함
                    voteInfo = VoteInfo(candidateTimes: convertedAvailableTimeSlot , candidatePlaces: [])
                    print("😄\(voteInfo)")
                    // JSON 인코더 생성
                    let encoder = JSONEncoder()
                    
                    do {
               
                        let jsonData = try encoder.encode(voteInfo)
                        
                        request.httpBody = jsonData
                        if let jsonString = String(data: jsonData, encoding: .utf8) {
                            print("JSONString: \(jsonString)")
                        }
                    }
                    catch {
                        print(error)
                    }

                    Task{
                        do {
                            try await getMeetings()
                            let response =  try await apiService.asyncPost(for: request)
                            print("asyncPost Success \(response)")
                            
                        } catch{
                            print("asyncPost Fail : \(error) url: \(String(describing: request.url?.description ?? ""))")
                        }
                        
                    }
                }) {
                    Text("투표완료하기")
                        .font(.system(size: 20))
                        .padding(6)
                        .background(.myDD8686)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                } .frame(minWidth: 150, maxWidth: .infinity, minHeight: 52)
                
                
                if isManager {
                    Spacer()
                    Button(action: {
                        showTimeTableConfirmView.toggle()
                        print("showshowTimeTableConfirmView. \(showTimeTableConfirmView)")
                        
                    }) {
                        Text("투표마감하기")
                            .font(.system(size: 20))
                            .padding(6)
                            .background(.myDD8686)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    .frame(minWidth: 150, maxWidth: .infinity, minHeight: 52)
                    .sheet(isPresented: $showTimeTableConfirmView) {
                        TimeTableConfirmView(sharedDm: sharedDm)
                    }
                    
                }
                Spacer()
                
            }
        }.toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                
                Image(systemName: "gearshape")
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
                    })).frame(width: 20, height: 20)
                
                
            }
        }
    }
    
    /// 임시
    @MainActor
    func getMeetings() async throws {
        
        // URL 객체 생성
        guard let url = URL(string: "https://5techdong.store/meetings/\(sharedDm.meetingId)") else {
            throw NetworkError.cannotCreateURL
        }
        do {
            let accessToken = try SignInInfo.shared.readToken(.access)
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
            
            
            let (data, httpResponse) = try await URLSession.shared.data(for: request)
            print("❤️@생성된 모임조회@TIMETABLE: \(String(data: data, encoding: .utf8) ?? "")")
            
            if let httpResponse = httpResponse as? HTTPURLResponse,
               !(200..<300).contains(httpResponse.statusCode) {
                print("Error: \(httpResponse.statusCode) badRequest")
                throw NetworkError.badRequest
            }
        } catch {
            print("Error getMeetings: \(error.localizedDescription)")
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
    
    func convertCheckedStatesToTimeTable()  {
        
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
                col = days - 1
                print("start : \(sharedDm.startDate) end:  \(end) daysDiff: \(col)")
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
    
    
    func convertTimeCellToTuple( voteTimes : VotedTimesResult?) {
        
        
        var row :Int = 0
        var col : Int = 0
        var voteTimeCellToTuple : Set<IntTuple> = []
        
        guard let voteTimes = voteTimes else {
            print("voteTimesResult is nil")
            return
        }
        print("voteTimes  count \(voteTimes.totalCandidateTimes.count   )")
        for item in voteTimes.totalCandidateTimes {
            let end = dateStringToDate(dateString: String(item.dateTime.prefix(10))) ?? sharedDm.startDate
            if let  days = daysBetween(start: sharedDm.startDate, end: end ) {
                col = days - 1
                print("start : \(sharedDm.startDate) end:  \(end) daysDiff: \(col)")
            }
            print("item.dateTime.suffix(7)\(item)  \(item.dateTime.suffix(7))")
            
            if let timeSlot2 = timeSlot2.firstIndex(where: { $0.contains(String(item.dateTime.suffix(5))) }) {
                
                row = timeSlot2
                print("item ->(Row, Col) time: \(item.dateTime.suffix(7))   (\(row) , \(col))")
                
                let index = row * sharedDm.numberOfDays  + col
                
                allSchedule[index] = Double(item.voteCount ?? 0 ) /   Double(voteTimes.numberOfPeople)
                
                
            } else {
                
                print("timeSlot2 error")
            }
            
            
        }
        
    }
    
    func getTimeTableHit(meetingID: Int64) async{
        let apiService  = APIService< BaseResponse<VotedTimesResult>, BaseResponse<VotedTimesResult>>()
        var TimeCellToTuple : Set<IntTuple> = []
        var allSchedule = Array(repeating: 0, count: 48 * 7)
        //https://5techdong.store/candidate-times/{meetingId}
        let urlString = "https://5techdong.store/candidate-times/\(meetingID)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        allSchedule.removeAll()
        print("getTimeTableHit  url :  \(url)")
        let accessToken: String
        do {
            accessToken = try SignInInfo.shared.readToken(.access)
        } catch {
            print("Failed to retrieve access token: \(error)")
            return
        }
        var request = URLRequest(url: url)
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)",
        ]
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
        
        do {
            print("request body: \(request.httpBody)")
            let  decoded = try  await apiService.asyncLoad(for: request)
            print("decoded : \(decoded)")
            
            convertTimeCellToTuple(voteTimes: decoded.result)
            
            
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted // 보기 좋게 출력
            
            let jsonData = try encoder.encode(decoded)
            
            // JSON 데이터를 문자열로 변환
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                print("Decoded JSON:\n\(jsonString)")
            } else {
                print("Failed to convert JSON data to string.")
            }
        } catch{
            print("decoding error \(error)")
        }
        
    }
    
    //리버가 필요할것에 대비해.. ID 만들기
    
    private func makeServerArray(){
        availableTimeTuple
        serverCandidateTimes.removeAll()
        
        for time in availableTimeTuple {
            
            let index = time.columnIndex * sharedDm.numberOfDays  + time.rowIndex
            serverCandidateTimes.append(index)
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

func generateRandomNumber() -> Double {
    // 0.1 단위로 0.1에서 1.0까지의 숫자 배열 생성
    let possibleValues = stride(from: 0.1, through: 1.0, by: 0.1).map { $0 }
    // 배열에서 랜덤으로 하나의 값을 선택
    return possibleValues.randomElement() ?? 0.1
}

///ㅁㅁㅁ

#Preview {
    
    TimeTableView(sharedDm: SharedDateModel(startDate: Date(), endDate: Date(), numberOfDays: 7))
    
}

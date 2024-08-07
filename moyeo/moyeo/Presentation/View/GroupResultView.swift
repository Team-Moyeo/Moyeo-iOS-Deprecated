import SwiftUI

struct GroupResultView: View {
    @Environment(AppViewModel.self) var appViewModel
    @State private var Details = false
    let images: [String] // 서버에서 받아온 이미지 URL 배열
    
    var body: some View {
        GeometryReader { geometry in
            NavigationStack{
                VStack() {
                    // 결과 정보 화면 (날짜, 진행 시간, 장소)
                    resultInfo(geometry: geometry)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    // 그룹원 프로필 내용
                    groupMemberProfile(geometry: geometry)
                        .padding(.horizontal)
                        .padding(.top, 34)
                    Spacer()
                    // 홈버튼
                    backToHomeButton(geometry: geometry)
                        .padding(.bottom, 34)
                }
                //                .navigationBarBackButtonHidden(true)
                
            }
        }
        .preferredColorScheme(.light)
        .navigationTitle("오택동 첫 회식")
        .navigationBarItems(trailing:Button(action: {
            print("공유버튼 클릭")
            //추후 공유 버튼 눌렀을 때 올라올 팝업창 토글 시키기
        }, label: {
            Image(systemName: "square.and.arrow.up")
                .resizable()
                .frame(width: 18, height: 24)
                .foregroundStyle(Color.myDD8686)
        })
        )
    }
}

// 결과 정보 화면 (날짜, 진행 시간, 장소)
extension GroupResultView {
    @ViewBuilder
    func resultInfo(geometry: GeometryProxy) -> some View {
        DisclosureGroup(
            isExpanded: $Details,
            content: {
                VStack(alignment: .leading, spacing: 5) {
                    Divider()
                        .foregroundStyle(Color.myGray3)
                        .padding(.vertical, 13)
                        .padding(.leading, 17)
                    Text("진행 시간")
                        .foregroundStyle(Color.black)
                        .font(.system(size: 14))
                        .padding(.leading, 17)
                    HStack{
                        Text(Image(systemName: "circle.fill"))
                            .font(.system(size: 8))
                        Text("오전 10:00 ~ 오전 11:30") // 여기에 받아온 정보 입력
                            .font(.system(size: 17))
                    }
                    .foregroundStyle(Color.myGray)
                    Divider()
                        .padding(.vertical, 13)
                        .foregroundStyle(Color.myGray3)
                        .padding(.leading, 17)
                    Text("장소")
                        .foregroundStyle(Color.black)
                        .font(.system(size: 14))
                        .padding(.leading)
                    
                    HStack{
                        Text(Image(systemName: "circle.fill"))
                            .font(.system(size: 8))
                        Text("대동집 포항효자점") // 여기에 받아온 정보 입력
                            .font(.system(size: 17))
                    }
                    .foregroundStyle(Color.myGray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            },
            label: {
                HStack{
                    Text(Image(systemName: "circle.fill"))
                        .font(.system(size: 8))
                    Text("2024년 12월 30일 (토)") // 여기에 받아온 정보 입력
                        .font(.system(size: 17))
                }
                .padding(.top, 4)
                .padding(.bottom, 5)
                .foregroundStyle(Color.myGray)
            }).padding(.all)
            .background(Color.myF1F1F1)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.myGray3, lineWidth: 1)
            )
        
    }
}

//그룹원 프로필 내용
extension GroupResultView {
    @ViewBuilder
    func groupMemberProfile(geometry: GeometryProxy) -> some View {
        
        
        let columns = [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(Image(systemName: "circle.fill"))
                    .font(.system(size: 8))
                Text("그룹원")
                    .font(.system(size: 17))
            }
            .foregroundStyle(Color.myGray)
            .padding(.top, 4)
            .padding(.bottom, 5)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(images, id: \.self) { imageUrl in
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } placeholder: {
                        ProgressView()
                            .frame(width: 60, height: 60)
                    }
                }
            }
            .padding()
        }
        .padding()
        .background(Color.myF1F1F1)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.myGray3, lineWidth: 1)
        )
    }
}

// 홈으로 돌아가기 버튼
extension GroupResultView {
    @ViewBuilder
    func backToHomeButton(geometry: GeometryProxy) -> some View {
        NavigationLink(
            destination: MainView(),
            label: {
                Text("홈으로 돌아가기")
                    .foregroundStyle(Color.black)
                    .frame(width: geometry.size.width * 0.92, height: geometry.size.height * 0.06)
                    .background(Color.myGray2)
                    .cornerRadius(5)
            })
    }
}

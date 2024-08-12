import SwiftUI
struct CapturedContent: View {
    @Environment(AppViewModel.self) var appViewModel
    @State private var Details = false
    let images: [String] // 서버에서 받아온 이미지 URL 배열
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // 결과 정보 화면 (날짜, 진행 시간, 장소)
                resultInfo(geometry: geometry)
                    .padding(.horizontal)
                    .padding(.top, 20)
//                Spacer()
                // 그룹원 프로필 내용
                groupMemberProfile(geometry: geometry)
                    .padding(.horizontal)
                    .padding(.top, 34)
                Spacer()
            }
        }
        .preferredColorScheme(.light)
    }
}
// 결과 정보 화면 (날짜, 진행 시간, 장소)
extension CapturedContent {
    @ViewBuilder
    func resultInfo(geometry: GeometryProxy) -> some View {
        DisclosureGroup(
//            isExpanded: .constant(true),
            content: {
                VStack(alignment: .leading, spacing: 5) {
                    Divider()
                        .foregroundStyle(Color.gray)
                        .padding(.vertical, 13)
                        .padding(.leading, 17)
                    Text("진행 시간")
                        .foregroundStyle(Color.black)
                        .font(.system(size: 14))
                        .padding(.leading, 17)
                    HStack {
                        Text(Image(systemName: "circle.fill"))
                            .font(.system(size: 8))
                        Text("오전 10:00 ~ 오전 11:30")
                            .font(.system(size: 17))
                    }
                    .foregroundStyle(Color.gray)
                    Divider()
                        .padding(.vertical, 13)
                        .foregroundStyle(Color.gray)
                        .padding(.leading, 17)
                    Text("장소")
                        .foregroundStyle(Color.black)
                        .font(.system(size: 14))
                        .padding(.leading)
                    
                    HStack {
                        Text(Image(systemName: "circle.fill"))
                            .font(.system(size: 8))
                        Text("대동집 포항효자점")
                            .font(.system(size: 17))
                    }
                    .foregroundStyle(Color.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            },
            label: {
                HStack {
                    Text(Image(systemName: "circle.fill"))
                        .font(.system(size: 8))
                    Text("2024년 12월 30일 (토)")
                        .font(.system(size: 17))
                }
                .padding(.top, 4)
                .padding(.bottom, 5)
                .foregroundStyle(Color.gray)
            })
        .padding()
        .background(Color(white: 0.95))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}


//그룹원 프로필 내용
extension CapturedContent {
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
                ForEach(images.indices, id: \.self) { index in
                    AsyncImage(url: URL(string: images[index])) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                    } placeholder: {
                        Text("오잉 사진이 전달되지 않았어요!")
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

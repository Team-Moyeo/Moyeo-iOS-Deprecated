import SwiftUI

struct GroupResultView: View {
    @Environment var appViewModel: AppViewModel
    @Environment(\.colorScheme) var colorScheme
    @State private var capturedImage: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // 캡처될 부분: 시간, 날짜, 장소 및 그룹원
                CapturedContent(appViewModel: _appViewModel, images: ["",""])
                    .environment(appViewModel)
                
                Spacer()
                // main으로 가는 버튼
                Button {
                    appViewModel.popToMain()
                } label: {
                    Text("홈으로 돌아가기")
                        .bold()
                        .font(.system(size: 17))
                }
                .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.06)
                .foregroundColor(Color.black)
                .background(Color.myGray2)
                .cornerRadius(5)
                .padding(.bottom, 34)
            }
        }
        .navigationTitle("오택동 첫 회식")
        .toolbar{
            ToolbarItem(placement: .topBarTrailing, content: {
                HStack() {
                    Spacer()
                    Button(action: {
                        capturedImage = takeCapture()
                    }, label: {
                        Image(systemName: "camera.viewfinder")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.myDD8686)
                    })
                    if let image = capturedImage {
//                        Image(uiImage: image)
//                            .resizable()
//                            .scaledToFit()
                        ShareLink(item: TransferableImage(uiImage: image),
                                  preview: SharePreview(Text("Captured Image"), image: Image(uiImage: image))) {
                            Label("", systemImage: "square.and.arrow.up")
                                .frame(width: 18, height: 24)
                                .foregroundStyle(Color.myDD8686)
                        }
                    }
                    
                }
            })
        }
    }
    
    // 화면 캡처 함수
    func takeCapture() -> UIImage {
        var image: UIImage?
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let currentLayer = windowScene.windows.first(where: { $0.isKeyWindow })?.layer else { return UIImage() }

        let currentScale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(currentLayer.frame.size, false, currentScale)

        guard let currentContext = UIGraphicsGetCurrentContext() else { return UIImage() }

        currentLayer.render(in: currentContext)
        image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        return image ?? UIImage()
    }
    
    // 사진 저장 함수
    func saveInPhoto(img: UIImage) {
        UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
    }

     //사진 공유 함수
    func sharePicture(img: UIImage) {
        let av = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootViewController = windowScene.windows.first ( where: { $0.isKeyWindow })?.rootViewController else {
            return
        }
        rootViewController.present(av,animated: true, completion:nil)
    }
}

struct TransferableImage: Transferable {
    let uiImage: UIImage
    
    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .image) { transferableImage in
            guard let data = transferableImage.uiImage.pngData() else {
                throw NSError(domain: "TransferableImageError", code: -1, userInfo: [NSLocalizedDescriptionKey: "No representation available"])
            }
            return data
        }
    }
}

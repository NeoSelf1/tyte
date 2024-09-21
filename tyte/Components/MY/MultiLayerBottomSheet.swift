import SwiftUI

struct MultiLayerBottomSheet: View {
    @ObservedObject var viewModel: MyPageViewModel
    @Binding var bottomSheetPosition: PresentationDetent
    @State private var isScreenshotTaken = false
    @State private var screenshotImage: UIImage?
    
    var body: some View {
        ZStack {
            VStack {
                HStack{
                    HStack{
                        Image(systemName: "square.and.arrow.down.fill")
                            .font(._title)
                            .foregroundStyle(.gray60)
                        
                        Text("다운로드")
                            .font(._subhead2)
                            .foregroundStyle(.gray60)
                            .opacity(0.7)
                    }
                    .padding(.horizontal,12)
                    .padding(.vertical,8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(.blue10, lineWidth: 1)
                    )
                    .padding(1)
                    
                    Spacer()
                    
                    Image(systemName: "xmark")
                        .foregroundStyle(.gray60)
                        .font(._headline2)
                        .padding()
                        .onTapGesture {
                            viewModel.isDetailViewPresented = false
                        }
                }
                .padding(.horizontal)
                .frame(height:64)
                .background(.blue10)
                
                Spacer()
            }
            .zIndex(1)
            
            DetailView(viewModel: viewModel)
                .padding(.top, 60) // 버튼 높이만큼 여백 추가
                .zIndex(2)
        }
        .alert(isPresented: $isScreenshotTaken) {
            Alert(title: Text("스크린샷 저장 완료"), message: Text("스크린샷이 저장되었습니다."), dismissButton: .default(Text("확인")))
        }
    }
    
    private func takeScreenshot() {
        let renderer = ImageRenderer(content: DetailView(viewModel: viewModel))
        renderer.scale = UIScreen.main.scale
        
        if let uiImage = renderer.uiImage {
            UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
            screenshotImage = uiImage
            isScreenshotTaken = true
        }
    }
}

#Preview {
    MultiLayerBottomSheet(
        viewModel: MyPageViewModel(),
        bottomSheetPosition: .constant(.height(720))
    )
}

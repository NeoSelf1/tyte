import SwiftUI

struct MultiLayerBottomSheet: View {
    @ObservedObject var viewModel: MyPageViewModel
    @State private var isScreenshotTaken = false
    @State private var screenshotImage: UIImage?
    @State private var detailViewSize: CGSize = .zero
    
    var body: some View {
        ZStack {
            VStack {
                HStack{
                    Button(action: takeScreenshot) {
                        HStack {
                            Image(systemName: "square.and.arrow.down.fill")
                                .font(._title)
                                .foregroundStyle(.gray60)
                            
                            Text("다운로드")
                                .font(._subhead2)
                                .foregroundStyle(.gray60)
                                .opacity(0.7)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 99)
                                .stroke(.blue10, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal,12)
                    .padding(.vertical,8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 99)
                            .stroke(.blue10, lineWidth: 1)
                    )
                    .padding(1)
                    
                    Spacer()
                    
                    Button(action: { viewModel.isDetailSectionPresent = false }) {
                        Image(systemName: "xmark")
                            .foregroundStyle(.gray60)
                            .font(._headline2)
                    }
                    .padding()
                }
                .frame(height:64)
                .background(.blue10)
                
                Spacer()
            }
            .zIndex(1)
            
            DetailSection(todosForDate: viewModel.todosForDate,
                       dailyStatForDate: viewModel.dailyStatForDate,
                       isLoading: viewModel.isLoading
            )
            .padding(.top, 60)
            .zIndex(2)
            .overlay(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: ViewSizeKey.self, value: geometry.size)
                }
            )
        }
        .alert(isPresented: $isScreenshotTaken) {
            Alert(title: Text("스크린샷 저장 완료"), message: Text("스크린샷이 저장되었습니다."), dismissButton: .default(Text("확인")))
        }
        .onPreferenceChange(ViewSizeKey.self) { size in
            self.detailViewSize = size
        }
    }
    
    //TODO: 정리
    private func takeScreenshot() {
        let infoWindowView = DetailSection(
            todosForDate: viewModel.todosForDate,
            dailyStatForDate: viewModel.dailyStatForDate,
            isLoading: viewModel.isLoading
        )
        
        let controller = UIHostingController(rootView: infoWindowView)
        controller.view.frame = CGRect(origin: .zero, size: CGSize(width: detailViewSize.width, height: detailViewSize.height))
        controller.view.backgroundColor = .clear
                    
        if let rootVC = UIApplication.shared.windows.first?.rootViewController {
            rootVC.view.insertSubview(controller.view, at: 0)

            /// 이미지 캡쳐
            let renderer = UIGraphicsImageRenderer(size: CGSize(width: detailViewSize.width, height: detailViewSize.height))

            let infoWindowImage = renderer.image { context in
                controller.view.layer.render(in: context.cgContext)
            }
            
            isScreenshotTaken=true
            UIImageWriteToSavedPhotosAlbum(infoWindowImage, nil,nil, nil)
            controller.view.removeFromSuperview()
        }
    }
}

struct ViewSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}


#if DEBUG
#Preview {
    MultiLayerBottomSheet(viewModel: MyPageViewModel())
}
#endif

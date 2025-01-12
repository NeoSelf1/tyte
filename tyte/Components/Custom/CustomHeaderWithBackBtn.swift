/// 뒤로가기 버튼이 포함된 커스텀 네비게이션 헤더 컴포넌트
///
/// 제목, 뒤로가기 버튼, 그리고 완료 버튼을 포함하는 네비게이션 바를
/// 구현한 커스텀 헤더 컴포넌트입니다.
///
/// - Parameters:
///   - title: 헤더에 표시될 제목
///
/// - Note: 주로 시트나 모달 뷰의 상단 네비게이션 영역에서 사용됩니다.
///
/// ```swift
/// CustomHeaderWithBackBtn(title: "설정")
/// ```
import SwiftUI

struct CustomHeaderWithBackBtn: View {
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image("arrow_left")
                    .renderingMode(.template)
                    .foregroundColor(.gray60)
                    .padding()
            }
            
            Spacer()
            
            Text(title)
                .font(._subhead1)
                .foregroundColor(.gray90)
            
            Spacer()
            
            Button(action: {
                dismiss()
            }) {
                Text("완료")
                    .font(._subhead2)
                    .foregroundColor(.blue30)
                    .padding()
            }
        }
        .padding(.horizontal)
    }
}

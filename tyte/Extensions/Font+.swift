//
//  Font+.swift
//  tyte
//
//  Created by 김 형석 on 9/5/24.
//

import Foundation
import SwiftUI

extension Font {
    // 인스턴스가 아닌 타입 자체에 관련된 속성이나 메서드 정의 시 사용 = 모든 인스턴스가 공유하는 값을 저장할 때 사용.
    // 앱 전체에서 일관되게 사용되어야 하는 값들은 static으로, 이렇게 안할 경우, 폰트 사용파일에서 매번 인스턴스를 생성하여 접근해야함.
    
    static let _headline1 = Font.custom("Pretendard-Black", size: 24)
    static let _headline2 = Font.custom("Pretendard-Bold", size: 20)
    
    static let _subhead1 = Font.custom("Pretendard-Bold", size: 16)
    static let _subhead2 = Font.custom("Pretendard-Bold", size: 14)
    static let _title = Font.custom("Pretendard-Medium", size: 16)
    
    static let _body1 = Font.custom("Pretendard-Regular", size: 16)
    static let _body2 = Font.custom("Pretendard-Bold", size: 14)
    static let _body3 = Font.custom("Pretendard-Bold", size: 13)
    static let _body4 = Font.custom("Pretendard-Regular", size: 13)
    
    static let _caption = Font.custom("Pretendard-Medium", size: 12)
}

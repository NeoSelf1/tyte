//
//  MyPageView.swift
//  tyte
//
//  Created by 김 형석 on 9/14/24.
//

import SwiftUI

struct MyPageView: View {
    var body: some View {
        GraphView()
    }
}

#Preview {
    MyPageView()
        .environmentObject(MyPageViewModel())
}

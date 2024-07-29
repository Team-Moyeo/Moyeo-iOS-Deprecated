//
//  SpacingAndPaddingView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/28/24.
//

import SwiftUI

struct SpacingAndPaddingView: View {
    var body: some View {
        VStack {
            // Spacing 예시
            HStack(spacing: 20) {
                Text("First")
                    .background(Color.red)
                Text("Second")
                    .background(Color.blue)
            }
            .background(Color.gray)

            // Padding 예시
            HStack {
                Text("First")
                    .padding()
                    .background(Color.red)
                Text("Second")
                    .padding()
                    .background(Color.blue)
            }
            .background(Color.gray)
            
            
                      // 기본 패딩
                      Text("Hello, World!")
                          .padding() // 기본 패딩 16 포인트
                          .background(Color.red)
                          .padding(10)

                      // 사용자 정의 패딩
                      Text("Hello, World!")
                          .padding(16)
                          .background(Color.blue)
                          .padding(10)
                          .background(Color.cyan)
                      // 사용자 정의 패딩 8 포인트
                  
                  .background(Color.gray)
        }
        .padding() // VStack에 패딩 추가
    }
}


#Preview {
    SpacingAndPaddingView()
}

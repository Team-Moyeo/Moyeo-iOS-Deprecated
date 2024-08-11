//
//  MemberPopUpView.swift
//  moyeo
//
//  Created by Giwoo Kim on 8/6/24.
//

import SwiftUI

struct MemberPopUpView: View {
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        
        
    ]
    
    
    var imageString : [String] = ["FiveTechDong", "FiveTechDong2", "FiveTechDong3"]
    
    var body: some View {
        ScrollView {
            ZStack {
                Spacer().frame(height: 50)
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(0...100, id: \.self) { rowIndex in
                        CircleImage(image: Image(imageString[rowIndex % imageString.count]), frameSize: 80)
                            .frame(width: 100, height: 100)
                    }
                }
                
                
                
            }    .safeAreaInset(edge: .top) {
                Color.clear.frame(height: 0) // 상단 안전 영역 확보
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 0) // 하단 안전 영역 확보
            }
        }
    }
}



#Preview {
    MemberPopUpView()
}

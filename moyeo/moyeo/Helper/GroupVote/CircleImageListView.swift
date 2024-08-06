//
//  CircleImageListView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/25/24.
//

import SwiftUI

struct CircleImageListView: View {
    var imageString : [String] = ["FiveTechDong", "FiveTechDong2", "YachtPeople"]
    var body: some View {
        
        HStack(alignment: .center) {
            ZStack{
                ForEach(0..<min(imageString.count, 3), id: \.self) { index in
                    if index <= 1 {
                        CircleImage(image: Image(imageString[index]))
                            .offset(x: CGFloat(index) * -10)
                            .frame(width: 80, height: 80)
                    } else {
                        
                        CircleImage()
                            .overlay {
                                Text("+99")
                                    .foregroundColor(.white)
                                    .font(.system(size: 14)) // 텍스트 크기 조정
                                    .bold()
                            }
                            .offset(x: CGFloat(index) * -10)
                            .frame(width: 80, height: 80)
                        
                        
                    }
                    
                }
            }
        }
    }
}

#Preview {
    CircleImageListView()
}

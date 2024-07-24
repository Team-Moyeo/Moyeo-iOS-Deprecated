//
//  SwiftUIView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/19/24.
//

import SwiftUI

struct LazyVGridWithIndexExample: View {
    private let items = Array(1...50).map { "Item \($0)" }
    
    // 그리드 열 정의
    private let columns = [GridItem(.fixed(50)), GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                // 첫 번째 행: 헤더
                GridRow {
                    Text("Index")
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.3))
                        .border(Color.gray)
                    Text("Column 1")
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.3))
                        .border(Color.gray)
                    Text("Column 2")
                        .frame(height: 50)
                        .background(Color.gray.opacity(0.3))
                        .border(Color.gray)
                }
                
                // 데이터 행
                ForEach(items.indices, id: \.self) { index in
                    GridRow {
                        Text("\(index + 1)")
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.3))
                            .border(Color.gray)
                        Text(items[index])
                            .frame(height: 50)
                            .background(Color.green.opacity(0.3))
                            .border(Color.gray)
                        Text("Detail for \(items[index])")
                            .frame(height: 50)
                            .background(Color.orange.opacity(0.3))
                            .border(Color.gray)
                    }
                }
            }
            .padding()
        }
    }
}

struct LazyVGridWithIndexExample_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGridWithIndexExample()
    }
}

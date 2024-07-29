//
//  SwiftUIView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/19/24.
//
import SwiftUI

struct DynamicGridExample: View {
    // 동적으로 설정할 열의 개수와 크기
    @State private var numberOfColumns: Double = 3
    @State private var fixedColumnWidth: Double = 50
    
    private var columns: [GridItem] {
        // 가변적인 열 정의
        var gridItems: [GridItem] = []
        
        // 첫 번째 열은 고정된 너비
        gridItems.append(GridItem(.fixed(CGFloat(fixedColumnWidth))))
        
        // 나머지 열들은 유동적인 너비
        for _ in 1..<Int(numberOfColumns) {
            gridItems.append(GridItem(.flexible()))
        }
        
        return gridItems
    }
    
    private let items = Array(1...30).map { "Item \($0)" }
    
    var body: some View {
        VStack {
            // 열 개수와 고정 열 너비를 조절할 수 있는 슬라이더
            HStack {
                Text("Number of Columns: \(Int(numberOfColumns))")
                Slider(value: $numberOfColumns, in: 1...10, step: 1) {
                    Text("Number of Columns")
                }
                
            }
            HStack {
                Text("Fixed Column Width: \(fixedColumnWidth, specifier: "%.0f")")
                Slider(value: $fixedColumnWidth, in: 30...100, step: 1) {
                    Text("Fixed Column Width")
                }
            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: 10) {
                    // 헤더 행
                    GridRow {
                        Text("Index")
                            .frame(height: 50)
                            .background(Color.gray.opacity(0.3))
                            .border(Color.gray)
                        ForEach(1..<Int(numberOfColumns), id: \.self) { index in
                            Text("Column \(index + 1)")
                                .frame(height: 50)
                                .background(Color.gray.opacity(0.3))
                                .border(Color.gray)
                        }
                    }
                    
                    // 데이터 행
                    ForEach(items.indices, id: \.self) { index in
                        GridRow {
                            Button(action: {
                                print("Button at row \(index + 1), column 1 tapped")
                            }) {
                                Text("\(index + 1)")
                                    .frame(height: 50)
                                    .background(Color.blue.opacity(0.3))
                                    .border(Color.gray)
                            }
                            ForEach(1..<Int(numberOfColumns), id: \.self) { columnIndex in
                                Button(action: {
                                    print("Button at row \(index + 1), column \(columnIndex + 1) tapped")
                                }) {
                                    Text("Item \(index + 1) - \(columnIndex + 1)")
                                        .frame(height: 50)
                                        .background(Color.green.opacity(0.3))
                                        .border(Color.gray)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct DynamicGridExample_Previews: PreviewProvider {
    static var previews: some View {
        DynamicGridExample()
    }
}


//
//  SwiftUIView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/19/24.
//
import SwiftUI

struct LazyVGridWithButtonTrackingView: View {
    private let items = Array(1...50).map { "Item \($0)" }
    
    // 그리드 열 정의
    private let columns = [GridItem(.fixed(50)), GridItem(.flexible()), GridItem(.flexible())]
    
    @State private var selectedButton: (row: Int, column: Int)? = nil
    
    var body: some View {
        VStack {
            // 선택된 버튼의 위치를 표시
            if let selectedButton = selectedButton {
                Text("Selected Button is at Row \(selectedButton.row), Column \(selectedButton.column)")
                    .padding()
            }
            
            ScrollView {
            LazyVGrid(columns: columns, spacing: 10) {
                    // 헤더 행
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
                            Button(action: {
                                // 버튼 클릭 시 위치를 설정
                                selectedButton = (row: index  + 1, column:  1)
                            }) {
                                Text("\(index + 1)")
                                    .frame(height: 50)
                                    .background(Color.blue.opacity(0.3))
                                    .border(Color.gray)
                            }
                            Button(action: {
                                selectedButton = (row: index + 1, column:  2)
                            }) {
                                Text(items[index])
                                    .frame(height: 50)
                                    .background(Color.green.opacity(0.3))
                                    .border(Color.gray)
                            }
                            Button(action: {
                                selectedButton = (row: index  + 1, column:  3)
                            }) {
                                Text("Detail for \(items[index])")
                                    .frame(height: 50)
                                    .background(Color.orange.opacity(0.3))
                                    .border(Color.gray)
                            }
                        }
                    }
                }
                .padding()
            }
        }
    }
}

struct LazyVGridWithButtonTrackingView_Previews: PreviewProvider {
    static var previews: some View {
        LazyVGridWithButtonTrackingView()
    }
}

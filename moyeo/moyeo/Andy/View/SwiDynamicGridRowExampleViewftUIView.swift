//
//  SwiftUIView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/19/24.
//

import SwiftUI

struct DynamicGridRowExampleView: View {
    @State private var itemCount: Int = 5
    private var items: [String] {
        (1...itemCount).map { "Item \($0)" }
    }
    
    var body: some View {
        VStack {
            Button("Add Item") {
                itemCount += 1
            }
            Button("Remove Item") {
                if itemCount > 0 {
                    itemCount -= 1
                }
            }
            
            Grid {
                // 헤더 행
                GridRow {
                    Text("Header 1")
                        .frame(width: 100, height: 50)
                        .background(Color.gray.opacity(0.3))
                        .border(Color.gray)
                    Text("Header 2")
                        .frame(width: 100, height: 50)
                        .background(Color.gray.opacity(0.3))
                        .border(Color.gray)
                }
                
                // 데이터 행
                ForEach(items, id: \.self) { item in
                    GridRow {
                        Text(item)
                            .frame(width: 100, height: 50)
                            .background(Color.blue.opacity(0.3))
                            .border(Color.gray)
                        Text("Detail for \(item)")
                            .frame(width: 100, height: 50)
                            .background(Color.green.opacity(0.3))
                            .border(Color.gray)
                    }
                }
            }
            .padding()
        }
    }
}

struct DynamicGridRowExampleView_Previews: PreviewProvider {
    static var previews: some View {
        DynamicGridRowExampleView()
    }
}

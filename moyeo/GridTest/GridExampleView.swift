//
//  SwiftUIView.swift
//  moyeo
//
//  Created by Giwoo Kim on 7/19/24.
//


import SwiftUI

struct GridExampleView: View {
    var body: some View {
        Grid {
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
            ForEach(0..<10) { index in
                GridRow {
                    Text("Item \(index) A")
                        .frame(width: 100, height: 50)
                        .background(Color.blue.opacity(0.3))
                        .border(Color.gray)
                    Text("Item \(index) B")
                        .frame(width: 100, height: 50)
                        .background(Color.blue.opacity(0.3))
                        .border(Color.gray)
                }
            }
        }
        .padding()
    }
}

struct GridExampleView_Previews: PreviewProvider {
    static var previews: some View {
        GridExampleView()
    }
}

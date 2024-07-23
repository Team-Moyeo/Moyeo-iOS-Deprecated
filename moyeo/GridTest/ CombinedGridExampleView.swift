//
//  ContentView.swift
//  moyeo
//
//  Created by kyungsoolee on 7/15/24.
//

import SwiftUI

import SwiftUI

struct ContentView: View {
    let columns = [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]
    let rows = [GridItem(.fixed(50)), GridItem(.fixed(50)), GridItem(.fixed(50))]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(0..<10) { index in
                    VStack {
                        Text("Item \(index)")
                            .frame(height: 50)
                            .background(Color.blue.opacity(0.3))
                            .cornerRadius(8)

                        LazyHGrid(rows: rows, spacing: 10) {
                            ForEach(0..<3) { subIndex in
                                Text("Subitem \(subIndex)")
                                    .frame(width: 100, height: 50)
                                    .background(Color.green.opacity(0.3))
                                    .cornerRadius(8)
                            }
                        }
                        .frame(height: 160) // Adjust the frame to fit the LazyHGrid content
                    }
                }
            }
            .padding()
        }
    }
}

struct CombinedGridExampleView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

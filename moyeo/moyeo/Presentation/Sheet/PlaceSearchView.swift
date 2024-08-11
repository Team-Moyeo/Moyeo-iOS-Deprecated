//
//  PlaceSearchView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/26/24.
//

import SwiftUI
import NMapsMap

// 지도 보이는 뷰
struct PlaceSearchView: View {
    
    @Environment(PlaceViewModel.self) var placeViewModel
    @EnvironmentObject var sharedDm : SharedDateModel
    @State private var searchQuery: String = ""
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.leading, 8)
                        TextField("장소를 검색하세요", text: $searchQuery, onCommit: {
                            placeViewModel.searchQuery = searchQuery
                            Task {
                                await placeViewModel.searchPlaces()
                            }
                        })
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 7)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.leading)
                    
                    Button(action: {
                        UIApplication.shared.endEditing(true)
                        if placeViewModel.showSearchResults {
                            placeViewModel.showSearchResults = false
                        } else {
                            placeViewModel.searchQuery = searchQuery
                            Task {
                                await placeViewModel.searchPlaces()
                            }
                            placeViewModel.showSearchResults = true
                        }
                    }) {
                        Text(placeViewModel.showSearchResults ? "취소" : "검색")
                            .padding(.trailing)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal)
                
                if placeViewModel.showSearchResults {
                    placeSearchListView()
                } else {
                    GeometryReader { geometry in
                        ZStack {
                            NMapViewControllerRepresentable(
                                places: placeViewModel.places,
                                currentPlace: placeViewModel.currentPlace
                            )
                            .edgesIgnoringSafeArea(.all)
                        }
                    }
                }
            }
        }
        .navigationTitle("새로운 장소 추가")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            searchQuery = placeViewModel.searchQuery
        }
    }
}

extension PlaceSearchView {
    // 검색 결과 리스트뷰
    @ViewBuilder
    func placeSearchListView() -> some View {
        List(placeViewModel.places) { place in
            NavigationLink(
                destination: PlaceAddView(place: place).environment(placeViewModel).environmentObject(sharedDm),
                label: {
                    VStack(alignment: .leading) {
                        Text(place.name)
                            .font(.headline)
                        Text(place.roadAddress)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                })

        }
    }
}


extension UIApplication {
    func endEditing(_ force: Bool) {
        self.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//
//  PlaceAddView.swift
//  moyeo
//
//  Created by Woowon Kang on 7/26/24.
//

import SwiftUI
import NMapsMap

struct PlaceAddView: View {
    
    @Environment(PlaceViewModel.self) var placeViewModel
    
    var place: Place
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // NMapViewControllerRepresentable를 통해 지도를 표시
                NMapViewControllerRepresentable(places: placeViewModel.places, currentPlace: placeViewModel.currentPlace)
                    .edgesIgnoringSafeArea([.leading, .bottom, .trailing])
                    .onAppear {
                        placeViewModel.currentPlace = place
                    }
                
                VStack{
                    Spacer()
                    if placeViewModel.currentPlace != nil {
                        infoWindow(geometry: geometry)
                    }
                }
                .ignoresSafeArea()
            }
        }
        .navigationTitle("새로운 장소 추가") // PlaceAddView의 네비게이션 타이틀 추가
        .navigationBarTitleDisplayMode(.inline) // 타이틀을 작게 표시
    }
}

extension PlaceAddView {
    
    @ViewBuilder
    func infoWindow(geometry: GeometryProxy) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(placeViewModel.currentPlace?.name ?? "")
                .font(.headline)
                .foregroundColor(.black)
                .fontWeight(.heavy)
                .padding(.top, 10)
            Text(placeViewModel.currentPlace?.roadAddress ?? "")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            Button(action: {
                placeViewModel.isPresentingPlaceSearchView.toggle()
                Task {
                    let success = try await placeViewModel.postPlace()
                    if success {
                        print("Place added successfully")
                        // fix된 장소 추가
                        // createMeetingViewModel.fixedPlace = placeViewModel.places
                    } else {
                        print("Failed to add place")
                    }
                }
            }) {
                Text("추가하기")
                    .font(.body)
                    .bold()
                    .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.06)
                    .background(Color.myDD8686)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.bottom, 20)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .frame(width: geometry.size.width)
        .ignoresSafeArea(.all)
    }
}

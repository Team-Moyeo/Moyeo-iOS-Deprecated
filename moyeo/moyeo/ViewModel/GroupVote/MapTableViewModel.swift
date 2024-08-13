//
//  MapTableViewModel.swift
//  moyeo
//
//  Created by Giwoo Kim on 8/13/24.
//

import SwiftUI
import Combine
//@MainActor
class MapTableViewModel: ObservableObject {
    @Published var votedPlacesResult = VotedPlacesResult(myVotedPlaces: [], totalCandidatePlaces:[], numberOfPeople: 0)
    @Published var meetingID: Int = 0
    
   
    func getCandidatePlaces() async{
        let apiService = APIService< VotedPlacesResult,BaseResponse<VotedPlacesResult>>()
     
        let urlString = "https://5techdong.store/candidate-places/\(meetingID)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL in \(urlString)")
            return
        }
        
      
        let accessToken: String
        do {
            accessToken = try SignInInfo.shared.readToken(.access)
        } catch {
            print("Failed to retrieve access token: \(error)")
            return
        }
        var request = URLRequest(url: url)
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)",
        ]
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
      
        do {
            
            print("request body: \(String(describing: request.httpBody))")
            
            
            let  decoded = try  await apiService.asyncLoad(for: request)
            let  candidatePlacesResult = decoded.result
            
            DispatchQueue.main.async{
                self.votedPlacesResult = candidatePlacesResult ?? VotedPlacesResult(myVotedPlaces: [], totalCandidatePlaces:[], numberOfPeople: 0)
                
            }
            print("decoded VotedPlacesResult : \(decoded)")
      
        } catch{
            print("decoding error \(error)")
        }
        
        
    }
    
    func set() async{
        let apiService = APIService< VotedPlacesResult,BaseResponse<VotedPlacesResult>>()
     
        let urlString = "https://5techdong.store/candidate-places/\(meetingID)"
        guard let url = URL(string: urlString) else {
            print("Invalid URL in \(urlString)")
            return
        }
        
      
        let accessToken: String
        do {
            accessToken = try SignInInfo.shared.readToken(.access)
        } catch {
            print("Failed to retrieve access token: \(error)")
            return
        }
        var request = URLRequest(url: url)
        
        let headers = [
            "Content-Type": "application/json",
            "Authorization": "Bearer \(accessToken)",
        ]
        request.allHTTPHeaderFields = headers
        request.httpMethod = "GET"
      
        do {
            
            print("request body: \(String(describing: request.httpBody))")
            
            
            let  decoded = try  await apiService.asyncLoad(for: request)
            let  candidatePlacesResult = decoded.result
            
            DispatchQueue.main.async{
                self.votedPlacesResult = candidatePlacesResult ?? VotedPlacesResult(myVotedPlaces: [], totalCandidatePlaces:[], numberOfPeople: 0)
                
            }
            print("decoded VotedPlacesResult : \(decoded)")
      
        } catch{
            print("decoding error \(error)")
        }
        
        
    }
    }


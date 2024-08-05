//
//  ProfileViewModel.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/5/24.
//

import Foundation


@Observable
class ProfileViewModel {
    var profileInfo: MemberResponse.MemberInfo
    
    init() {
        self.profileInfo = .init(profileImage: nil, name: "", phoneNumber: nil, email: nil)
    }
    
    
}

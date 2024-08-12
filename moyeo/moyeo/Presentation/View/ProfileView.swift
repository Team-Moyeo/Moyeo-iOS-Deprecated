//
//  ProfileView.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/4/24.
//

import SwiftUI


struct ProfileView: View {
    
    @Environment(AppViewModel.self) var appViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            
            ProfileImageView()
            .padding(.bottom, 28)
            
            List {
                ProfileDetailsView()
                AccountActionsView()
            }
            .listSectionSpacing(54)
            .listStyle(.plain)
            
        }
        .navigationBarBackButtonHidden()
        .toolbar {
            toolbarContent
        }
        .onAppear {
            Task {
                await profileViewModel.loadProfileInfo()
            }
        }
        
    }
    
    
    
    private var toolbarContent: some ToolbarContent {
        Group {
            if profileViewModel.editProfileMode {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        profileViewModel.toggleEditMode(cancelChanges: true)
                    } label: {
                        Text("취소")
                            .pretendard(.regular, 17)
                            .foregroundStyle(.myDD8686)
                    }
                }
                
                ToolbarItemGroup(placement: .principal) {
                    Text("내 정보 관리")
                        .pretendard(.semiBold, 17)
                        .foregroundStyle(.myGray4)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await profileViewModel.saveProfileChanges()
                        }
                    } label: {
                        Text("완료")
                            .foregroundStyle(.myDD8686)
                    }
                }
                
            } else {
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        appViewModel.pop()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(.myDD8686)
                            .frame(width: 18, height: 18)
                    }
                }
                
                ToolbarItemGroup(placement: .principal) {
                    Text("내 정보 관리")
                        .pretendard(.semiBold, 17)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        profileViewModel.toggleEditMode(cancelChanges: false)
                    } label: {
                        Image(systemName: "pencil.circle")
                            .foregroundStyle(.myDD8686)
                            .frame(width: 18, height: 18)
                    }
                }
            }
        }
    }
}

private struct ProfileImageView: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel

    var body: some View {
        ZStack {
            if let imageData = profileViewModel.profileInfo.profileImage,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.myGray2, lineWidth: 1)
                    )
            } else {
                Image(.dummyProfile)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(.myGray2, lineWidth: 1)
                    )
            }
            
            if profileViewModel.editProfileMode {
                Button {
                    // Profile Image 수정 로직 추가
                } label: {
                    Image(systemName: "pencil.circle.fill")
                        .foregroundStyle(.black)
                        .background(
                            Circle()
                                .fill(.white)
                                .frame(width: 16, height: 16)
                        )
                        .frame(width: 18, height: 18)
                        .offset(x: 26, y: 25)
                }
            }
        }
    }
}


private struct ProfileDetailsView: View {
    
    enum ProfileDetail: String, CaseIterable {
        case name = "이름"
        case phoneNumber = "연락처"
        case email = "이메일"
        
        var label: String {
            return self.rawValue
        }
    }
    
    var body: some View {
        Section {
            ForEach(ProfileDetail.allCases, id: \.self) { detail in
                ProfileDetailsViewCell(profileDetail: detail)
            }
        }
        .frame(height: 54)
        .listRowInsets(
            EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        )
    }
}


private struct AccountActionsView: View {
    var body: some View {
        Section {
            Button {
                // 회원탈퇴 로직 추가
            } label: {
                Text("회원탈퇴")
            }
            
            Button {
                // 로그아웃 로직 추가
            } label: {
                Text("로그아웃")
                    .foregroundStyle(.myDD8686)
            }
        }
        .frame(height: 54)
        .listRowInsets(
            EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        )
    }
}


private struct ProfileDetailsViewCell: View {
    
    @EnvironmentObject var profileViewModel: ProfileViewModel
    let profileDetail: ProfileDetailsView.ProfileDetail
    
    var body: some View {
        HStack {
            Text(profileDetail.label)
                .pretendard(.regular, 17)
                .foregroundColor(.primary)
            
            Spacer()
            
            if profileViewModel.editProfileMode {
                TextField("기입해주세요", text: profileDetailContent)
                    .multilineTextAlignment(.trailing)
                    .accentColor(.myDD8686)
            } else {
                Text(profileDetailContent.wrappedValue)
                    .pretendard(.regular, 17)
                    .foregroundStyle(.secondary)
            }
        }
    }
}


extension ProfileDetailsViewCell {
    
    private var profileDetailContent: Binding<String> {
        switch profileDetail {
        case .name:
            return $profileViewModel.profileInfo.name
        case .phoneNumber:
            return $profileViewModel.profileInfo.phoneNumber
        case .email:
            return $profileViewModel.profileInfo.email
        }
    }
    
}


#Preview {
    ProfileView()
}

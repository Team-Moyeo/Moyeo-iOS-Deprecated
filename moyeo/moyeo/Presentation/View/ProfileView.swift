//
//  ProfileView.swift
//  moyeo
//
//  Created by Chang Jonghyeon on 8/4/24.
//

import SwiftUI


struct ProfileView: View {
    
    @State var profileViewModel: ProfileViewModel = .init()
    
    var body: some View {
        VStack(spacing: 0) {
            
            ProfileImageView(
                profileImage: profileViewModel.profileInfo.profileImage
            )
            .padding(.bottom, 28)
            
            List {
                ProfileDetailsView(
                    name: profileViewModel.profileInfo.name,
                    phoneNumber: profileViewModel.profileInfo.phoneNumber,
                    email: profileViewModel.profileInfo.email
                )
                AccountActionsView()
            }
            .listSectionSpacing(54)
            .listStyle(.plain)
            
        }
    }
}

private struct ProfileImageView: View {
    
    var profileImage: Data?
    
    var body: some View {
        ZStack {
            
            if let imageData = profileImage,
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
            
            Button {
                
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

private struct ProfileDetailsView: View {
    
    var name: String?
    var phoneNumber: String?
    var email: String?
    
    var body: some View {
        Section {
            
            ProfileDetailsViewCell(
                title: "이름",
                content: name
            )
            
            ProfileDetailsViewCell(
                title: "전화번호",
                content: "+82 10-1234-5678"
            )
            
            ProfileDetailsViewCell(
                title: "이메일",
                content: "appleLearner@postech.ac.kr"
            )
            
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
                
            } label: {
                Text("회원탈퇴")
            }
            
            Button {
                
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
    
    let title: String
    let content: String
    
    var body: some View {
        HStack() {
            
            Text(title)
                .pretendard(.regular, 17)
                .foregroundColor(.primary)
            
            Spacer()
            
            Text(content)
                .pretendard(.regular, 17)
                .foregroundStyle(.secondary)
            
        }
    }
}


#Preview {
    ProfileView()
}

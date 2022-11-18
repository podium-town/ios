//
//  ExploreProfile.swift
//  Podium
//
//  Created by Michael Jach on 11/11/2022.
//

import SwiftUI

struct ExploreProfile: View {
  @State var profile: ProfileModel
  @Binding var disabled: Bool
  @Binding var isFollowing: Bool
  
  var onFollow: (_ userId: String) -> Void
  var onUnfollow: (_ userId: String) -> Void
  
  var body: some View {
    HStack {
      Image(uiImage: profile.avatarData == nil ? UIImage(named: "avatar")! : UIImage(data: profile.avatarData!)!)
        .resizable()
        .frame(width: 44, height: 44)
        .clipShape(Circle())
      
      Text(profile.username ?? profile.id)
        .fontWeight(.semibold)
      
      Spacer()
      
      if isFollowing {
        Button {
          onUnfollow(profile.id)
        } label: {
          Text("Unfollow")
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
              RoundedRectangle(cornerRadius: 23)
            )
        }
        .disabled(disabled)
        .opacity(disabled ? 0.6 : 1)
      } else {
        Button {
          onFollow(profile.id)
        } label: {
          Text("Follow")
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
              RoundedRectangle(cornerRadius: 23)
            )
        }
        .disabled(disabled)
        .opacity(disabled ? 0.5 : 1)
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: 15)
        .foregroundColor(Color("ColorLightBackground"))
    )
  }
}

struct ExploreProfile_Previews: PreviewProvider {
  static var previews: some View {
    ExploreProfile(
      profile: Mocks.profile,
      disabled: .constant(false),
      isFollowing: .constant(false),
      onFollow: { _ in },
      onUnfollow: { _ in }
    )
  }
}

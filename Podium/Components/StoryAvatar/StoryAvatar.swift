//
//  StoryAvatar.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI

struct StoryAvatar: View {
  @State var profile: ProfileModel
  var isAddVisible: Bool = false
  var hasNew: Bool
  
  var body: some View {
    ZStack {
      Circle()
        .strokeBorder(hasNew ? Color.accentColor : Color.clear, lineWidth: 3)
        .frame(width: 68, height: 68)
      
      Image(uiImage: profile.avatarData == nil ? UIImage(named: "avatar")! : UIImage(data: profile.avatarData!)!)
        .resizable()
        .scaledToFill()
        .frame(width: 58, height: 58)
        .clipShape(Circle())
        .overlay(
          isAddVisible ?
          VStack {
            Spacer()
            HStack {
              Circle()
                .frame(width: 18, height: 18)
                .foregroundColor(.accentColor)
                .overlay(
                  Image("plus")
                    .resizable()
                    .foregroundColor(Color("ColorTextInverted"))
                    .frame(width: 10, height: 10)
                )
              Spacer()
            }
          } : nil
        )
    }
  }
}

struct StoryAvatar_Previews: PreviewProvider {
  static var previews: some View {
    StoryAvatar(
      profile: Mocks.profile,
      isAddVisible: true,
      hasNew: true
    )
  }
}

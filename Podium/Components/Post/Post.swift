//
//  Post.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI

struct Post: View {
  var post: PostModel
  var profile: ProfileModel
  var onDelete: (_ post: PostModel) -> Void
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Image(uiImage: (profile.avatar?.base64ToImage() ?? UIImage(named: "avatar")!))
        .resizable()
        .scaledToFill()
        .frame(width: 48, height: 48)
        .clipShape(Circle())
      
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 0) {
          Text(profile.username)
            .fontWeight(.semibold)
          
          Spacer()
          
          Menu {
            Button("Delete", action: { onDelete(post) })
          } label: {
            Image("more")
              .resizable()
              .frame(width: 18, height: 18)
              .padding(.horizontal, 12)
              .foregroundColor(.gray)
          }
          
          Text(
            Date(timeIntervalSince1970: TimeInterval(
              integerLiteral: post.createdAt
            )).timeAgoDisplay()
          )
          .foregroundColor(.gray)
          .font(.caption)
        }
        
        Text(post.text)
      }
    }
    .padding(12)
    
    Divider()
      .overlay(Color("ColorSeparator"))
  }
}

struct Post_Previews: PreviewProvider {
  static var previews: some View {
    Post(
      post: Mocks.post,
      profile: Mocks.profile,
      onDelete: { _ in }
    )
  }
}

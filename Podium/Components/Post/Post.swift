//
//  Post.swift
//  Podium
//
//  Created by Michael Jach on 14/11/2022.
//

import SwiftUI

struct Post: View {
  var profile: ProfileModel
  var post: PostModel
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Button {
        
      } label: {
        Image(uiImage: (profile.avatar?.base64ToImage() ?? UIImage(named: "avatar")!))
          .resizable()
          .scaledToFill()
          .frame(width: 48, height: 48)
          .clipShape(Circle())
      }
      
      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 0) {
          Text(profile.username ?? profile.id)
            .fontWeight(.semibold)
          
          Spacer()
          
          Menu {
            Button("Delete", action: {  })
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
        
        if let images = post.images {
          HStack {
            ForEach(images, id: \.self) { id in
              RoundedRectangle(cornerRadius: 16)
                .foregroundColor(Color.gray)
                .overlay(
                  Text("Loading")
                )
                .frame(height: 190)
                .onAppear {
                  
                }
            }
          }
        }
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
      profile: Mocks.profile,
      post: Mocks.post
    )
  }
}

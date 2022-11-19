//
//  Post.swift
//  Podium
//
//  Created by Michael Jach on 14/11/2022.
//

import SwiftUI

enum PostVariant {
  case base
  case large
}

struct Post: View {
  var profile: ProfileModel
  var post: PostModel
  var onDelete: ((_ post: PostModel) -> Void)?
  var onProfile: ((_ profile: ProfileModel) -> Void)?
  var onImage: ((_ post: PostModel) -> Void)?
  var variant: PostVariant = .base
    
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Button {
        onProfile?(profile)
      } label: {
        Image(uiImage: (profile.avatarData != nil) ? UIImage(data: profile.avatarData!)! : UIImage(named: "avatar")!)
          .resizable()
          .scaledToFill()
          .frame(width: variant == .base ? 48 : 64, height: variant == .base ? 48 : 64)
          .clipShape(Circle())
      }

      VStack(alignment: .leading, spacing: 4) {
        HStack(spacing: 0) {
          Text(profile.username ?? profile.id)
            .fontWeight(.semibold)
            .font(variant == .base ? .body : .title)

          Spacer()

          Text(
            Date(timeIntervalSince1970: TimeInterval(
              integerLiteral: post.createdAt
            )).timeAgoDisplay()
          )
          .foregroundColor(.gray)
          .font(.caption)
        }

        Text(post.text)

        VStack(spacing: 0) {
          if let imageData = post.imageData {
            if imageData.count == 1 {
              if let imgData = imageData[0] {
                Button {
                  onImage?(post)
                } label: {
                  Image(uiImage: UIImage(data: imgData)!)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .allowsHitTesting(false)
                }
              }
            } else {
              HStack {
                ForEach(imageData, id: \.self) { data in
                  Button {
                    onImage?(post)
                  } label: {
                    Image(uiImage: UIImage(data: data)!)
                      .resizable()
                      .scaledToFill()
                      .frame(height: 160)
                      .clipShape(RoundedRectangle(cornerRadius: 15))
                  }
                }
              }
              .padding(.top, 8)
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
      post: Mocks.post,
      onDelete: { _ in },
      onProfile: { _ in }
    )
  }
}

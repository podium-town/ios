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
  
  @State private var loadedImages: [String: Data] = [:]
    
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
          if let images = post.images {
            HStack {
              ForEach(images, id: \.self) { fileId in
                if let loadedImage = loadedImages[fileId] {
                  Button {
                    onImage?(post)
                  } label: {
                    Image(uiImage: UIImage(data: loadedImage)!)
                      .resizable()
                      .scaledToFill()
                      .frame(height: 160)
                      .clipShape(RoundedRectangle(cornerRadius: 15))
                      .allowsHitTesting(false)
                  }
                } else {
                  RoundedRectangle(cornerRadius: 15)
                    .foregroundColor(Color("ColorLightBackground"))
                    .frame(height: 160)
                    .task {
                      do {
                        let (_, loadedData) = try await API.loadImage(
                          profileId: profile.id,
                          fileId: fileId
                        )
                        self.loadedImages[fileId] = loadedData
                      } catch let error {
                        print(error)
                      }
                    }
                }
              }
            }
          }
        }
        .padding(.top, 8)
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

//
//  ThreadPost.swift
//  Podium
//
//  Created by Michael Jach on 19/11/2022.
//

import SwiftUI

struct ThreadPost: View {
  var post: PostModel
  var onDelete: (_ post: PostModel) -> Void
  var onProfile: (_ profile: ProfileModel) -> Void
  var onImage: (_ post: PostModel) -> Void
  
  @State private var loadedImages: [String: Data] = [:]
  
  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .center) {
        if let profile = post.profile {
          Button {
            onProfile(profile)
          } label: {
            Image(uiImage: (profile.avatarData != nil) ? UIImage(data: profile.avatarData!)! : UIImage(named: "avatar")!)
              .resizable()
              .scaledToFill()
              .frame(width: 64, height: 64)
              .clipShape(Circle())
              .clipped()
          }
          
          HStack(alignment: .center, spacing: 0) {
            Text(profile.username ?? "")
              .fontWeight(.semibold)
              .font(.title2)
            
            Spacer()
            
            Text(
              Date(timeIntervalSince1970: TimeInterval(
                integerLiteral: post.createdAt
              )).timeAgoDisplay()
            )
            .foregroundColor(.gray)
            .font(.caption)
          }
        }
      }
      .padding(.bottom, 8)
      
      VStack(alignment: .leading, spacing: 4) {
        Text(post.text)
          .font(.title3)
        
        if let images = post.images, !images.isEmpty {
          VStack(spacing: 0) {
            HStack {
              ForEach(images, id: \.self) { url in
                if let loadedImage = loadedImages[url] {
                  Button {
                    onImage(post)
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
                        let (_, loadedData) = try await API.getImage(
                          url: url
                        )
                        self.loadedImages[url] = loadedData
                      } catch let error {
                        print(error)
                      }
                    }
                }
              }
            }
          }
          .padding(.top, 8)
        }
      }
    }
    .padding(22)
  }
}

struct ThreadPost_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 0) {
      ThreadPost(
        post: Mocks.postSimple,
        onDelete: { _ in },
        onProfile: { _ in },
        onImage: { _ in }
      )
      ThreadPost(
        post: Mocks.post,
        onDelete: { _ in },
        onProfile: { _ in },
        onImage: { _ in }
      )
    }
  }
}

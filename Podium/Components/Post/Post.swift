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
  var post: PostModel
  var onDelete: ((_ post: PostModel) -> Void)?
  var onProfile: ((_ profile: ProfileModel) -> Void)?
  var onImage: ((_ post: PostModel) -> Void)?
  
  @State private var loadedImages: [String: Data] = [:]
  
  var body: some View {
    VStack(spacing: 0) {
      if let profile = post.profile {
        HStack(alignment: .top, spacing: 12) {
          Button {
            onProfile?(profile)
          } label: {
            Image(uiImage: (profile.avatarData != nil) ? UIImage(data: profile.avatarData!)! : UIImage(named: "avatar")!)
              .resizable()
              .scaledToFill()
              .frame(width: 48, height: 48)
              .clipShape(Circle())
              .clipped()
          }
          
          VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
              Text(profile.username ?? "")
                .fontWeight(.semibold)
                .font(.body)
              
              Spacer()
              
              Text(
                Date(timeIntervalSince1970: TimeInterval(
                  integerLiteral: post.createdAt
                )).timeAgoDisplay()
              )
              .foregroundColor(.gray)
              .font(.caption)
            }
            .padding(.bottom, 4)
            
            Text(post.text)
            
            if let images = post.images, !images.isEmpty {
              VStack(spacing: 0) {
                HStack {
                  ForEach(images, id: \.self) { url in
                    if let loadedImage = loadedImages[url] {
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
        .padding(12)
      }
      
      Divider()
        .overlay(Color("ColorSeparator"))
        .padding(0)
    }
  }
}

struct Post_Previews: PreviewProvider {
  static var previews: some View {
    VStack(spacing: 0) {
      Post(
        post: Mocks.postSimple,
        onDelete: { _ in },
        onProfile: { _ in }
      )
      Post(
        post: Mocks.post,
        onDelete: { _ in },
        onProfile: { _ in }
      )
    }
  }
}

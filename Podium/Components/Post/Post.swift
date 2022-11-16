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
  var onDelete: (_ post: PostModel) -> Void
  var onProfile: (_ profile: ProfileModel) -> Void
  var variant: PostVariant = .base
  
  @State private var images: [String: UIImage] = [:]
  @State private var isMediaPresented = false
  
  var body: some View {
    HStack(alignment: .top, spacing: 12) {
      Button {
        onProfile(profile)
      } label: {
        Image(uiImage: (profile.avatar?.base64ToImage() ?? UIImage(named: "avatar")!))
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
        
        VStack(spacing: 0) {
          if let imagePlaceholders = post.images {
            if imagePlaceholders.count == 1 {
              if let img = images[imagePlaceholders[0]] {
                Button {
                  isMediaPresented = true
                } label: {
                  Image(uiImage: img)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 310, height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
              } else {
                RoundedRectangle(cornerRadius: 16)
                  .foregroundColor(Color("ColorLightBackground"))
                  .overlay(
                    ProgressView()
                  )
                  .frame(width: 310, height: 160)
                  .task {
                    await downloadImage(
                      profileId: profile.id,
                      fileId: imagePlaceholders[0]
                    )
                  }
              }
            } else {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                  ForEach(imagePlaceholders, id: \.self) { fileId in
                    if let img = images[fileId] {
                      Button {
                        isMediaPresented = true
                      } label: {
                        Image(uiImage: img)
                          .resizable()
                          .scaledToFill()
                          .frame(width: 280, height: 160)
                          .clipShape(RoundedRectangle(cornerRadius: 16))
                      }
                    } else {
                      RoundedRectangle(cornerRadius: 16)
                        .foregroundColor(Color("ColorLightBackground"))
                        .overlay(
                          ProgressView()
                        )
                        .frame(width: 280, height: 160)
                        .task {
                          await downloadImage(
                            profileId: profile.id,
                            fileId: fileId
                          )
                        }
                    }
                  }
                }
                .padding(.top, 8)
              }
            }
          }
        }
        .sheet(isPresented: $isMediaPresented) {
          TabView {
            ForEach(Array(images.values), id: \.self) { img in
              Image(uiImage: img)
                .resizable()
                .scaledToFit()
            }
          }
          .tabViewStyle(.page)
        }
      }
    }
    .padding(12)
    
    Divider()
      .overlay(Color("ColorSeparator"))
  }
  
  func downloadImage(profileId: String, fileId: String) async {
    do {
      let (fileId, data) = try await API().loadImage(
        profileId: profileId,
        fileId: fileId
      )
      DispatchQueue.main.async() {
        self.images[fileId] = UIImage(data: data)
      }
    } catch let error {
      
    }
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

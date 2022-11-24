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
  var isSelf: Bool
  var post: PostModel
  var onDelete: (_ post: PostModel) -> Void
  var onReport: (_ post: PostModel) -> Void
  var onProfile: (_ profile: ProfileModel) -> Void
  var onImage: (_ post: PostModel) -> Void
  var onMenuTap: () -> Void
  
  @State private var loadedImages: [String: Data] = [:]
  @State private var animateGradient = false
  
  var body: some View {
    VStack(spacing: 0) {
      if let profile = post.profile {
        VStack(spacing: 0) {
          if let isLoading = post.isLoading, isLoading {
            LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing)
              .hueRotation(.degrees(animateGradient ? 45 : 0))
              .frame(height: 2)
              .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                  if post.isLoading ?? false {
                    animateGradient.toggle()
                  }
                }
              }
          } else {
            Rectangle()
              .foregroundColor(Color.clear)
              .frame(height: 2)
          }
          
          HStack(alignment: .top, spacing: 12) {
            Button {
              onProfile(profile)
            } label: {
              Image(uiImage: (profile.avatarData != nil) ? UIImage(data: profile.avatarData!)! : UIImage(named: "avatar")!)
                .resizable()
                .scaledToFill()
                .frame(width: 48, height: 48)
                .clipShape(Circle())
                .clipped()
            }
            .padding(.top, 2)
            
            VStack(alignment: .leading, spacing: 0) {
              HStack(spacing: 0) {
                Text(profile.username ?? "")
                  .fontWeight(.semibold)
                  .font(.body)
                
                Spacer()
                
                Menu {
                  if isSelf {
                    Button("Delete post") {
                      onDelete(post)
                    }
                  }
                  
                  Button("Report post") {
                    onReport(post)
                  }
                } label: {
                  Image("more")
                    .resizable()
                    .frame(width: 18, height: 18)
                    .scaledToFill()
                }
                .padding(.bottom, 6)
                .padding(.top, 4)
                .padding(.horizontal, 12)
                .foregroundColor(.gray)
                .onTapGesture {
                  onMenuTap()
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
                            .frame(maxHeight: 260)
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .allowsHitTesting(false)
                        }
                      } else if url == "preview" {
                        RoundedRectangle(cornerRadius: 15)
                          .foregroundColor(Color("ColorLightBackground"))
                          .frame(height: 160)
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
          .padding(.horizontal, 12)
          .padding(.bottom, 12)
          .padding(.top, 8)
        }
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
        isSelf: false,
        post: Mocks.postSimple,
        onDelete: { _ in },
        onReport: { _ in },
        onProfile: { _ in },
        onImage: { _ in },
        onMenuTap: {}
      )
      Post(
        isSelf: false,
        post: Mocks.post,
        onDelete: { _ in },
        onReport: { _ in },
        onProfile: { _ in },
        onImage: { _ in },
        onMenuTap: {}
      )
    }
  }
}

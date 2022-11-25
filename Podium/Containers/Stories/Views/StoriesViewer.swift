//
//  StoriesViewer.swift
//  Podium
//
//  Created by Michael Jach on 25/11/2022.
//

import SwiftUI

struct StoriesViewer: View {
  var profile: ProfileModel
  @Binding var isPresented: Bool
  var currentStory: StoryModel?
  var stories: [String: [StoryModel]]
  
  var onPresent: () -> Void
  var onAddImage: (_ image: UIImage) -> Void
  
  var body: some View {
    VStack {
      if let currentProfile = currentStory?.profile {
        HStack {
          ForEach(stories[currentProfile.id] ?? []) { story in
            RoundedRectangle(cornerRadius: 15)
              .frame(height: 4)
              .opacity(currentStory?.id == story.id ? 0.8 : 0.5)
          }
        }
        
        HStack {
          Image(uiImage: (currentProfile.avatarData != nil) ? UIImage(data: currentProfile.avatarData!)! : UIImage(named: "avatar")!)
            .resizable()
            .scaledToFill()
            .frame(width: 32, height: 32)
            .clipShape(Circle())
          
          Text(currentProfile.username ?? "")
            .fontWeight(.semibold)
          
          Spacer()
          
          Text("5h")
        }
      }
      
      Spacer()
      
      StoriesCreate(
        profile: profile,
        isPresented: $isPresented,
        currentStory: currentStory,
        onPresent: onPresent,
        onAddImage: onAddImage
      )
    }
    .padding()
    .foregroundColor(.white)
  }
}

struct StoriesViewer_Previews: PreviewProvider {
  static var previews: some View {
    StoriesViewer(
      profile: Mocks.profile,
      isPresented: .constant(true),
      currentStory: Mocks.story,
      stories: [:],
      onPresent: {},
      onAddImage: { _ in }
    )
  }
}

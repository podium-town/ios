//
//  StoriesCreate.swift
//  Podium
//
//  Created by Michael Jach on 25/11/2022.
//

import SwiftUI

struct StoriesCreate: View {
  var profile: ProfileModel
  @Binding var isPresented: Bool
  var currentStory: StoryModel?
  
  var onPresent: () -> Void
  var onAddImage: (_ image: UIImage) -> Void
  
  var body: some View {
    if let currentProfile = currentStory?.profile {
      if currentProfile.id == profile.id {
        VStack {
          HStack {
            Button {
              onPresent()
            } label: {
              Image("add")
                .resizable()
                .frame(width: 32, height: 32)
              Text("Add Story")
                .fontWeight(.medium)
            }
            
            Spacer()
            
            Text("Views: 43")
              .fontWeight(.medium)
          }
          .padding()
          .foregroundColor(.black)
          .background(.white)
          .clipShape(RoundedRectangle(cornerRadius: 25))
          .shadow(radius: 5)
        }
        .sheet(isPresented: $isPresented) {
          ImagePicker(
            sourceType: .photoLibrary
          ) { image in
            onAddImage(image)
          }
        }
      } else {
        HStack {
          Spacer()
          Button {
            
          } label: {
            Image("heart")
              .resizable()
              .frame(width: 24, height: 24)
          }
          .padding(.horizontal)
        }
      }
    }
  }
}

struct StoriesCreate_Previews: PreviewProvider {
  static var previews: some View {
    StoriesCreate(
      profile: Mocks.profile,
      isPresented: .constant(true),
      currentStory: Mocks.story,
      onPresent: {},
      onAddImage: { _ in }
    )
  }
}

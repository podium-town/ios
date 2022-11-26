//
//  StoriesView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct StoriesView: View {
  let store: Store<StoriesState, StoriesAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        if let create = viewStore.images.first {
          Color.black
            .overlay(
              Image(uiImage: create)
                .resizable()
                .scaledToFill()
            )
            .edgesIgnoringSafeArea(.all)
          
          CreateView(
            onAdd: {
              viewStore.send(.addStory)
            },
            onDismiss: {
              viewStore.send(.dismissCreate)
            }
          )
        } else if let currentStory = viewStore.currentStory,
                  let currentProfile = currentStory.profile {
          if let data = viewStore.loadedMedia[currentStory.url] {
            Color.black
              .overlay(
                Image(uiImage: UIImage(data: data)!)
                  .resizable()
                  .scaledToFill()
              )
              .edgesIgnoringSafeArea(.all)
          } else {
            ProgressView()
              .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
          }
          
          HStack {
            Button {
              viewStore.send(.prevStory)
            } label: {
              VStack {
                Spacer()
                HStack {
                  Spacer()
                }
                Spacer()
              }
            }
            
            Button {
              viewStore.send(.nextStory)
            } label: {
              VStack {
                Spacer()
                HStack {
                  Spacer()
                }
                Spacer()
              }
            }
          }
          
          VStack {
            HStack {
              ForEach(viewStore.stories[currentProfile.id] ?? []) { story in
                RoundedRectangle(cornerRadius: 15)
                  .frame(height: 4)
                  .opacity(currentStory.id == story.id ? 0.8 : 0.5)
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
              
              Text(Date(timeIntervalSince1970: TimeInterval(currentStory.createdAt)).timeAgoDisplay())
            }
            
            Spacer()
            
            if currentProfile.id == viewStore.profile.id {
              CreateBar(
                isLoading: viewStore.isLoading,
                isPresented: viewStore.binding(
                  get: \.isPickerPresented,
                  send: StoriesAction.presentPicker(isPresented:)
                ),
                onPicker: {
                  viewStore.send(.presentPicker(isPresented: true))
                },
                onAddImage: { image in
                  viewStore.send(.addImage(image))
                }
              )
            }
          }
          .padding()
        } else {
          VStack {
            Spacer()
            CreateBar(
              isLoading: viewStore.isLoading,
              isPresented: viewStore.binding(
                get: \.isPickerPresented,
                send: StoriesAction.presentPicker(isPresented:)
              ),
              onPicker: {
                viewStore.send(.presentPicker(isPresented: true))
              },
              onAddImage: { image in
                viewStore.send(.addImage(image))
              }
            )
            .padding()
          }
          .background(Color.black)
        }
      }
      .background(Color.black)
      .onAppear {
        viewStore.send(.getStories)
      }
    }
  }
}

struct StoriesView_Previews: PreviewProvider {
  static var previews: some View {
    StoriesView(store: Store(
      initialState: StoriesState(
        profile: Mocks.profile,
        stories: ["456" : [Mocks.story, Mocks.story]],
        currentProfile: "456",
        images: []
      ),
      reducer: storiesReducer,
      environment: AppEnvironment()
    ))
  }
}

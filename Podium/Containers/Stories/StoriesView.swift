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
        } else if let currentStory = viewStore.currentStory {
          if let data = viewStore.loadedMedia[currentStory.story.url] {
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
              ForEach(viewStore.stories[currentStory.profile.id] ?? []) { story in
                RoundedRectangle(cornerRadius: 15)
                  .foregroundColor(.white)
                  .frame(height: 4)
                  .opacity(currentStory.story.id == story.story.id ? 0.8 : 0.5)
              }
            }
            
            HStack {
              Image(uiImage: (currentStory.profile.avatarData != nil) ? UIImage(data: currentStory.profile.avatarData!)! : UIImage(named: "avatar")!)
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
              
              Text(currentStory.profile.username ?? "")
                .fontWeight(.semibold)
                .foregroundColor(.white)
              
              Spacer()
              
              Text(Date(timeIntervalSince1970: TimeInterval(currentStory.story.createdAt)).timeAgoDisplay())
                .foregroundColor(.white)
            }
            
            Spacer()
            
            if currentStory.profile.id == viewStore.profile.id {
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
                  },
                  onDelete: {
                    viewStore.send(.deleteStory)
                  },
                  seenBy: currentStory.story.seenBy,
                  likedBy: currentStory.story.likedBy
                )
              }
            } else {
              VStack {
                Spacer()
                HStack {
                  Spacer()
                  if currentStory.story.likedBy.contains(where: { $0.id == viewStore.profile.id }) {
                    Image("heart-filled")
                      .resizable()
                      .frame(width: 28, height: 28)
                      .foregroundColor(Color("ColorRed"))
                      .padding()
                  } else {
                    Button {
                      viewStore.send(.markLiked(
                        storyId: currentStory.story.id,
                        ownerId: currentStory.profile.id,
                        profileId: viewStore.profile.id
                      ))
                    } label: {
                      Image("heart")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                    }
                    .padding()
                  }
                }
              }
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
              },
              onDelete: {
                viewStore.send(.deleteStory)
              }
            )
            .padding()
          }
          .background(Color.black)
        }
      }
      .banner(data: viewStore.binding(
        get: \.bannerData,
        send: StoriesAction.dismissBanner
      ))
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
        stories: ["456" : [Mocks.storyProfile, Mocks.storyProfile]],
        currentProfile: "456",
        images: []
      ),
      reducer: storiesReducer,
      environment: AppEnvironment()
    ))
  }
}

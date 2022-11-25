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
        if let currentStory = viewStore.currentStory {
          if !viewStore.images.isEmpty {
            Color.black
              .overlay(
                Image(uiImage: viewStore.images.first!)
                  .resizable()
                  .scaledToFill()
              )
              .edgesIgnoringSafeArea(.all)
          } else if let data = viewStore.loadedMedia[currentStory.url] {
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
        } else {
          Color.black
            .overlay(
              Text("No more stories")
                .foregroundColor(.white)
                .fontWeight(.medium)
            )
        }
        
        if viewStore.images.isEmpty {
          StoriesViewer(
            profile: viewStore.profile,
            isPresented: viewStore.binding(
              get: \.isPickerPresented,
              send: StoriesAction.presentPicker(isPresented:)
            ),
            currentStory: viewStore.currentStory,
            stories: viewStore.stories,
            onPresent: {
              viewStore.send(.presentPicker(isPresented: true))
            },
            onAddImage: { image in
              viewStore.send(.addImage(image))
            }
          )
        } else {
          VStack {
            HStack {
              Spacer()
              Button {
                viewStore.send(.dismissCreate)
              } label: {
                Image("close")
                  .resizable()
                  .frame(width: 32, height: 32)
                  .foregroundColor(.white)
              }
            }
            .padding(24)
            
            Spacer()
            
            HStack {
              Spacer()
              Button {
                viewStore.send(.addStory)
              } label: {
                HStack {
                  Text("Add")
                    .fontWeight(.medium)
                    .font(.title3)
                  
                  Image("send")
                    .resizable()
                    .frame(width: 24, height: 24)
                }
                .foregroundColor(.black)
                .padding(.vertical, 10)
                .padding(.horizontal, 18)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 99))
              }
            }
            .padding(24)
          }
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
        images: [UIImage(named: "welcome")!]
      ),
      reducer: storiesReducer,
      environment: AppEnvironment()
    ))
  }
}

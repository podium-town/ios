//
//  MediaView.swift
//  Podium
//
//  Created by Michael Jach on 19/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct MediaView: View {
  let store: Store<MediaState, MediaAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      TabView {
        ForEach(viewStore.post.images, id: \.self) { fileId in
          if let loadedImage = viewStore.loadedImages[fileId] {
            Image(uiImage: UIImage(data: loadedImage)!)
              .resizable()
              .scaledToFill()
              .padding()
          } else {
            RoundedRectangle(cornerRadius: 15)
              .foregroundColor(Color("ColorLightBackground"))
              .onAppear {
                viewStore.send(.loadImage(
                  fileId: fileId
                ))
              }
          }
        }
      }
      .tabViewStyle(.page)
      .background(Color("ColorBackground"))
    }
  }
}

struct MediaView_Previews: PreviewProvider {
  static var previews: some View {
    MediaView(store: Store(
      initialState: MediaState(
        post: Mocks.post
      ),
      reducer: mediaReducer,
      environment: AppEnvironment()
    ))
  }
}

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
        ForEach(viewStore.post.images) { imageObj in
          if let loadedImage = viewStore.loadedImages[imageObj.url],
             let uiImage = UIImage(data: loadedImage) {
            Image(uiImage: uiImage)
              .resizable()
              .scaledToFit()
              .ignoresSafeArea()
          } else {
            ProgressView()
              .onAppear {
                viewStore.send(.loadImage(
                  url: imageObj.url
                ))
              }
          }
        }
      }
      .tabViewStyle(.page)
      .padding()
      .ignoresSafeArea()
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

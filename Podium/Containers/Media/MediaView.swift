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
        ForEach(viewStore.post.imageData ?? [], id: \.self) { data in
          Image(uiImage: UIImage(data: data)!)
            .resizable()
            .scaledToFit()
            .padding()
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

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
      VStack {
        Spacer()
        HStack {
          Spacer()
          Text("Hmm")
          Spacer()
        }
        Spacer()
      }
      .background(Color.black)
      .edgesIgnoringSafeArea(.all)
    }
  }
}

struct StoriesView_Previews: PreviewProvider {
  static var previews: some View {
    StoriesView(store: Store(
      initialState: StoriesState(),
      reducer: storiesReducer,
      environment: AppEnvironment()
    ))
  }
}

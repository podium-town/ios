//
//  ThreadView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct ThreadView: View {
  let store: Store<ThreadState, ThreadAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      ScrollView {
        
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Image("more")
            .resizable()
            .frame(width: 18, height: 18)
            .scaledToFill()
        }
      }
    }
  }
}

struct ThreadView_Previews: PreviewProvider {
  static var previews: some View {
    ThreadView(store: Store(
      initialState: ThreadState(),
      reducer: threadReducer,
      environment: AppEnvironment()
    ))
  }
}

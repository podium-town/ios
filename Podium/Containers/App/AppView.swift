//
//  AppView.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct AppView: View {
  let store: StoreOf<Main>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      ZStack {
        IfLetStore(
          self.store.scope(
            state: \.login,
            action: AppAction.login
          ),
          then: LoginView.init(store:)
        )
        
        IfLetStore(
          self.store.scope(
            state: \.tabs,
            action: AppAction.tabs
          ),
          then: TabsView.init(store:)
        )
      }
      .onAppear {
        viewStore.send(.initialize)
      }
    }
  }
}

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: Store(
      initialState: AppState(),
      reducer: Main()
    ))
  }
}

//
//  ProfileView.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct ProfileView: View {
  let store: Store<ProfileState, ProfileAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      Text(viewStore.profile.username)
    }
  }
}

struct ProfileView_Previews: PreviewProvider {
  static var previews: some View {
    ProfileView(store: Store(
      initialState: ProfileState(
        profile: Mocks.profile
      ),
      reducer: profileReducer,
      environment: AppEnvironment()
    ))
  }
}

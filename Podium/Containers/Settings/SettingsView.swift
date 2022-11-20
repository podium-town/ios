//
//  SettingsView.swift
//  Podium
//
//  Created by Michael Jach on 20/11/2022.
//

import SwiftUI
import ComposableArchitecture

struct SettingsView: View {
  let store: Store<SettingsState, SettingsAction>
  
  var body: some View {
    WithViewStore(store) { viewStore in
      List {
        Section(header: Text("Settings")) {
          Button {
            
          } label: {
            Text("Logout")
              .foregroundColor(.red)
          }
        }
      }
      .listStyle(.insetGrouped)
      .navigationTitle("Settings")
    }
  }
}

struct SettingsView_Previews: PreviewProvider {
  static var previews: some View {
    SettingsView(store: Store(
      initialState: SettingsState(
        profile: Mocks.profile
      ),
      reducer: settingsReducer,
      environment: AppEnvironment()
    ))
  }
}

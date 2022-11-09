//
//  AppReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine
import Foundation

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  loginReducer.optional().pullback(
    state: \.login,
    action: /AppAction.login,
    environment: { $0 }
  ),
  tabsReducer.optional().pullback(
    state: \.tabs,
    action: /AppAction.tabs,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .initialize:
      if let profile = environment.localStorage.data(forKey: StorageKey.profile.rawValue),
         let loadedProfile = try? JSONDecoder().decode(ProfileModel.self, from: profile) {
        state.tabs = TabsState()
      } else if let verificationId = environment.localStorage.string(forKey: StorageKey.authVerificationID.rawValue) {
        if state.login != nil {
          state.login?.verificationId = verificationId
        } else {
          state.login = LoginState(
            verificationId: verificationId
          )
        }
      } else {
        state.login = LoginState()
      }
      return .none
      
    case .tabs(_):
      return .none
      
    case .login(.didSignIn(.success(let profile))):
      state.login = nil
      state.tabs = TabsState()
      return .none
      
    case .login(_):
      return .none
    }
  }
)

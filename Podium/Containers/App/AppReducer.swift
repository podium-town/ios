//
//  AppReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine
import Foundation

struct Main: ReducerProtocol {
  typealias State = AppState
  typealias Action = AppAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .initialize:
        if let profile = UserDefaults.standard.data(forKey: StorageKey.profile.rawValue),
           let loadedProfile = try? JSONDecoder().decode(ProfileModel.self, from: profile) {
          state.tabs = TabsState(
            profile: loadedProfile,
            homeState: HomeState(
              profile: loadedProfile
            ),
            profileState: ProfileState(
              fromProfile: loadedProfile,
              profile: loadedProfile
            ),
            exploreState: ExploreState(
              profile: loadedProfile,
              foundProfiles: []
            )
          )
        } else if let verificationId = UserDefaults.standard.string(forKey: StorageKey.authVerificationID.rawValue) {
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
        
      case .tabs(.profile(.settings(.deleteAccount))),
          .tabs(.profile(.settings(.logout))):
        state.login = LoginState()
        state.tabs = nil
        UserDefaults.standard.removeObject(forKey: StorageKey.profile.rawValue)
        UserDefaults.standard.removeObject(forKey: StorageKey.authVerificationID.rawValue)
        return .none
        
      case .tabs(_):
        return .none
        
      case .login(.didSignIn(.success(let profile))):
        if profile.username != nil {
          state.login = nil
          state.tabs = TabsState(
            profile: profile,
            homeState: HomeState(
              profile: profile
            ),
            profileState: ProfileState(
              fromProfile: profile,
              profile: profile
            ),
            exploreState: ExploreState(
              profile: profile,
              foundProfiles: []
            )
          )
        }
        return .none
        
      case .login(.didSetUsername(.success(let profile))):
        state.login = nil
        state.tabs = TabsState(
          profile: profile,
          homeState: HomeState(
            profile: profile
          ),
          profileState: ProfileState(
            fromProfile: profile,
            profile: profile
          ),
          exploreState: ExploreState(
            profile: profile,
            foundProfiles: []
          )
        )
        return .none
        
      case .login(_):
        return .none
      }
    }
    .ifLet(\.tabs, action: /Action.tabs) {
      Tabs()
    }
    .ifLet(\.login, action: /Action.login) {
      Login()
    }
  }
}

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
        state.tabs = TabsState(
          profile: loadedProfile,
          homeState: HomeState(
            profile: loadedProfile,
            posts: []
          ),
          profileState: ProfileState(
            isSelf: true,
            fromProfile: loadedProfile,
            profile: loadedProfile
          ),
          addState: AddState(
            profile: loadedProfile
          ),
          exploreState: ExploreState(
            profile: loadedProfile,
            foundProfiles: []
          )
        )
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
      
    case .tabs(.profile(.settings(.logout))):
      state.login = LoginState()
      state.tabs = nil
      environment.localStorage.removeObject(forKey: StorageKey.profile.rawValue)
      environment.localStorage.removeObject(forKey: StorageKey.authVerificationID.rawValue)
      return .none
      
    case .tabs(_):
      return .none
      
    case .login(.didSignIn(.success(let profile))):
      if profile.username != nil {
        state.login = nil
        state.tabs = TabsState(
          profile: profile,
          homeState: HomeState(
            profile: profile,
            posts: []
          ),
          profileState: ProfileState(
            isSelf: true,
            fromProfile: profile,
            profile: profile
          ),
          addState: AddState(
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
          profile: profile,
          posts: []
        ),
        profileState: ProfileState(
          isSelf: true,
          fromProfile: profile,
          profile: profile
        ),
        addState: AddState(
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
)

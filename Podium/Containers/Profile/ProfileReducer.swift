//
//  ProfileReducer.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture

let profileReducer = Reducer<ProfileState, ProfileAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    default:
      return .none
    }
  }
)

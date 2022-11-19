//
//  MediaReducer.swift
//  Podium
//
//  Created by Michael Jach on 19/11/2022.
//

import ComposableArchitecture

let mediaReducer = Reducer<MediaState, MediaAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    default:
      return .none
    }
  }
)

//
//  StoriesReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine

let storiesReducer = Reducer<StoriesState, StoriesAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    default:
      return .none
    }
  }
)

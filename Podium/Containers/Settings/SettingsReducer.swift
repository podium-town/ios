//
//  SettingsReducer.swift
//  Podium
//
//  Created by Michael Jach on 20/11/2022.
//

import ComposableArchitecture
import CoreFoundation

let settingsReducer = Reducer<SettingsState, SettingsAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    
    default:
      return .none
    }
  }
)

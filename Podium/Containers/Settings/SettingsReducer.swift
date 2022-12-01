//
//  SettingsReducer.swift
//  Podium
//
//  Created by Michael Jach on 20/11/2022.
//

import ComposableArchitecture
import CoreFoundation
import UIKit

let settingsReducer = Reducer<SettingsState, SettingsAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .logout:
      return .none
      
    case .viewPrivacy:
      if let url = URL(string: environment.privacyUrl) {
        UIApplication.shared.open(url)
      }
      return .none
      
    case .viewTerms:
      if let url = URL(string: environment.termsUrl) {
        UIApplication.shared.open(url)
      }
      return .none
      
    case .deleteAccount:
      return .none
    }
  }
)

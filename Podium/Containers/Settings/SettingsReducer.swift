//
//  SettingsReducer.swift
//  Podium
//
//  Created by Michael Jach on 20/11/2022.
//

import ComposableArchitecture
import UIKit

struct Settings: ReducerProtocol {
  typealias State = SettingsState
  typealias Action = SettingsAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .logout:
        return .none
        
      case .viewPrivacy:
        if let url = URL(string: "https://podium.town/privacy") {
          UIApplication.shared.open(url)
        }
        return .none
        
      case .viewTerms:
        if let url = URL(string: "https://podium.town/terms") {
          UIApplication.shared.open(url)
        }
        return .none
        
      case .deleteAccount:
        let id = state.profile.id
        return .fireAndForget {
          try await API.deleteAccount(id: id)
        }
      }
    }
  }
}

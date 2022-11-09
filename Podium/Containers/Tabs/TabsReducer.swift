//
//  TabsReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine

let tabsReducer = Reducer<TabsState, TabsAction, AppEnvironment>.combine(
  homeReducer.optional().pullback(
    state: \.home,
    action: /TabsAction.home,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .initialize:
      state.home = HomeState()
      return .none
      
    case .home(_):
      return .none
    }
  }
)

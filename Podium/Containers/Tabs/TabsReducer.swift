//
//  TabsReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine

let tabsReducer = Reducer<TabsState, TabsAction, AppEnvironment>.combine(
  homeReducer.pullback(
    state: \.homeState,
    action: /TabsAction.home,
    environment: { $0 }
  ),
  profileReducer.pullback(
    state: \.profileState,
    action: /TabsAction.profile,
    environment: { $0 }
  ),
  addReducer.pullback(
    state: \.addState,
    action: /TabsAction.add,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .initialize:
      return .none
      
    case .home(_):
      return .none
      
    case .add(_):
      return .none
    }
  }
)

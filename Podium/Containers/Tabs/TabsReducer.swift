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
  exploreReducer.pullback(
    state: \.exploreState,
    action: /TabsAction.explore,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .home(_):
      return .none
      
    case .add(.didAddPost(.success(let post))):
      state.profileState.posts.append(post)
      return .none
      
    case .add(_):
      return .none
      
    case .profile(_):
      return .none
      
    case .explore(.didFollow(.success((let from, let id)))):
      state.profile.following.append(id)
      state.exploreState.profile.following.append(id)
      state.homeState.profile.following.append(id)
      return .none
      
    case .explore(.didUnfollow(.success((let from, let id)))):
      state.profile.following.removeAll(where: { $0 == id })
      state.exploreState.profile.following.removeAll(where: { $0 == id })
      state.homeState.profile.following.removeAll(where: { $0 == id })
      return .none
      
    case .explore(_):
      return .none
    }
  }
)

//
//  ExploreAction.swift
//  Podium
//
//  Created by Michael Jach on 11/11/2022.
//

import ComposableArchitecture

enum ExploreAction {
  case searchQueryChanged(String)
  case search
  case didSearch(TaskResult<[ProfileModel]>)
  case follow(String)
  case didFollow(TaskResult<String>)
}

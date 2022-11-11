//
//  ProfileAction.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture

enum ProfileAction {
  case getPosts
  case didGetPosts(TaskResult<[PostModel]>)
}

//
//  AddAction.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture

enum AddAction {
  case addPost
  case didAddPost(TaskResult<PostModel>)
  case textChanged(String)
}

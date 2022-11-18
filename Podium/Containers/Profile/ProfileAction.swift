//
//  ProfileAction.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture
import UIKit

enum ProfileAction {
  case getPosts
  case didGetPosts(TaskResult<[PostModel]>)
  case presentPicker(isPresented: Bool)
  case changeAvatar(UIImage)
}

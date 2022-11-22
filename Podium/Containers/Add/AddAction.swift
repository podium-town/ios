//
//  AddAction.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture
import UIKit

enum AddAction {
  case addPost
  case addedPost(PostModel)
  case didAddPost(TaskResult<PostModel>)
  case didUploadMedia(TaskResult<PostModel>)
  case textChanged(String)
  case presentPicker(isPresented: Bool)
  case addImage(UIImage)
  case dismiss
}

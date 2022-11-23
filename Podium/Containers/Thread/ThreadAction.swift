//
//  ThreadAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture

enum ThreadAction {
  case textChanged(String)
  case send
  case sended(PostModel)
  case didSend(TaskResult<PostModel>)
  case getComments
  case didGetComments(TaskResult<[PostModel]>)
  case deletePost(post: PostModel)
  case addComments(comments: [PostModel])
}

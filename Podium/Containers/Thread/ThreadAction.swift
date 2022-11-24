//
//  ThreadAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture

indirect enum ThreadAction {
  case textChanged(String)
  case send
  case sended(PostModel)
  case didSend(TaskResult<PostModel>)
  case getComments
  case didGetComments(TaskResult<[PostModel]>)
  case deletePost(post: PostModel)
  case reportPost(post: PostModel)
  case reportComment(comment: PostModel)
  case didReportComment(TaskResult<PostModel>)
  case didReportPost(TaskResult<PostModel>)
  case deleteComment(comment: PostModel)
  case addComments(comments: [PostModel])
  case openMenu
  case attachListener
  case presentMedia(isPresented: Bool, post: PostModel?)
  
  // View Actions
  case media(MediaAction)
}

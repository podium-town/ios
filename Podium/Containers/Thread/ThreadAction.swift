//
//  ThreadAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import FirebaseFirestore

indirect enum ThreadAction {
  case setLoading(loading: Bool)
  case textChanged(String)
  case send
  case sended(PostProfileModel)
  case didSend(TaskResult<PostProfileModel>)
  case getComments
  case didGetComments(TaskResult<[PostProfileModel]>)
  case deletePost(post: PostProfileModel)
  case reportPost(post: PostProfileModel)
  case reportComment(comment: PostProfileModel)
  case didReportComment(TaskResult<PostProfileModel>)
  case didReportPost(TaskResult<PostProfileModel>)
  case deleteComment(comment: PostProfileModel)
  case addComments(comments: [PostProfileModel])
  case openMenu
  case presentMedia(isPresented: Bool, post: PostProfileModel?)
  
  // View Actions
  case media(MediaAction)
}

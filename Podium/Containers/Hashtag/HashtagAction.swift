//
//  HashtagAction.swift
//  Podium
//
//  Created by Michael Jach on 02/12/2022.
//

import ComposableArchitecture
import Foundation

enum HashtagAction {
  case getPosts
  case didGetPosts(TaskResult<[PostProfileModel]>)
  case presentMedia(isPresented: Bool, post: PostProfileModel?, loadedImages: [String: Data]?)
  case presentThread(isPresented: Bool, post: PostProfileModel?)
  case presentProfile(isPresented: Bool, profile: ProfileModel?)
  case reportPost(post: PostProfileModel)
  case didReportPost(TaskResult<String>)
  case blockPost(post: PostProfileModel)
  case didBlockPost(TaskResult<PostProfileModel>)
  case blockProfile(profile: ProfileModel)
  case didBlockProfile(TaskResult<ProfileModel>)
  case onMenuOpen
  
  // View Actions
  case media(MediaAction)
  case profile(ProfileAction)
  case thread(ThreadAction)
}

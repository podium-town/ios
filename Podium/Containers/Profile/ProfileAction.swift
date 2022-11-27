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
  case didGetPosts(TaskResult<[PostProfileModel]>)
  case presentPicker(isPresented: Bool)
  case presentSettings(isPresented: Bool)
  case presentThread(isPresented: Bool, post: PostProfileModel?)
  case presentMedia(isPresented: Bool, post: PostProfileModel?)
  case changeAvatar(UIImage)
  case onMenuOpen
  case deletePost(post: PostProfileModel)
  case didDeletePost(TaskResult<String>)
  case reportPost(post: PostProfileModel)
  case didReportPost(TaskResult<String>)
  case follow
  case didFollow(TaskResult<(ProfileModel, String)>)
  case unfollow
  case didUnfollow(TaskResult<(ProfileModel, String)>)
  case dismissBanner
  
  // View Actions
  case settings(SettingsAction)
  case thread(ThreadAction)
  case media(MediaAction)
}

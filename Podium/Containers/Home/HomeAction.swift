//
//  HomeAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Foundation

enum HomeAction {
  case presentStories(isPresented: Bool, profileId: String?)
  case presentThread(isPresented: Bool, post: PostProfileModel?)
  case presentAdd(isPresented: Bool)
  case presentProfile(isPresented: Bool, profile: ProfileModel?)
  case presentMedia(isPresented: Bool, post: PostProfileModel?)
  case getPosts
  case deletePost(post: PostProfileModel)
  case didDeletePost(TaskResult<String>)
  case reportPost(post: PostProfileModel)
  case didReportPost(TaskResult<String>)
  case dismissBanner
  case onMenuOpen
  
  // View Actions
  case add(AddAction)
  case stories(StoriesAction)
  case thread(ThreadAction)
  case profile(ProfileAction)
  case media(MediaAction)
}

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
  case presentProfile(isPresented: Bool, profile: ProfileModel?)
  case presentAdd(isPresented: Bool)
  case presentMedia(isPresented: Bool, post: PostProfileModel?, loadedImages: [String: Data]?)
  case presentThread(isPresented: Bool, post: PostProfileModel?)
  case dismissBanner
  case onMenuOpen
  case getPosts
  case deletePost(post: PostProfileModel)
  case didDeletePost(TaskResult<String>)
  case reportPost(post: PostProfileModel)
  case didReportPost(TaskResult<String>)
  case blockPost(post: PostProfileModel)
  case didBlockPost(TaskResult<PostProfileModel>)
  case blockProfile(profile: ProfileModel)
  case didBlockProfile(TaskResult<ProfileModel>)
  
  // View Actions
  case add(AddAction)
  case stories(StoriesAction)
  case media(MediaAction)
  case thread(ThreadAction)
  case profile(ProfileAction)
}

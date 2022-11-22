//
//  HomeState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Foundation

struct HomeState: Equatable {
  var profile: ProfileModel
  var isStoriesPresented = false
  var isThreadPresented = false
  var isProfilePresented = false
  var isMediaPresented = false
  var isAddPresented = false
  var isLoadingRefreshable = false
  var isEmpty = false
  var posts: [PostModel]
  var bannerData: BannerData?
  
  // View States
  var add: AddState?
  var stories: StoriesState?
  var threadState: ThreadState?
  var profileState: ProfileState?
  var mediaState: MediaState?
}

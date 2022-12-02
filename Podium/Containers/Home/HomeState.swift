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
  var isAddPresented = false
  var isMediaPresented = false
  var isThreadPresented = false
  var isProfilePresented = false
  var isEmpty = false
  var bannerData: BannerData?
  var stories: [String: [StoryProfileModel]] = [:]
  var profiles: [ProfileModel] = []
  var isStoriesLoading = false
  var posts: [PostProfileModel] = []
  var isLoadingRefreshable = false
  
  // View States
  var add: AddState?
  var storiesState: StoriesState?
  var threadState: ThreadState?
  var mediaState: MediaState?
  var profileState: ProfileState?
}

//
//  StoriesAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Foundation
import UIKit

enum StoriesAction {
  case getStories
  case prevStory
  case nextStory
  case setProfile(String)
  case addStory
  case didAddStory(TaskResult<(String, StoryProfileModel)>)
  case prefetchStories
  case didPrefetchStories(TaskResult<[String: Data]>)
  case presentPicker(isPresented: Bool)
  case addImage(UIImage)
  case deleteStory
  case didDeleteStory(TaskResult<StoryProfileModel>)
  case dismissCreate
  case dismiss
  case dismissBanner
  case markSeen(storyId: String?, ownerId: String, profileId: String?)
  case getStats(storyId: String?)
  case didGetStats(TaskResult<[SeenByModel]>)
}

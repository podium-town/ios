//
//  StoriesReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine
import UIKit

let storiesReducer = Reducer<StoriesState, StoriesAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .dismiss:
      return .none
      
    case .dismissCreate:
      state.images = []
      return .none
      
    case .dismissBanner:
      state.bannerData = nil
      return .none
      
    case .deleteStory:
      let story = state.currentStory!
      return .task {
        await .didDeleteStory(TaskResult {
          try await API.deleteStory(
            story: story
          )
        })
      }
      
    case .didDeleteStory(.success(let story)):
      return Effect(value: .getStories)
      
    case .didDeleteStory(.failure(let error)):
      state.bannerData = BannerData(
        title: "Delete",
        detail: "Error while deleting story.",
        type: .error
      )
      return .none
      
    case .prefetchStories:
      let index = min(state.urls.count, 5)
      let fileUrls = Array(state.urls.prefix(upTo: index)).map({ $0.url })
      return .task {
        await .didPrefetchStories(TaskResult {
          try await API.prefetchStories(
            fileUrls: fileUrls
          )
        })
      }
      
    case .didPrefetchStories(.success(let results)):
      for result in results {
        state.loadedMedia[result.key] = result.value
        state.urls.removeAll(where: { $0.url == result.key })
      }
      return .none
      
    case .didPrefetchStories(.failure(let error)):
      return .none
      
    case .addImage(let image):
      state.images.append(image)
      return .none
      
    case .presentPicker(let isPresented):
      state.isPickerPresented = isPresented
      return .none
      
    case .addStory:
      state.isLoading = true
      let profile = state.profile
      let image = state.images.first!
      state.images = []
      return .task {
        await .didAddStory(TaskResult {
          try await API.addStory(
            profile: profile,
            image: image
          )
        })
      }
      
    case .didAddStory(.success((let profileId, let story))):
      state.isLoading = false
      return Effect(value: .getStories)
      
    case .didAddStory(.failure(let error)):
      state.isLoading = false
      return .none
      
    case .getStories:
      let profilesMap = state.stories.compactMap({ $0.key })
      if state.currentProfile == nil {
        state.profilesIterator = profilesMap.makeBidirectionalIterator()
      } else {
        let shiftBy = profilesMap.firstIndex(of: state.currentProfile!)
//        state.profilesIterator = profilesMap.shift(withDistance: shiftBy ?? 0).makeBidirectionalIterator()
        state.profilesIterator = profilesMap.makeBidirectionalIterator()
        state.currentProfile = state.profilesIterator?.at(index: shiftBy ?? 0)
      }
      state.storiesIterator = state.stories.first(where: { $0.key == state.currentProfile })?.value.makeBidirectionalIterator()
      state.currentStory = state.storiesIterator?.next()
      return Effect(value: .prefetchStories)
      
    case .prevStory:
      if let prevStory = state.storiesIterator?.previous() {
        state.currentStory = prevStory
      } else if let prevProfile = state.profilesIterator?.previous() {
        state.currentProfile = prevProfile
        state.storiesIterator = state.stories.first(where: { $0.key == state.currentProfile })?.value.makeBidirectionalIterator()
        state.currentStory = state.storiesIterator?.last()
      }
      
      return .none
      
    case .nextStory:
      state.currentStory = state.storiesIterator?.next()
      if state.currentStory == nil {
        state.currentProfile = state.profilesIterator?.next()
        if state.currentProfile == nil {
          state.currentStory = nil
          return Effect(value: .dismiss)
        } else {
          state.storiesIterator = state.stories.first(where: { $0.key == state.currentProfile })?.value.makeBidirectionalIterator()
          state.currentStory = state.storiesIterator?.next()
        }
      }
      return Effect(value: .prefetchStories)
      
    case .setProfile(_):
      return .none
    }
  }
)

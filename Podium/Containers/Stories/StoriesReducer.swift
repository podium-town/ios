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
    case .dismissCreate:
      state.images = []
      return .none
      
    case .prefetchStories:
      let index = min(state.urls.count, 5)
      let fileUrls = Array(state.urls.prefix(upTo: index))
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
        state.urls.removeAll(where: { $0 == result.key })
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
      let profileId = state.profile.id
      let image = state.images.first!
      state.images = []
      return .task {
        await .didAddStory(TaskResult {
          try await API.addStory(
            profileId: profileId,
            image: image
          )
        })
      }
      
    case .didAddStory(.success(let fileUrl)):
      return .none
      
    case .didAddStory(.failure(let error)):
      return .none
      
    case .getStories:
      let profilesMap = state.stories.compactMap({ $0.key })
      if state.currentProfile == nil {
        state.profilesIterator = profilesMap.makeIterator()
      } else {
        let shiftBy = profilesMap.firstIndex(of: state.currentProfile!)
        state.profilesIterator = profilesMap.shift(withDistance: shiftBy ?? 0).makeIterator()
        state.currentProfile = state.profilesIterator?.next()
      }
      state.storiesIterator = state.stories.first(where: { $0.key == state.currentProfile })?.value.makeIterator()
      state.currentStory = state.storiesIterator?.next()
      return .none
      
    case .prevStory:
      return .none
      
    case .nextStory:
      state.currentStory = state.storiesIterator?.next()
      if state.currentStory == nil {
        state.currentProfile = state.profilesIterator?.next()
        if state.currentProfile == nil {
          state.currentStory = nil
        } else {
          state.storiesIterator = state.stories.first(where: { $0.key == state.currentProfile })?.value.makeIterator()
          state.currentStory = state.storiesIterator?.next()
        }
      }
      return Effect(value: .prefetchStories)
      
    case .setProfile(_):
      return .none
    }
  }
)

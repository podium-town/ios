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
    case .markSeen(let storyId, let ownerId, let profileId):
      return .none
      
    case .getStats(let storyId):
      state.pendingRequestId = UUID().uuidString
      if let storyId = storyId {
        return .task {
          await .didGetStats(TaskResult {
            try await API.getStats(
              storyId: storyId
            )
          })
        }
        .cancellable(id: state.pendingRequestId)
      }
      return .none
      
    case .didGetStats(.success(let seenBy)):
      state.pendingRequestId = nil
      state.currentStory?.story.seenBy = seenBy
      return .none
      
    case .didGetStats(.failure(let error)):
      state.pendingRequestId = nil
      state.bannerData = BannerData(
        title: "Error",
        detail: "Error while getting stats.",
        type: .error
      )
      return .none
      
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
      state.stories[profileId]?.append(story)
      return Effect.merge([
        Effect(value: .getStories)
      ])
      
    case .didAddStory(.failure(let error)):
      state.isLoading = false
      return .none
      
    case .getStories:
      let profilesMap = state.profiles.map({ $0.id })
      if state.currentProfile == nil {
        state.profilesIterator = profilesMap.makeBidirectionalIterator()
      } else {
        let shiftBy = profilesMap.firstIndex(of: state.currentProfile!)
        state.profilesIterator = profilesMap.makeBidirectionalIterator()
        state.currentProfile = state.profilesIterator?.at(index: shiftBy ?? 0)
      }
      state.storiesIterator = state.stories.first(where: { $0.key == state.currentProfile })?.value.makeBidirectionalIterator()
      let index = state.storiesIterator?.collection.firstIndex(where: { !$0.story.seenBy.contains(where: { $0.id == state.profile.id }) }) ?? 0
      state.currentStory = state.storiesIterator?.at(index: index)
      return Effect.merge([
        Effect(value: .prefetchStories),
        Effect(value: .getStats(storyId: state.currentStory?.story.id)),
        Effect(value: .markSeen(
          storyId: state.currentStory?.story.id,
          ownerId: state.profile.id,
          profileId: state.currentStory?.profile.id
        ))
      ])
      
    case .prevStory:
      if let prevStory = state.storiesIterator?.previous() {
        state.currentStory = prevStory
      } else if let prevProfile = state.profilesIterator?.previous() {
        state.currentProfile = prevProfile
        state.storiesIterator = state.stories.first(where: { $0.key == state.currentProfile })?.value.makeBidirectionalIterator()
        state.currentStory = state.storiesIterator?.last()
      }
      return Effect.merge([
        Effect(value: .getStats(storyId: state.currentStory?.story.id)),
        .cancel(id: state.pendingRequestId),
        Effect(value: .markSeen(
          storyId: state.currentStory?.story.id,
          ownerId: state.profile.id,
          profileId: state.currentStory?.profile.id
        ))
      ])
      
    case .nextStory:
      if let nextStory = state.storiesIterator?.next() {
        state.currentStory = nextStory
      } else if let nextProfile = state.profilesIterator?.next() {
        state.currentProfile = nextProfile
        state.storiesIterator = state.stories.first(where: { $0.key == state.currentProfile })?.value.makeBidirectionalIterator()
        state.currentStory = state.storiesIterator?.next()
      } else {
        return Effect(value: .dismiss)
      }
      return Effect.merge([
        Effect(value: .getStats(storyId: state.currentStory?.story.id)),
        Effect(value: .prefetchStories),
        .cancel(id: state.pendingRequestId),
        Effect(value: .markSeen(
          storyId: state.currentStory?.story.id,
          ownerId: state.profile.id,
          profileId: state.currentStory?.profile.id
        ))
      ])
      
    case .setProfile(_):
      return .none
    }
  }
)

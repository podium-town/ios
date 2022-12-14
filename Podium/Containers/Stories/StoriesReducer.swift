//
//  StoriesReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine
import UIKit

struct Stories: ReducerProtocol {
  typealias State = StoriesState
  typealias Action = StoriesAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .markSeen(let storyId, let ownerId, let profileId):
        return .none
        
      case .markLiked(let storyId, let ownerId, let profileId):
        state.currentStory?.story.likedBy.append(SeenByModel(
          id: state.profile.id,
          username: state.profile.username ?? ""
        ))
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
        
      case .didGetStats(.success((let seenBy, let likedBy))):
        state.pendingRequestId = nil
        state.currentStory?.story.seenBy = seenBy
        state.currentStory?.story.likedBy = likedBy
        return .none
        
      case .didGetStats(.failure(_)):
        state.pendingRequestId = nil
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
        
      case .didDeleteStory(.success(_)):
        return Effect(value: .getStories)
        
      case .didDeleteStory(.failure(_)):
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
        
      case .didPrefetchStories(.failure(_)):
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
        
      case .didAddStory(.failure(_)):
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
  }
}

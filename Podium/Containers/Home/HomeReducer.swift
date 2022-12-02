//
//  HomeReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine
import Foundation
import FirebaseFirestore
import UIKit

struct Home: ReducerProtocol {
  typealias State = HomeState
  typealias Action = HomeAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .getPosts:
        state.isLoadingRefreshable = true
        return .none
        
      case .onMenuOpen:
        return .none
        
      case .dismissBanner:
        state.bannerData = nil
        return .none
        
      case .deletePost(let post):
        return .task {
          await .didDeletePost(TaskResult {
            try await API.deletePost(post: post)
          })
        }
        
      case .didDeletePost(.success(let id)):
        state.posts.removeAll(where: { $0.id == id })
        return .none
        
      case .didDeletePost(.failure(_)):
        return .none
        
      case .reportPost(let post):
        let reporterId = state.profile.id
        return .task {
          await .didReportPost(TaskResult {
            try await API.reportPost(
              reporterId: reporterId,
              post: post
            )
          })
        }
        
      case .didReportPost(.success(_)):
        return .none
        
      case .didReportPost(.failure(_)):
        return .none
        
      case .blockPost(let post):
        let fromId = state.profile.id
        return .task {
          await .didBlockPost(TaskResult {
            try await API.blockPost(
              post: post,
              fromId: fromId
            )
          })
        }
        
      case .didBlockPost(.success(let post)):
        state.posts.removeAll(where: { $0.id == post.id })
        return .none
        
      case .didBlockPost(.failure(_)):
        return .none
        
      case .blockProfile(let profile):
        let fromId = state.profile.id
        return .task {
          await .didBlockProfile(TaskResult {
            try await API.blockProfile(
              profile: profile,
              fromId: fromId
            )
          })
        }
        
      case .didBlockProfile(.success(let profile)):
        state.posts.removeAll(where: { $0.post.ownerId == profile.id })
        return .none
        
      case .didBlockProfile(.failure(_)):
        return .none
        
      case .presentAdd(let isPresented):
        state.isAddPresented = isPresented
        if isPresented {
          state.add = AddState(
            profile: state.profile
          )
        }
        return .none
        
      case .presentMedia(let isPresented, let post, let loadedImages):
        state.isMediaPresented = isPresented
        if isPresented, let post = post {
          state.mediaState = MediaState(
            post: post,
            loadedImages: loadedImages
          )
        }
        return .none
        
      case .presentThread(let isPresented, let post):
        state.isThreadPresented = isPresented
        if isPresented, let post = post {
          state.threadState = ThreadState(
            fromProfile: state.profile,
            post: post
          )
        }
        return .none
        
      case .presentStories(let isPresented, let profileId):
        state.isStoriesPresented = isPresented
        if let profileId = profileId {
          state.storiesState?.currentProfile = profileId
          state.storiesState?.profiles = state.profiles
        }
        return .none
        
      case .presentProfile(let isPresented, let profile):
        state.isProfilePresented = isPresented
        if let profile = profile {
          state.profileState = ProfileState(
            fromProfile: state.profile,
            profile: profile
          )
        }
        return .none
        
      case .stories(.markSeen(let storyId, let ownerId, let storyOwner)):
        var alreadySeen = false
        let profile = state.profile
        let mutated = state.stories[ownerId]?.compactMap { story in
          if story.story.id == storyId && story.profile.id != profile.id {
            var mut = story
            if !mut.story.seenBy.contains(where: { $0.id == state.profile.id}) {
              mut.story.seenBy.append(SeenByModel(
                id: state.profile.id,
                username: state.profile.username ?? "",
                avatar: state.profile.avatarData
              ))
            } else {
              alreadySeen = true
            }
            return mut
          }
          return story
        }
        state.stories[ownerId] = mutated
        state.storiesState?.stories[ownerId] = mutated
        state.profiles = state.profiles.map { profile in
          if profile.id == storyOwner {
            var mut = profile
            mut.hasNewStories = false
            return mut
          }
          return profile
        }
        
        if alreadySeen || storyOwner == state.profile.id {
          return .none
        } else {
          return .fireAndForget {
            try await API.markSeen(
              storyId: storyId,
              profile: profile
            )
          }
        }
        
      case .stories(.markLiked(let storyId, let ownerId, _)):
        var alreadyLiked = false
        let profile = state.profile
        let mutated = state.stories[ownerId]?.compactMap { story in
          if story.story.id == storyId {
            var mut = story
            if !mut.story.likedBy.contains(where: { $0.id == state.profile.id}) {
              mut.story.likedBy.append(SeenByModel(
                id: state.profile.id,
                username: state.profile.username ?? "",
                avatar: state.profile.avatarData
              ))
            } else {
              alreadyLiked = true
            }
            return mut
          }
          return story
        }
        state.stories[ownerId] = mutated
        state.storiesState?.stories[ownerId] = mutated
        
        if alreadyLiked {
          return .none
        } else {
          return .fireAndForget {
            try await API.markLiked(
              storyId: storyId,
              profile: profile
            )
          }
        }
        
      case .stories(.dismiss):
        state.isStoriesPresented = false
        return .none
        
      case .stories(_):
        return .none
        
      case .add(.addPost):
        state.isAddPresented = false
        return .none
        
      case .add(.dismiss):
        state.isAddPresented = false
        return .none
        
      case .add(_):
        return .none
        
      case .media(_):
        return .none
      case .thread(_):
        return .none
        
      case .profile(_):
        return .none
      }
    }
    .ifLet(\.add, action: /Action.add) {
      Add()
    }
    .ifLet(\.storiesState, action: /Action.stories) {
      Stories()
    }
    .ifLet(\.mediaState, action: /Action.media) {
      Media()
    }
    .ifLet(\.threadState, action: /Action.thread) {
      Thread()
    }
    .ifLet(\.profileState, action: /Action.profile) {
      Profile()
    }
  }
}

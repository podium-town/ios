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

let homeReducer = Reducer<HomeState, HomeAction, AppEnvironment>.combine(
  storiesReducer.optional().pullback(
    state: \.storiesState,
    action: /HomeAction.stories,
    environment: { $0 }
  ),
  profileReducer.optional().pullback(
    state: \.profileState,
    action: /HomeAction.profile,
    environment: { $0 }
  ),
  threadReducer.optional().pullback(
    state: \.threadState,
    action: /HomeAction.thread,
    environment: { $0 }
  ),
  addReducer.optional().pullback(
    state: \.add,
    action: /HomeAction.add,
    environment: { $0 }
  ),
  mediaReducer.optional().pullback(
    state: \.mediaState,
    action: /HomeAction.media,
    environment: { $0 }
  ),
  Reducer { state, action, environment in
    switch action {
    case .onMenuOpen:
      return .none
      
    case .dismissBanner:
      state.bannerData = nil
      return .none
      
    case .deletePost(let post):
      return .task {
        await .didDeletePost(TaskResult {
          try await API.deletePost(
            post: post
          )
        })
      }
      
    case .didDeletePost(.success(let id)):
      state.bannerData = BannerData(
        title: "Delete",
        detail: "Your post has been deleted.",
        type: .info
      )
      return Effect(value: .getPosts)
      
    case .didDeletePost(.failure(let error)):
      state.bannerData = BannerData(
        title: "Delete",
        detail: "Error while deleting post.",
        type: .error
      )
      return Effect(value: .getPosts)
      
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
      
    case .didReportPost(.success(let id)):
      state.bannerData = BannerData(
        title: "Report",
        detail: "Your report has been sent.",
        type: .info
      )
      return .none
      
    case .didReportPost(.failure(let error)):
      state.bannerData = BannerData(
        title: "Report",
        detail: "Error while reporting post.",
        type: .error
      )
      return .none
      
    case .getPosts:
      state.isLoadingRefreshable = true
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
      
    case .presentProfile(let isPresented, let profile):
      let fromProfile = state.profile
      state.isProfilePresented = isPresented
      if isPresented, let profile = profile {
        state.profileState = ProfileState(
          fromProfile: fromProfile,
          profile: profile
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
      
    case .presentThread(let isPresented, let post):
      state.isThreadPresented = isPresented
      if isPresented, let post = post {
        state.threadState = ThreadState(
          fromProfile: state.profile,
          post: post
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
      
    case .stories(.markLiked(let storyId, let ownerId, let storyOwner)):
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
      return .none
      
    case .didBlockProfile(.failure(let error)):
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
      return .none
      
    case .didBlockPost(.failure(let error)):
      return .none
      
    case .stories(.dismiss):
      state.isStoriesPresented = false
      return .none
      
    case .stories(_):
      return .none
      
    case .add(.addPost):
      state.isAddPresented = false
      return .none
      
    case .add(.didAddPost(.failure(let error))):
      return Effect(value: .getPosts)
      
    case .add(.dismiss):
      state.isAddPresented = false
      return .none
      
    case .add(_):
      return .none
      
    case .profile(_):
      return .none
      
    case .media(_):
      return .none
      
    case .thread(.deletePost(let post)):
      state.isThreadPresented = false
      state.posts = state.posts.filter({ $0.id != post.id })
      return .none
      
    case .thread(_):
      return .none
    }
  }
)

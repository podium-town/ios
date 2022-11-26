//
//  HomeReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import Combine
import Foundation

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
//      let followingIds = state.profile.following
//      return .task {
//        await .didGetPosts(TaskResult {
//          try await API.getPostsProfiles(
//            ids: followingIds
//          )
//        })
//      }
      
    case .didGetPosts(.success(let posts)):
      state.isLoadingRefreshable = false
//      state.posts = posts
//      if let encodedPosts = try? JSONEncoder().encode(state.posts) {
//        environment.localStorage.set(encodedPosts, forKey: StorageKey.posts.rawValue)
//      }
      state.isEmpty = posts.count == 0
      return .none
      
    case .didGetPosts(.failure(let error)):
      state.bannerData = BannerData(
        title: "Error",
        detail: error.localizedDescription,
        type: .error
      )
      state.isLoadingRefreshable = false
      return .none
      
    case .presentAdd(let isPresented):
      state.isAddPresented = isPresented
      if isPresented {
        state.add = AddState(
          profile: state.profile
        )
      }
      return .none
      
    case .presentMedia(let isPresented, let post):
      state.isMediaPresented = isPresented
      if isPresented, let post = post {
        state.mediaState = MediaState(
          post: post
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
      
    case .presentStories(let isPresented, let profile):
      state.isStoriesPresented = isPresented
      if let profile = profile {
        state.storiesState?.currentProfile = profile.id
      }
      return .none
      
    case .presentThread(let isPresented, let post):
      state.isThreadPresented = isPresented
      if isPresented, let post = post {
        state.threadState = ThreadState(
          profile: state.profile,
          post: post
        )
      }
      return .none
      
    case .stories(.dismiss):
      state.isStoriesPresented = false
      return .none
      
    case .stories(_):
      return .none
      
    case .add(.addPost):
      state.isAddPresented = false
      return .none
      
    case .add(.addedPost(let post)):
      var mut = post
      mut.isLoading = true
      return .none
      
    case .add(.didAddPost(.success(let added))):
      state.posts = state.posts.map { post in
        if post.id == added.id {
          var mut = post
          mut.isLoading = false
          mut.images = added.images
          return mut
        }
        return post
      }
      if let encodedPosts = try? JSONEncoder().encode(state.posts) {
        environment.localStorage.set(encodedPosts, forKey: StorageKey.posts.rawValue)
      }
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

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
    state: \.stories,
    action: /HomeAction.stories,
    environment: { $0 }
  ),
  profileReducer.optional().pullback(
    state: \.profileState,
    action: /HomeAction.profile,
    environment: { $0 }
  ),
  threadReducer.optional().pullback(
    state: \.thread,
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
    case .initialize:
      state.stories = StoriesState()
      return .none
      
    case .deletePost(let id):
      return .task {
        await .didDeletePost(TaskResult {
          try await API.deletePost(
            id: id
          )
        })
      }
      
    case .didDeletePost(.success(let id)):
      return Effect(value: .getPosts)
      
    case .didDeletePost(.failure(let error)):
      return .none
      
    case .getPosts:
      state.isLoadingRefreshable = true
      if let posts = environment.localStorage.data(forKey: StorageKey.posts.rawValue),
         let loadedPosts = try? JSONDecoder().decode([PostModel].self, from: posts) {
        state.posts = loadedPosts
      }
      let followingIds = state.profile.following
      return .task {
        await .didGetPosts(TaskResult {
          try await API.getPostsProfiles(
            ids: followingIds
          )
        })
      }
      
    case .didGetPosts(.success(let posts)):
      state.isLoadingRefreshable = false
      state.posts = posts
      if let encodedPosts = try? JSONEncoder().encode(state.posts) {
        environment.localStorage.set(encodedPosts, forKey: StorageKey.posts.rawValue)
      }
      state.isEmpty = posts.count == 0
      return .none
      
    case .didGetPosts(.failure(let error)):
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
      state.isProfilePresented = isPresented
      if isPresented, let profile = profile {
        state.profileState = ProfileState(
          profile: profile
        )
      }
      return .none
      
    case .presentStories(let isPresented):
      state.isStoriesPresented = isPresented
      if isPresented {
        state.stories = StoriesState()
      }
      return .none
      
    case .presentThread(let isPresented, let post):
      state.isThreadPresented = isPresented
      if isPresented {
        state.thread = ThreadState(
          profile: state.profile,
          post: post
        )
      }
      return .none
      
    case .stories(_):
      return .none
      
    case .add(.addPost):
      state.isAddPresented = false
      return Effect(value: .getPosts)
      
    case .add(.didAddPost(.success(let post))):
      state.posts.append(post)
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
      
    case .thread(_):
      return .none
    }
  }
)

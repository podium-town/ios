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
  Reducer { state, action, environment in
    switch action {
    case .initialize:
      state.stories = StoriesState()
      return Effect(value: .getPosts)
      
    case .deletePost(let id):
      return .task {
        await .didDeletePost(TaskResult {
          try await environment.api.deletePost(
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
      let followingIds = state.profile.following
      return .task {
        await .didGetPosts(TaskResult {
          try await environment.api.getPostsProfiles(
            ids: followingIds
          )
        })
      }
      
    case .didGetPosts(.success((let profiles, let posts))):
      state.isLoadingRefreshable = false
      state.posts = posts
      state.profiles = Dictionary(uniqueKeysWithValues: profiles.map{ ($0.id, $0) })
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
      
    case .presentThread(let isPresented):
      state.isThreadPresented = isPresented
      if isPresented {
        state.thread = ThreadState()
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
      
    case .add(_):
      return .none
      
    case .profile(_):
      return .none
    }
  }
)

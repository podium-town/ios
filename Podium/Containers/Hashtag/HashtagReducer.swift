//
//  HashtagReducer.swift
//  Podium
//
//  Created by Michael Jach on 02/12/2022.
//

import ComposableArchitecture

struct Hashtag: ReducerProtocol {
  typealias State = HashtagState
  typealias Action = HashtagAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
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
        
      case .getPosts:
        let hashtag = state.hashtag
        return .task {
          await .didGetPosts(TaskResult {
            try await API.getPostsForHashtag(hashtag: hashtag)
          })
        }
        
      case .didGetPosts(.success(let posts)):
        state.posts = posts
        return .none
        
      case .didGetPosts(.failure(_)):
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
        
      case .presentProfile(let isPresented, let profile):
        state.isProfilePresented = isPresented
        if isPresented, let profile = profile {
          state.profileState = ProfileState(
            fromProfile: state.profile,
            profile: profile
          )
        }
        return .none
        
      case .media(_):
        return .none

      case .profile(_):
        return .none
        
      case .thread(_):
        return .none
        
      case .onMenuOpen:
        return .none
      }
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

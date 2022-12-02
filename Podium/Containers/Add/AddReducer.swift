//
//  AddReducer.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture
import Foundation

struct Add: ReducerProtocol {
  typealias State = AddState
  typealias Action = AddAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .textChanged(let text):
        state.text = text
        state.isSendDisabled = state.text.count < 3
        return .none
        
      case .addImage(let image):
        state.images.append(image)
        return .none
        
      case .dismiss:
        return .none
        
      case .addPost:
        let hashtags = state.text.matchingStrings(regex: "#[a-zA-Z]+").compactMap({ $0.first })
        let post = PostProfileModel(
          post: PostModel(
            id: UUID().uuidString,
            text: state.text,
            ownerId: state.profile.id,
            createdAt: Date().millisecondsSince1970 / 1000,
            images: [],
            hashtags: hashtags
          ),
          profile: state.profile
        )
        if state.images.isEmpty {
          return .task {
            await .didAddPost(TaskResult {
              try await API.addPost(
                post: post
              )
            })
          }
        } else {
          let ownerId = state.profile.id
          let images = state.images
          return .task {
            await .didUploadMedia(TaskResult {
              try await API.uploadMedia(
                post: post,
                images: images
              )
            })
          }
        }
        
      case .didAddPost(.success(_)):
        state.isSendPending = false
        return .none
        
      case .didAddPost(.failure(_)):
        state.isSendPending = false
        return .none
        
      case .didUploadMedia(.success(let post)):
        return .task {
          await .didAddPost(TaskResult {
            try await API.addPost(
              post: post
            )
          })
        }
        
      case .didUploadMedia(.failure(_)):
        state.isSendPending = false
        return .none
        
      case .presentPicker(let isPresented):
        state.isPickerPresented = isPresented
        return .none
      }
    }
  }
}

//
//  AddReducer.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture
import Foundation

let addReducer = Reducer<AddState, AddAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
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
      let post = PostModel(
        id: UUID().uuidString,
        text: state.text,
        ownerId: state.profile.id,
        createdAt: Date().millisecondsSince1970 / 1000,
        images: []
      )
      return Effect(value: .addedPost(post))
      
    case .addedPost(let post):
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
      
    case .didAddPost(.success(let post)):
      state.isSendPending = false
      return .none
      
    case .didAddPost(.failure(let error)):
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
      
    case .didUploadMedia(.failure(let error)):
      state.isSendPending = false
      return .none
      
    case .presentPicker(let isPresented):
      state.isPickerPresented = isPresented
      return .none
    }
  }
)

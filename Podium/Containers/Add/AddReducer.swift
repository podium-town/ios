//
//  AddReducer.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture

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
      state.isSendPending = true
      let text = state.text
      let ownerId = state.profile.id
      if state.images.isEmpty {
        return .task {
          await .didAddPost(TaskResult {
            try await API.addPost(
              text: text,
              ownerId: ownerId,
              images: []
            )
          })
        }
      } else {
        let images = state.images
        return .task {
          await .didUploadMedia(TaskResult {
            try await API.uploadMedia(
              profileId: ownerId,
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
      
    case .didUploadMedia(.success(let urls)):
      let text = state.text
      let ownerId = state.profile.id
      return .task {
        await .didAddPost(TaskResult {
          try await API.addPost(
            text: text,
            ownerId: ownerId,
            images: urls
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

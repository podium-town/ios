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
      return .none
      
    case .addPost:
      state.isSendPending = true
      let text = state.text
      let ownerId = state.profile.id
      return .task {
        await .didAddPost(TaskResult {
          try await environment.api.addPost(
            text: text,
            ownerId: ownerId
          )
        })
      }
      
    case .didAddPost(.success(let post)):
      state.isSendPending = false
      return .none
      
    case .didAddPost(.failure(let error)):
      state.isSendPending = false
      return .none
    }
  }
)

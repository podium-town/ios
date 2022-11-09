//
//  LoginReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture

let loginReducer = Reducer<LoginState, LoginAction, AppEnvironment>.combine(
  Reducer { state, action, environment in
    switch action {
    case .phoneNumberChanged(let phoneNumber):
      state.phoneNumber = phoneNumber
      return .none
      
    case .verificationCodeChanged(let verificationCode):
      state.verificationCode = verificationCode
      return .none
            
    case .verifyPhone:
      state.isVerificationPending = true
      let phoneNumber = state.phoneNumber
      return .task {
        await .didVerifyPhone(TaskResult { try await environment.api.verifyPhoneNumber(phoneNumber: phoneNumber)
        })
      }
      
    case .didVerifyPhone(.success(let verificationId)):
      environment.localStorage.set(verificationId, forKey: StorageKey.authVerificationID.rawValue)
      state.verificationId = verificationId
      state.isVerificationPending = false
      return .none
      
    case .didVerifyPhone(.failure(let error)):
      state.isVerificationPending = false
      return .none
      
    case .signIn:
      state.isVerificationPending = true
      let verificationCode = state.verificationCode
      let verificationId = state.verificationId
      return .task {
        await .didSignIn(TaskResult {
          try await environment.api.signIn(
            verificationId: verificationId,
            verificationCode: verificationCode
          )
        })
      }
      
    case .didSignIn(.success(let profile)):
      state.isVerificationPending = false
      environment.localStorage.removeObject(forKey: StorageKey.authVerificationID.rawValue)
      if let encoded = profile.encoded() {
        environment.localStorage.set(encoded, forKey: StorageKey.profile.rawValue)
      }
      return .none
      
    case .didSignIn(.failure(let error)):
      state.isVerificationPending = false
      return .none
    }
  }
)

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
    case .dismissBanner:
      state.bannerData = nil
      return .none
      
    case .phoneNumberChanged(let phoneNumber):
      state.phoneNumber = phoneNumber
      return .none

    case .resend:
      return .none
      
    case .usernameChanged(let username):
      state.username = username
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
      state.bannerData = BannerData(
        title: "Error",
        detail: error.localizedDescription,
        type: .error
      )
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
      state.profile = profile
      state.isVerificationPending = false
      state.verificationId = nil
      environment.localStorage.removeObject(forKey: StorageKey.authVerificationID.rawValue)
      if let encoded = profile.encoded() {
        environment.localStorage.set(encoded, forKey: StorageKey.profile.rawValue)
      }
      if profile.username == nil {
        state.isUsernameSelectionVisible = true
      }
      return .none
      
    case .didSignIn(.failure(let error)):
      state.isVerificationPending = false
      environment.localStorage.removeObject(forKey: StorageKey.authVerificationID.rawValue)
      state.bannerData = BannerData(
        title: "Error",
        detail: error.localizedDescription,
        type: .error
      )
      return .none
      
    case .setUsername:
      let profile = state.profile
      let username = state.username
      if let profile = profile {
        return .task {
          await .didSetUsername(TaskResult {
            try await environment.api.setUsername(
              profile: profile,
              username: username
            )
          })
        }
      } else {
        return .none
      }
      
    case .didSetUsername(.success(let profile)):
      if let encoded = profile.encoded() {
        environment.localStorage.set(encoded, forKey: StorageKey.profile.rawValue)
      }
      state.isUsernameSelectionVisible = false
      return .none
      
    case .didSetUsername(.failure(let error)):
      state.bannerData = BannerData(
        title: "Error",
        detail: error.localizedDescription,
        type: .error
      )
      return .none
    }
  }
)
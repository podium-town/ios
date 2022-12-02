//
//  LoginReducer.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture
import UIKit

struct Login: ReducerProtocol {
  typealias State = LoginState
  typealias Action = LoginAction
  
  var body: some ReducerProtocol<State, Action> {
    Reduce { state, action in
      switch action {
      case .viewTerms:
        if let url = URL(string: "https://podium.town/terms") {
          UIApplication.shared.open(url)
        }
        return .none
        
      case .dismissBanner:
        state.bannerData = nil
        return .none
        
      case .phoneNumberChanged(let phoneNumber):
        state.phoneNumber = phoneNumber
        return .none
        
      case .resend:
        state.isVerificationPending = false
        state.isUsernameSelectionVisible = false
        state.verificationId = nil
        state.verificationCode = ""
        return .none
        
      case .usernameChanged(let username):
        state.username = username
        if username.count > 1 {
          state.isUsernameValidated = true
        } else {
          state.isUsernameValidated = false
        }
        return .none
        
      case .verificationCodeChanged(let verificationCode):
        state.verificationCode = verificationCode
        return .none
        
      case .verifyPhone:
        state.isVerificationPending = true
        let phoneNumber = state.phoneNumber
        return .task {
          await .didVerifyPhone(TaskResult {
            try await API.verifyPhoneNumber(phoneNumber: phoneNumber)
          })
        }
        
      case .didVerifyPhone(.success(let verificationId)):
        state.isVerificationPending = false
        UserDefaults.standard.set(verificationId, forKey: StorageKey.authVerificationID.rawValue)
        state.verificationId = verificationId
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
            try await API.signIn(
              verificationId: verificationId,
              verificationCode: verificationCode
            )
          })
        }
        
      case .didSignIn(.success(let profile)):
        state.profile = profile
        state.isVerificationPending = false
        state.verificationId = nil
        UserDefaults.standard.removeObject(forKey: StorageKey.authVerificationID.rawValue)
        if let encoded = profile.encoded() {
          UserDefaults.standard.set(encoded, forKey: StorageKey.profile.rawValue)
        }
        if profile.username == nil {
          state.isUsernameSelectionVisible = true
        }
        return .none
        
      case .didSignIn(.failure(let error)):
        state.isVerificationPending = false
        UserDefaults.standard.removeObject(forKey: StorageKey.authVerificationID.rawValue)
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
              try await API.setUsername(
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
          UserDefaults.standard.set(encoded, forKey: StorageKey.profile.rawValue)
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
  }
}

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
      case .setStep(let step):
        state.step = step
        return .none
        
      case .viewTerms:
        if let url = URL(string: "https://podium.town/terms") {
          UIApplication.shared.open(url)
        }
        return .none
        
      case .dismissBanner:
        state.bannerData = nil
        return .none
        
      case .emailAddressChanged(let emailAddress):
        state.emailAddress = emailAddress
        return .none
        
      case .passwordChanged(let password):
        state.password = password
        return .none
        
      case .phoneNumberChanged(let phoneNumber):
        state.phoneNumber = phoneNumber
        return .none
        
      case .resend:
        state.isVerificationPending = false
        state.step = .phone
        state.verificationId = nil
        state.verificationCode = ""
        return .none
        
      case .usernameChanged(let username):
        state.username = username
        state.isUsernameValidated = username.count > 1
        return .none
        
      case .verificationCodeChanged(let verificationCode):
        state.verificationCode = verificationCode
        return .none
        
      case .verifyEmail:
        state.isVerificationPending = true
        let emailAddress = state.emailAddress
        let password = state.password
        return .task {
          await .didSignIn(TaskResult {
            try await API.verifyEmail(
              emailAddress: emailAddress,
              password: password
            )
          })
        }
        
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
        
      case .createAccount:
        state.isVerificationPending = true
        let emailAddress = state.emailAddress
        let password = state.password
        return .task {
          await .didSignIn(TaskResult {
            try await API.createAccount(
              emailAddress: emailAddress,
              password: password
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
          state.step = .createProfile
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
        state.isVerificationPending = true
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
        state.isVerificationPending = false
        if let encoded = profile.encoded() {
          UserDefaults.standard.set(encoded, forKey: StorageKey.profile.rawValue)
        }
        state.step = .phone
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

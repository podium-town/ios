//
//  LoginAction.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import ComposableArchitecture

enum LoginAction {
  case phoneNumberChanged(String)
  case verificationCodeChanged(String)
  case usernameChanged(String)
  case emailAddressChanged(String)
  case passwordChanged(String)
  case verifyPhone
  case didVerifyPhone(TaskResult<String>)
  case verifyEmail
  case createAccount
  case signIn
  case didSignIn(TaskResult<ProfileModel>)
  case dismissBanner
  case resend
  case setUsername
  case didSetUsername(TaskResult<ProfileModel>)
  case viewTerms
  case setStep(step: SignInStep)
}

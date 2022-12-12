//
//  LoginState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

enum SignInStep {
  case phone
  case email
  case emailRegister
  case createProfile
}

struct LoginState: Equatable {
  var isVerificationPending = false
  var isUsernameValidated = false
  var verificationId: String?
  var profile: ProfileModel?
  var phoneNumber = ""
  var emailAddress = ""
  var password = ""
  var verificationCode = ""
  var username = ""
  var bannerData: BannerData?
  var step: SignInStep = .phone
}

//
//  LoginState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

struct LoginState: Equatable {
  var isVerificationPending = false
  var isUsernameSelectionVisible = false
  var isUsernameValidated = false
  var verificationId: String?
  var profile: ProfileModel?
  var phoneNumber = ""
  var verificationCode = ""
  var username = ""
  var bannerData: BannerData?
}

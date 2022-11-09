//
//  LoginState.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

struct LoginState: Equatable {
  var isVerificationPending = false
  var verificationId: String?
  var phoneNumber = ""
  var verificationCode = ""
}

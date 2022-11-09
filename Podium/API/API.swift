//
//  API.swift
//  Podium
//
//  Created by Michael Jach on 08/11/2022.
//

import FirebaseAuth

class API {
  func verifyPhoneNumber(phoneNumber: String) async throws -> String {
    do {
      return try await PhoneAuthProvider.provider()
        .verifyPhoneNumber(phoneNumber, uiDelegate: nil)
    } catch let error {
      print(error)
      throw AppError.general
    }
  }
  
  func signIn(verificationId: String?, verificationCode: String?) async throws -> ProfileModel {
    if let verificationId = verificationId,
       let verificationCode = verificationCode {
      let credential = PhoneAuthProvider.provider().credential(
        withVerificationID: verificationId,
        verificationCode: verificationCode
      )
      do {
        let result = try await Auth.auth().signIn(with: credential)
        return ProfileModel(id: result.user.uid)
      } catch let error {
        print(error)
        throw AppError.general
      }
    } else {
      print("Kurwa!")
      throw AppError.general
    }
  }
}

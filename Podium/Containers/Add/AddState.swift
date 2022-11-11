//
//  AddState.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

struct AddState: Equatable {
  var profile: ProfileModel
  var text = ""
  var isSendPending = false
  var isSendDisabled = true
}

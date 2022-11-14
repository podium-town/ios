//
//  AddState.swift
//  Podium
//
//  Created by Michael Jach on 09/11/2022.
//

import ComposableArchitecture
import UIKit

struct AddState: Equatable {
  var profile: ProfileModel
  var text = ""
  var isSendPending = false
  var isSendDisabled = true
  var isPickerPresented = false
  var image: UIImage?
  var images: [UIImage] = []
}
